import re
import numpy as np
from sentence_transformers import SentenceTransformer
from transformers import AutoTokenizer
from sentence_transformers.util import cos_sim
from langdetect import detect
from groq import Groq
import os


model = SentenceTransformer("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")
tokenizer = AutoTokenizer.from_pretrained("sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2")


def clean_text(text: str) -> str:
    text = text.lower()
    text = re.sub(r"\b(tôi là|tôi|i am|i'm)\b", " ", text, flags=re.IGNORECASE)
    text = re.sub(r"\S+@\S+\.\S+", " ", text)  # email
    text = re.sub(r"\+?\d[\d\s\-\(\)]{8,}", " ", text)  # phone
    text = re.sub(r"\b[A-ZĐ][a-zà-ỹ]+\b", " ", text)  # proper nouns (names)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def chunk_text(text: str, max_tokens=512) -> list:
    tokens = tokenizer.tokenize(text)
    chunks = []
    for i in range(0, len(tokens), max_tokens):
        chunk_tokens = tokens[i:i+max_tokens]
        chunk = tokenizer.convert_tokens_to_string(chunk_tokens)
        chunks.append(chunk)
    return chunks


def get_text_embedding(text: str, chunk_size=512) -> np.ndarray:
    cleaned = clean_text(text)
    chunks = chunk_text(cleaned, max_tokens=chunk_size)
    if not chunks:
        return np.zeros(model.get_sentence_embedding_dimension())
    embeddings = model.encode(chunks)
    return np.mean(embeddings, axis=0)


def calculate_similarity(text1: str, text2: str) -> float:
    emb1 = get_text_embedding(text1)
    emb2 = get_text_embedding(text2)
    return cos_sim(emb1, emb2).item()


def make_cv_text(parsed_content: dict) -> str:
    parts = []
    for section in ['mo_ta_ban_than', 'kinh_nghiem_lam_viec', 'hoc_van', 'du_an']:
        value = parsed_content.get(section, [])
        if isinstance(value, list):
            parts.extend([str(item) for item in value])
        else:
            parts.append(str(value))
    parts.extend(parsed_content.get("ky_nang", []))
    return ' '.join(parts)

def detect_language(text: str) -> str:
    try:
        lang = detect(text)
        return 'vi' if lang.startswith('vi') else 'en'
    except:
        return 'en'

def build_reasoning_prompt(cv_text: str, jd_text: str, sim: dict, lang: str) -> str:
    def fmt(score):
        return f"{score:.4f}" if isinstance(score, (int, float)) else "N/A"

    if lang == "vi":
        prompt = f"""
Bạn là một chuyên gia tuyển dụng có kiến thức sâu rộng về đánh giá hồ sơ ứng viên. Dưới đây là nội dung CV và mô tả công việc (JD), cùng với một số điểm số thể hiện mức độ tương đồng giữa các phần chính (Kỹ năng, Kinh nghiệm, Học vấn, Tổng thể) được tính bằng công thức cosine similarity.
Điểm số tương đồng này chỉ để tham khảo và không phải là yếu tố quyết định duy nhất trong việc đánh giá ứng viên. Có thể quyết định dựa trên nội dung cụ thể của CV và JD. Nên đưa ra dẫn chứng cụ thể từ nội dung CV và JD để hỗ trợ đánh giá.
Hãy thực hiện các bước sau:
1. 🔹 **Điểm phù hợp**: Dựa trên nội dung CV và JD, hãy nêu rõ phần nào phù hợp với nhau, đặc biệt là những phần có điểm số tương đồng cao.
2. ⚠️ **Thiếu sót**: (Với những phần có điểm số tương đồng thấp) Hãy chỉ ra các thông tin thiếu, chưa khớp hoặc chưa làm nổi bật trong CV.
3. ✅ **Đề xuất cải thiện**: Gợi ý các bổ sung hoặc chỉnh sửa cụ thể mà ứng viên nên thực hiện để tăng khả năng phù hợp.


Điểm tương đồng cosine:
- Tổng thể: {fmt(sim['overall'])}
- Kỹ năng: {fmt(sim['skills'])}
- Kinh nghiệm: {fmt(sim['experience'])}
- Học vấn: {fmt(sim['education'])}

=== CV ===
{cv_text}

=== Mô tả công việc ===
{jd_text}

Chú ý: Trả về dưới dạng  markdown, sử dụng các tiêu đề và danh sách để làm rõ các phần khác nhau. Luôn phản hồi hoàn toàn bằng tiếng Việt mượt mà.
"""
    else:
        prompt = f"""You are a senior recruitment specialist with deep expertise in evaluating candidates. Below is a candidate's CV and a Job Description (JD), along with similarity scores (calculated using cosine similarity) that reflect alignment in key areas: skills, experience, education, and overall.
the similarity scores are for reference only and not the sole deciding factor in candidate evaluation. Decisions should be based on the specific content of the CV and JD, with concrete evidence from both to support the assessment.
Please perform the following analysis:
1. 🔹 **Matching Points**: Identify which parts of the CV align well with the JD, especially those with high similarity scores.
2. ⚠️ **Gaps**: (For sections with low similarity) Specify what is missing or underrepresented in the CV.
3. ✅ **Improvement Suggestions**: Provide specific recommendations for how the candidate can enhance their fit for the role.

Cosine Similarity Scores:
- Overall: {fmt(sim['overall'])}
- Skills: {fmt(sim['skills'])}
- Experience: {fmt(sim['experience'])}
- Education: {fmt(sim['education'])}

=== CV ===
{cv_text}

=== Job Description ===
{jd_text}

Note: Respond in markdown format with clear headings and lists. Always reply in English.
"""
    return prompt


def call_groq_reasoning(prompt: str) -> str:
    client = Groq(api_key=os.getenv("GROQ_API_KEY"))
    if detect_language(prompt) == "vi":
        lang = "vi"
    else:
        lang = "en"
    system_prompt = (
        "Bạn là một chuyên gia tuyển dụng có kiến thức sâu rộng về đánh giá hồ sơ ứng viên. "
        "Hãy phân tích chi tiết mức độ phù hợp giữa CV và JD, dựa trên điểm tương đồng cosine và nội dung cụ thể. "
        "Luôn phản hồi bằng tiếng Việt."
        if lang == "vi"
        else
        "You are a senior talent acquisition specialist with deep expertise in candidate evaluation. "
        "Analyze in detail the relevance between the CV and the Job Description, based on cosine similarity scores and content. "
        "Always respond in English."
    )
    chat_completion = client.chat.completions.create(
        model="llama3-8b-8192",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": prompt}
        ]
    )
    return chat_completion.choices[0].message.content
