import psycopg2
from psycopg2.extras import Json
from sentence_transformers import SentenceTransformer
import numpy as np
from dotenv import load_dotenv
import os
import json

load_dotenv()

def get_db_connection():
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME"),
        user=os.getenv("DB_USER"),
        password=os.getenv("DB_PASSWORD"),
        host=os.getenv("DB_HOST"),
        port=os.getenv("DB_PORT")
    )

# Khởi tạo mô hình SBERT
model = SentenceTransformer('sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')

def save_cv_embedding(cv_id, candidate_id, text, column):
    embedding = model.encode(text, normalize_embeddings=True).tolist()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        f"""
        INSERT INTO cv_embeddings (cv_id, candidate_id, {column}, model_version, created_at)
        VALUES (%s, %s, %s, %s, NOW())
        ON CONFLICT (cv_id, candidate_id) DO UPDATE 
        SET {column} = EXCLUDED.{column},
            model_version = EXCLUDED.model_version,
            updated_at = NOW()
        RETURNING embedding_id
        """,
        (cv_id, candidate_id, embedding, 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
    )
    embedding_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return embedding_id


def save_job_embedding(job_id, text, column):
    embedding = model.encode(text, normalize_embeddings=True).tolist()
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        f"""
        INSERT INTO job_embeddings (job_id, {column}, model_version, created_at)
        VALUES (%s, %s, %s, NOW())
        ON CONFLICT (job_id) DO UPDATE 
        SET {column} = EXCLUDED.{column},
            model_version = EXCLUDED.model_version,
            updated_at = NOW()
        RETURNING embedding_id
        """,
        (job_id, embedding, 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2')
    )

    embedding_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return embedding_id


def get_embedding(table, id_column, id_value, embedding_column):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(f"SELECT {embedding_column} FROM {table} WHERE {id_column} = %s", (id_value,))
    result = cursor.fetchone()
    cursor.close()
    conn.close()

    if not result or result[0] is None:
        return None

    raw = result[0]

    # Nếu là tuple chứa string
    if isinstance(raw, (tuple, list)) and isinstance(raw[0], str):
        try:
            raw = json.loads(raw[0])
        except Exception:
            return None

    # Nếu là chuỗi JSON
    if isinstance(raw, str):
        try:
            raw = json.loads(raw)
        except Exception:
            return None

    # Cuối cùng: đảm bảo list[float]
    try:
        return [float(x) for x in raw]
    except Exception as e:
        print(f"⚠️ Error parsing embedding to float: {e}")
        return None