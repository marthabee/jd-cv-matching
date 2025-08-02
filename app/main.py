from fastapi import FastAPI, HTTPException, Query
from app.models import MatchRequest, MatchResponse
from app.db import (
    get_db_connection,
    save_cv_embedding,
    save_job_embedding,
    get_embedding
)
from app.utils import calculate_similarity, make_cv_text, clean_text, detect_language, build_reasoning_prompt, call_groq_reasoning
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
            experience_similarity, education_similarity, projects_similarity, weighted_score, last_calculated, cv_embedding_id,
            match_type, computed_at
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), %s, %s, NOW())
        RETURNING match_id
        """,
        (
            request.job_id,
            candidate_id,
            request.cv_id,
            overall_similarity,
            ky_nang_similarity,
            kinh_nghiem_similarity,
            hoc_van_similarity,
            du_an_similarity,
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
    cv_id: int = Query(...),
    job_id: int = Query(...),
    section_type: str = Query("full_text")
):
    conn = get_db_connection()
    cursor = conn.cursor()

    # mapping section_type -> column
    column_map = {
        "full_text": "overall_similarity",
        "ky_nang": "skills_similarity",
        "kinh_nghiem_lam_viec": "experience_similarity",
        "hoc_van": "education_similarity",
        "du_an": "projects_similarity",
        "weighted": "weighted_score"
    }

    if section_type not in column_map:
        raise HTTPException(status_code=400, detail=f"Invalid section_type. Must be one of {list(column_map.keys())}")

    col = column_map[section_type]

    cursor.execute(f"""
        SELECT {col}
        FROM vector_matches
        WHERE cv_id = %s AND job_id = %s
        ORDER BY last_calculated DESC
        LIMIT 1
    """, (cv_id, job_id))
    
    result = cursor.fetchone()
    cursor.close()
    conn.close()

    if not result:
        raise HTTPException(status_code=404, detail="No match result found")

    return {
        "cv_id": cv_id,
        "job_id": job_id,
        "section_type": section_type,
        "similarity_score": round(float(result[0]), 4)
    }


@app.get("/api/v1/ai/job-recommendations/{candidate_id}")
async def recommend_jobs(candidate_id: int, top_k: int = Query(5, ge=1, le=50)):
    conn = get_db_connection()
    cursor = conn.cursor()

    # --- B1: Lấy CV chính của ứng viên ---
    cursor.execute("""
        SELECT cv_id FROM candidate_cvs
        WHERE candidate_id = %s AND is_primary = TRUE
        LIMIT 1
    """, (candidate_id,))
    row = cursor.fetchone()

    # Nếu không có CV chính → fallback
    if not row:
        cursor.execute("""
            SELECT cv_id FROM candidate_cvs
            WHERE candidate_id = %s
            ORDER BY updated_at DESC
            LIMIT 1
        """, (candidate_id,))
        row = cursor.fetchone()

    if not row:
        raise HTTPException(status_code=404, detail="No JD found for candidate")

    cv_id = row[0]

    # --- B2: Lấy embedding của CV (full_text) ---
    cv_emb = get_embedding("cv_embeddings", "cv_id", cv_id, "full_text_embedding")
    if not cv_emb:
        raise HTTPException(status_code=404, detail="CV embedding not found")

    # --- B3: Lấy tất cả JD embedding ---
    cursor.execute("SELECT job_id, full_jd_embedding FROM job_embeddings")
    jd_rows = cursor.fetchall()

    if not jd_rows:
        return {"candidate_id": candidate_id, "cv_id": cv_id, "recommendations": []}

    recommendations = []

    for job_id, jd_emb in jd_rows:
        if not jd_emb:
            continue

        # --- B4: Nếu đã từng match → lấy overall_similarity ---
        cursor.execute("""
            SELECT overall_similarity FROM vector_matches
            WHERE cv_id = %s AND job_id = %s
            ORDER BY last_calculated DESC
            LIMIT 1
        """, (cv_id, job_id))
        match = cursor.fetchone()

        if match:
            sim = match[0]
        else:
            # --- Nếu chưa có, tính cosine mới ---
            try:
                sim = cos_sim(np.array(cv_emb), np.array(jd_emb)).item()
            except Exception as e:
                print(f"⚠️ Cosine error for job_id={job_id}: {e}")
                continue

        recommendations.append((job_id, sim))

    cursor.close()
    conn.close()

    # --- B5: Sắp xếp giảm dần & trả về Top-K ---
    recommendations.sort(key=lambda x: x[1], reverse=True)
    top_k_recs = recommendations[:top_k]

    return {
        "candidate_id": candidate_id,
        "cv_id": cv_id,
        "top_k": top_k,
        "recommendations": [
            {"job_id": job_id, "overall_similarity": round(score, 4)}
            for job_id, score in top_k_recs
        ]
    }


@app.get("/api/v1/ai/match-analysis/{application_id}")
async def match_reasoning(application_id: int):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT a.cv_id, a.job_id,
               vm.overall_similarity, vm.skills_similarity,
               vm.experience_similarity, vm.education_similarity,
               cc.parsed_content,
               j.description, j.requirements
        FROM applications a
        JOIN vector_matches vm ON vm.cv_id = a.cv_id AND vm.job_id = a.job_id
        JOIN cv_content cc ON cc.cv_id = a.cv_id
        JOIN jobs j ON j.job_id = a.job_id
        WHERE a.application_id = %s
    """, (application_id,))

    row = cursor.fetchone()

    if not row:
        cursor.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Application not found")

    (
        cv_id, job_id,
        overall, skills_sim, exp_sim, edu_sim,
        parsed_content, jd_desc, jd_reqs
    ) = row

    parsed = json.loads(parsed_content) if isinstance(parsed_content, str) else parsed_content
    jd_text = f"{jd_desc}\n\nRequirements:\n{jd_reqs}"
    cv_text = make_cv_text(parsed)

    sim_scores = {
        "overall": overall,
        "skills": skills_sim,
        "experience": exp_sim,
        "education": edu_sim
    }

    combined_text = f"{cv_text}\n\n{jd_text}"
    lang = detect_language(combined_text)

    prompt = build_reasoning_prompt(cv_text, jd_text, sim_scores, lang)
    reasoning = call_groq_reasoning(prompt)

    ai_analysis_data = {
        "language": lang,
        "match_scores": sim_scores,
        "reasoning": reasoning
    }

    cursor.execute(
        "UPDATE applications SET ai_analysis = %s, updated_at = NOW() WHERE application_id = %s",
        (json.dumps(ai_analysis_data), application_id)
    )
    conn.commit()
    cursor.close()
    conn.close()

    return {
        "application_id": application_id,
        "cv_id": cv_id,
        "job_id": job_id,
        "language_detected": lang,
        **sim_scores,
        "reasoning": reasoning
    }
