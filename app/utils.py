import re
import numpy as np
from sentence_transformers import SentenceTransformer
from transformers import AutoTokenizer
from sentence_transformers.util import cos_sim

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
