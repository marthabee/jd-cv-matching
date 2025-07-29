import psycopg2
from psycopg2.extras import Json
from sentence_transformers import SentenceTransformer
import numpy as np
from dotenv import load_dotenv
import os

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

def save_cv_embedding(cv_id, candidate_id, text, section_type):
    embedding = model.encode(text, normalize_embeddings=True).tolist()
    conn = get_db_connection()
    cursor = conn.cursor()
    # Lưu vào đúng cột theo section_type
    if section_type == 'full_text':
        column = 'full_text_embedding'
    elif section_type == 'ky_nang':
        column = 'skills_embedding'
    elif section_type == 'kinh_nghiem_lam_viec':
        column = 'experience_embedding'
    else:
        column = 'full_text_embedding' 

    cursor.execute(
        f"""
        INSERT INTO cv_embeddings (cv_id, candidate_id, {column}, model_version, section_type)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (cv_id, candidate_id, section_type) DO UPDATE 
        SET {column} = EXCLUDED.{column},
            model_version = EXCLUDED.model_version,
            created_at = NOW()
        RETURNING embedding_id
        """,
        (cv_id, candidate_id, embedding, 'sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2', section_type)
    )
    embedding_id = cursor.fetchone()[0]
    conn.commit()
    cursor.close()
    conn.close()
    return embedding_id

def save_job_embedding(job_id, text, section_type):
    embedding = model.encode(text, normalize_embeddings=True).tolist()
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO job_embeddings (job_id, full_jd_embedding, model_version, created_at)
        VALUES (%s, %s, %s, NOW())
        ON CONFLICT (job_id) DO UPDATE 
        SET full_jd_embedding = EXCLUDED.full_jd_embedding,
            created_at = NOW()
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
    return result[0] if result else None