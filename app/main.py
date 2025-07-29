from fastapi import FastAPI, HTTPException, Query
from app.models import MatchRequest, MatchResponse
from app.db import (
    get_db_connection,
    save_cv_embedding,
    save_job_embedding,
    get_embedding,
)
from app.utils import calculate_similarity, make_cv_text, clean_text
from sentence_transformers.util import cos_sim
import numpy as np
import json

app = FastAPI()

@app.post("/api/v1/ai/calculate-match", response_model=MatchResponse)
async def calculate_match(request: MatchRequest):
    conn = get_db_connection()
    cursor = conn.cursor()

    # Lấy candidate_id từ cv_id
    cursor.execute("SELECT candidate_id FROM candidate_cvs WHERE cv_id = %s", (request.cv_id,))
    result = cursor.fetchone()
    if not result:
        raise HTTPException(status_code=404, detail="CV not found")
    candidate_id = result[0]

    # Lấy parsed_content từ cv_content
    cursor.execute(
        """
        SELECT parsed_content FROM cv_content
        WHERE cv_id = %s
        """,
        (request.cv_id,),
    )
    parsed_result = cursor.fetchone()
    if not parsed_result:
        raise HTTPException(status_code=404, detail="Parsed CV not found")

    parsed_content = parsed_result[0]
    parsed_content = json.loads(parsed_content) if isinstance(parsed_content, str) else parsed_content

    # Lấy JD từ bảng jobs
    cursor.execute("SELECT description, requirements FROM jobs WHERE job_id = %s", (request.job_id,))
    job_data = cursor.fetchone()
    if not job_data:
        raise HTTPException(status_code=404, detail="Job not found")

    description, requirements = job_data
    jd_text = f"{description} {requirements}"

    # Tạo văn bản CV tổng hợp và lưu embedding full_text
    cv_full_text = make_cv_text(parsed_content)
    cv_embedding_id = save_cv_embedding(request.cv_id, candidate_id, cv_full_text, 'full_text')

    # Tách từng phần của CV
    mo_ta_ban_than = parsed_content.get('mo_ta_ban_than', '')

    ky_nang_parsed = parsed_content.get('ky_nang', [])

    # Lấy kỹ năng từ bảng candidate_skills
    cursor.execute("""
        SELECT s.skill_name
        FROM candidate_skills cs
        JOIN candidate_profiles cp ON cp.user_id = %s
        JOIN skills s ON cs.skill_id = s.skill_id
        WHERE cs.profile_id = cp.profile_id
    """, (candidate_id,))
    ky_nang_db = [row[0] for row in cursor.fetchall()]

    # Gộp kỹ năng
    all_skills = list(set(ky_nang_parsed + ky_nang_db))
    ky_nang = ' '.join(all_skills)

    kinh_nghiem = ' '.join([
        clean_text(str(item.get(f, '')))
        for item in parsed_content.get('kinh_nghiem_lam_viec', [])
        for f in ['vi_tri', 'cong_ty', 'dia_diem', 'thoi_gian', 'mo_ta']
    ])
    hoc_van = ' '.join([
        clean_text(str(item.get(f, '')))
        for item in parsed_content.get('hoc_van', [])
        for f in ['truong', 'nganh', 'trinh_do', 'xep_loai']
    ])
    du_an = ' '.join([
        clean_text(str(item.get(f, '')))
        for item in parsed_content.get('du_an', [])
        for f in ['ten_du_an', 'vai_tro', 'mo_ta']
    ])

    # Lưu từng phần embedding
    save_cv_embedding(request.cv_id, candidate_id, mo_ta_ban_than, 'mo_ta_ban_than')
    save_cv_embedding(request.cv_id, candidate_id, ky_nang, 'ky_nang')
    save_cv_embedding(request.cv_id, candidate_id, kinh_nghiem, 'kinh_nghiem_lam_viec')
    save_cv_embedding(request.cv_id, candidate_id, hoc_van, 'hoc_van')
    save_cv_embedding(request.cv_id, candidate_id, du_an, 'du_an')

    # Lưu JD embedding
    save_job_embedding(request.job_id, jd_text, 'full_jd')

    # Tính độ tương đồng giữa các phần
    overall_similarity = calculate_similarity(cv_full_text, jd_text)
    mo_ta_ban_than_similarity = calculate_similarity(mo_ta_ban_than, requirements) if mo_ta_ban_than else 0.0
    ky_nang_similarity = calculate_similarity(ky_nang, requirements) if ky_nang else 0.0
    kinh_nghiem_similarity = calculate_similarity(kinh_nghiem, requirements) if kinh_nghiem else 0.0
    hoc_van_similarity = calculate_similarity(hoc_van, requirements) if hoc_van else 0.0
    du_an_similarity = calculate_similarity(du_an, requirements) if du_an else 0.0

    weighted_score = overall_similarity

    # Lưu kết quả so khớp vào vector_matches
    cursor.execute(
        """
        INSERT INTO vector_matches (
            job_id, candidate_id, cv_id, overall_similarity, skills_similarity,
            experience_similarity, weighted_score, last_calculated, cv_embedding_id,
            match_type, computed_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, NOW(), %s, %s, NOW())
        RETURNING match_id
        """,
        (
            request.job_id,
            candidate_id,
            request.cv_id,
            overall_similarity,
            ky_nang_similarity,
            kinh_nghiem_similarity,
            weighted_score,
            cv_embedding_id,
            'sbert',
        ),
    )
    match_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()

    return MatchResponse(
        match_id=match_id,
        job_id=request.job_id,
        candidate_id=candidate_id,
        cv_id=request.cv_id,
        overall_similarity=overall_similarity,
        mo_ta_ban_than_similarity=mo_ta_ban_than_similarity,
        ky_nang_similarity=ky_nang_similarity,
        kinh_nghiem_similarity=kinh_nghiem_similarity,
        hoc_van_similarity=hoc_van_similarity,
        du_an_similarity=du_an_similarity,
    )


@app.get("/api/v1/ai/similarity")
async def get_similarity(
    cv_id: int = Query(..., description="CV ID"),
    job_id: int = Query(..., description="Job ID"),
    section_type: str = Query("full_text", description="Loại embedding: full_text, ky_nang, kinh_nghiem_lam_viec,...")
):
    cv_emb = get_embedding("cv_embeddings", "cv_id", cv_id, f"{section_type}_embedding")
    job_emb = get_embedding("job_embeddings", "job_id", job_id, "full_jd_embedding")

    if not cv_emb or not job_emb:
        raise HTTPException(status_code=404, detail="Missing embeddings")

    similarity = cos_sim(np.array(cv_emb), np.array(job_emb)).item()

    return {
        "cv_id": cv_id,
        "job_id": job_id,
        "section_type": section_type,
        "cosine_similarity": round(float(similarity), 4)
    }
