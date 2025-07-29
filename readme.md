# AI Matching API (JD-CV Similarity)

API này cung cấp chức năng tính toán **độ tương đồng ngữ nghĩa giữa mô tả công việc (JD) và hồ sơ ứng viên (CV)** dựa trên các phần nội dung chính như mô tả bản thân, kỹ năng, kinh nghiệm, học vấn, dự án… Sử dụng mô hình `sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2`.

## 🚀 Khởi chạy

### 1. Yêu cầu
- Python 3.10+
- PostgreSQL (đã có schema)
- Docker (chỉ dùng cho PostgreSQL nếu muốn)
- Đã cài `venv`, `uvicorn`, `fastapi`

### 2. Cài đặt dependencies

```bash
pip install -r requirements.txt
```

### 3. Chạy API

```bash
uvicorn app.main:app --reload
```

---

## 🧠 Các Endpoint chính

### 1. Tính toán độ tương đồng JD - CV

**[POST] /api/v1/ai/calculate-match**

Tính embedding cho CV & JD → tính similarity → lưu vào `vector_matches`.

**Request body:**

```json
{
  "cv_id": 123,
  "candidate_id": 456,
  "job_id": 789
}
```

**Response:**

```json
{
  "match_id": 1,
  "job_id": 789,
  "candidate_id": 456,
  "cv_id": 123,
  "overall_similarity": 0.8123,
  "mo_ta_ban_than_similarity": 0.79,
  "ky_nang_similarity": 0.85,
  "kinh_nghiem_similarity": 0.81,
  "hoc_van_similarity": 0.74,
  "du_an_similarity": 0.66
}
```

---

### 2. Tra cứu độ tương đồng cosine theo embedding (phụ)

**[GET] /api/v1/ai/similarity**

Trả về cosine similarity giữa CV và JD embedding đã lưu.

**Query params:**

- `cv_id` (int): ID CV
- `job_id` (int): ID Job
- `section_type` (str): Loại văn bản so sánh, ví dụ: `full_text`, `ky_nang`, `kinh_nghiem_lam_viec`, ...

**Example:**

```http
GET /api/v1/ai/similarity?cv_id=123&job_id=789&section_type=ky_nang
```

**Response:**

```json
{
  "cv_id": 123,
  "job_id": 789,
  "section_type": "ky_nang",
  "cosine_similarity": 0.8467
}
```

---

## 🧼 Tiền xử lý dữ liệu CV

- Xoá cụm: `"tôi"`, `"tôi là"`, `"i'm"`, `"i am"`, email, số điện thoại, tên riêng.
- Cắt thành nhiều đoạn nhỏ ≤ 512 tokens (mô hình giới hạn).
- Lấy trung bình embedding để đại diện toàn văn bản.

---

## 🗃️ Cơ sở dữ liệu liên quan

- `cv_embeddings`: lưu vector từng phần của CV
- `job_embeddings`: lưu vector JD
- `vector_matches`: lưu kết quả similarity

---

## 🛠 Dev contact

- API maintainer: BEE
- Email: bee29082004@example.com
- Mô hình: `paraphrase-multilingual-MiniLM-L12-v2`

---

## 📌 Ghi chú

- Nếu CV đã được lưu embedding rồi → API sẽ tự cập nhật (UPSERT).
- JD cũng sẽ được embedding nếu chưa có.
