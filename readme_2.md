# 🧠 Hướng dẫn tích hợp FE & BE cho hệ thống AI Matching

---

## 🧠 Mục tiêu hệ thống

🔹  Ứng dụng AI nhằm:

- Phân tích mức độ phù hợp giữa **CV ứng viên** và **Job Description (JD)**.
- Gợi ý việc làm phù hợp.
- Sinh đánh giá AI tự động cho đơn ứng tuyển.

---

## 📌 Hướng dẫn Frontend (FE)

### 1. API So khớp CV & JD

- **POST** `/api/v1/ai/calculate-match`
- **Body**:

```json
{
  "cv_id": 123,
  "job_id": 456
}
```

- **Response**:

```json
{
  "match_id": 1,
  "job_id": 456,
  "candidate_id": 78,
  "cv_id": 123,
  "overall_similarity": 0.82,
  "mo_ta_ban_than_similarity": 0.76,
  "ky_nang_similarity": 0.85,
  "kinh_nghiem_similarity": 0.80,
  "hoc_van_similarity": 0.65
}
```

---

### 2. API Điểm so khớp chi tiết theo phần

- **GET** `/api/v1/ai/similarity`
- **Params**:
  - `cv_id`, `job_id`
  - `section_type`: `full_text`, `ky_nang`, `kinh_nghiem_lam_viec`, `hoc_van`, `du_an`
- **Response**:

```json
{
  "cv_id": 123,
  "job_id": 456,
  "section_type": "ky_nang",
  "similarity_score": 0.85
}
```

---

### 3. API Gợi ý việc làm

- **GET** `/api/v1/ai/job-recommendations/{candidate_id}`
- **Params**: `top_k`
- **Response**:

```json
{
  "candidate_id": 78,
  "cv_id": 123,
  "top_k": 5,
  "recommendations": [
    {
      "job_id": 456,
      "title": "Data Scientist",
      "group": "ABC Corp",
      "overall_similarity": 0.87
    }
  ]
}
```

---

### 4. API Phân tích AI đơn ứng tuyển

- **GET** `/api/v1/ai/match-analysis/{application_id}`
- **Response**:

```json
{
  "application_id": 999,
  "cv_id": 123,
  "job_id": 456,
  "language_detected": "vi",
  "overall": 0.81,
  "skills": 0.84,
  "experience": 0.78,
  "education": 0.60,
  "reasoning": "## Điểm phù hợp..."
}
```

---

## 🔧 Hướng dẫn Backend (BE)

### 1. Các thành phần

- `main.py`: FastAPI endpoint
- `models.py`: Pydantic models
- `db.py`: Lưu embedding, truy vấn DB
- `utils.py`: Tính cosine, gọi Groq reasoning

### 2. Pipeline chính `/calculate-match`

- Lấy thông tin JD, CV
- Sinh embedding (SBERT)
- Tính cosine similarity giữa từng phần
- Ghi vào `vector_matches`

### 3. Embedding

- SBERT model: `paraphrase-multilingual-MiniLM-L12-v2`
- Lưu dạng list[float] vào PostgreSQL: `job_embeddings`, `cv_embeddings`

### 4. AI Reasoning

- Gọi Groq API
- Prompt sinh tự động theo ngôn ngữ CV & JD
- Trả về lý do markdown

---

## 📄 Ghi chú DB

| Mục          | Bảng                           | Mô tả                |
| ------------ | ------------------------------ | -------------------- |
| CV           | cv\_content, cv\_embeddings    | Nội dung + embedding |
| JD           | jobs, job\_embeddings          | JD và embedding      |
| Skills       | job\_skills, candidate\_skills | Gộp từ parse và DB   |
| Match        | vector\_matches                | So khớp cosine       |
| Phân tích AI | applications.ai\_analysis      | Markdown lý do AI    |

---

## ✅ FE & BE Checklist

### Frontend:

-

### Backend:

-

