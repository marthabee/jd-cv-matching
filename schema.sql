-- =============================================
-- USERS & AUTHENTICATION
-- =============================================
CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    phone VARCHAR(20),
    full_name VARCHAR(200) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('CANDIDATE', 'RECRUITER', 'ADMIN')),
    auth_provider VARCHAR(20) DEFAULT 'LOCAL',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_profile (
    user_id BIGINT PRIMARY KEY REFERENCES users(user_id) ON DELETE CASCADE,
    profile_image_url VARCHAR(500),
    bio TEXT,
    website_url VARCHAR(500),
    languages TEXT[],
    profile_completed BOOLEAN DEFAULT FALSE,
    account_status VARCHAR(20) DEFAULT 'PENDING',
    last_login_at TIMESTAMP,
    login_attempts INT DEFAULT 0,
    locked_until TIMESTAMP
);

CREATE TABLE user_verification (
    verification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    verification_type VARCHAR(20) CHECK (verification_type IN ('EMAIL', 'PHONE', 'PASSWORD_RESET')),
    verification_code VARCHAR(100),
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- CANDIDATES & PROFILES
-- =============================================
CREATE TABLE candidate_profiles (
    profile_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    date_of_birth DATE,
    gender VARCHAR(20),
    address TEXT,
    city_id INT,
    district_id INT,
    education_level VARCHAR(20),
    years_experience INT,
    current_job_title VARCHAR(200),
    current_salary DECIMAL(12,2),
    expected_salary DECIMAL(12,2),
    notice_period_days INT,
    willing_to_relocate BOOLEAN DEFAULT FALSE,
    remote_work_preference VARCHAR(20),
    primary_cv_id BIGINT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);



-- =============================================
-- RECRUITER PROFILES
-- =============================================
CREATE TABLE recruiter_profiles (
    profile_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    company_id BIGINT REFERENCES companies(company_id) ON DELETE CASCADE,
    position VARCHAR(100),
    department VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- COMPANIES
-- =============================================
CREATE TABLE companies (
    company_id BIGSERIAL PRIMARY KEY,
    company_name VARCHAR(200),
    tax_code VARCHAR(50) UNIQUE,
    description TEXT,
    industry VARCHAR(100),
    company_size VARCHAR(20),
    address TEXT,
    district_id INT,
    website VARCHAR(500),
    logo_url VARCHAR(500),
    company_status VARCHAR(20) DEFAULT 'PENDING',
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- JOBS
-- =============================================
CREATE TABLE jobs (
    job_id BIGSERIAL PRIMARY KEY,
    recruiter_id BIGINT REFERENCES users(user_id),
    company_id BIGINT REFERENCES companies(company_id) ON DELETE CASCADE,
    title VARCHAR(200),
    description TEXT,
    requirements TEXT,
    responsibilities TEXT,
    experience_level VARCHAR(20),
    employment_type VARCHAR(20),
    salary_min DECIMAL(12,2),
    salary_max DECIMAL(12,2),
    city_id INT,
    work_arrangement VARCHAR(20),
    min_experience_years INT,
    max_experience_years INT,
    category VARCHAR(100),
    education_requirements TEXT,
    language_requirements TEXT[],
    application_deadline DATE,
    auto_review_threshold DECIMAL(3,2),
    priority_level VARCHAR(20),
    featured BOOLEAN DEFAULT FALSE,
    status VARCHAR(20),
    published_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE job_skills (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    skill_name VARCHAR(100),
    is_required BOOLEAN,
    importance_level VARCHAR(20),
    min_years_experience INT,
    created_at TIMESTAMP DEFAULT NOW()
);


-- =============================================
-- CVS & EMBEDDINGS
-- =============================================
CREATE TABLE candidate_cvs (
    cv_id BIGSERIAL PRIMARY KEY,
    candidate_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    cv_name VARCHAR(200),
    file_name VARCHAR(255),
    file_path VARCHAR(500),
    file_size BIGINT,
    file_type VARCHAR(20),
    is_primary BOOLEAN,
    parsing_status VARCHAR(20),
    parsing_error TEXT,
    language VARCHAR(10),
    cv_version INT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cv_content (
    content_id BIGSERIAL PRIMARY KEY,
    cv_id BIGINT REFERENCES candidate_cvs(cv_id) ON DELETE CASCADE,
    raw_text TEXT,
    parsed_content JSONB,
    ai_analysis JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cv_embeddings (
    embedding_id BIGSERIAL PRIMARY KEY,
    cv_id BIGINT REFERENCES candidate_cvs(cv_id) ON DELETE CASCADE,
    candidate_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    full_text_embedding VECTOR(384),
    skills_embedding VECTOR(384),
    experience_embedding VECTOR(384),
    education_embedding VECTOR(384),
    projects_embedding VECTOR(384),
    model_version VARCHAR(100),
    content_hash VARCHAR(64),
    confidence_score DECIMAL(4,3),
    section_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE job_embeddings (
    embedding_id BIGSERIAL PRIMARY KEY,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    full_jd_embedding VECTOR(384),
    requirements_embedding VECTOR(384),
    skills_embedding VECTOR(384),
    model_version VARCHAR(100),
    embedding_created_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE vector_matches (
    match_id BIGSERIAL PRIMARY KEY,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    candidate_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    cv_id BIGINT REFERENCES candidate_cvs(cv_id),
    overall_similarity DECIMAL(5,4),
    skills_similarity DECIMAL(5,4),
    experience_similarity DECIMAL(5,4),
    education_similarity DECIMAL(5,4),
    projects_similarity DECIMAL(5,4),
    weighted_score DECIMAL(5,4),
    last_calculated TIMESTAMP,
    cv_embedding_id BIGINT REFERENCES cv_embeddings(embedding_id),
    valid_until TIMESTAMP,
    match_type VARCHAR(30), -- AUTO, MANUAL, AI_SUGGEST
    computed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);



-- =============================================
-- APPLICATIONS & STATUS TRACKING
-- =============================================
CREATE TABLE applications (
    application_id BIGSERIAL PRIMARY KEY,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    candidate_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    cv_id BIGINT REFERENCES candidate_cvs(cv_id),
    cover_letter TEXT,
    ai_match_score DECIMAL(5,2),
    ai_analysis JSONB,
    reviewed_by BIGINT REFERENCES users(user_id),
    reviewed_at TIMESTAMP,
    rejection_reason TEXT,
    notes TEXT,
    priority VARCHAR(20),
    current_status VARCHAR(30),
    submitted_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(job_id, candidate_id)
);

CREATE TABLE application_status_history (
    history_id BIGSERIAL PRIMARY KEY,
    application_id BIGINT REFERENCES applications(application_id) ON DELETE CASCADE,
    from_status VARCHAR(30),
    to_status VARCHAR(30),
    changed_by BIGINT REFERENCES users(user_id),
    change_reason TEXT,
    automated BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================
-- TESTING & ASSESSMENTS
-- =============================================
CREATE TABLE job_tests (
    test_id BIGSERIAL PRIMARY KEY,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    test_name VARCHAR(200),
    test_type VARCHAR(30),
    difficulty_level VARCHAR(20),
    duration_minutes INT,
    passing_score DECIMAL(5,2),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE test_questions (
    question_id BIGSERIAL PRIMARY KEY,
    test_id BIGINT REFERENCES job_tests(test_id) ON DELETE CASCADE,
    question_text TEXT,
    question_type VARCHAR(30),
    points DECIMAL(5,2),
    time_limit_seconds INT,
    order_index INT,
    explanation TEXT,
    required BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE question_options (
    option_id BIGSERIAL PRIMARY KEY,
    question_id BIGINT REFERENCES test_questions(question_id) ON DELETE CASCADE,
    option_text TEXT,
    is_correct BOOLEAN DEFAULT FALSE,
    order_index INT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE test_results (
    result_id BIGSERIAL PRIMARY KEY,
    application_id BIGINT REFERENCES applications(application_id) ON DELETE CASCADE,
    test_id BIGINT REFERENCES job_tests(test_id),
    start_time TIMESTAMP,
    submit_time TIMESTAMP,
    total_score DECIMAL(5,2),
    percentage DECIMAL(5,2),
    status VARCHAR(20),
    passed BOOLEAN,
    time_taken_seconds INT,
    graded_by BIGINT REFERENCES users(user_id),
    graded_at TIMESTAMP,
    feedback TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE question_answers (
    answer_id BIGSERIAL PRIMARY KEY,
    result_id BIGINT REFERENCES test_results(result_id) ON DELETE CASCADE,
    question_id BIGINT REFERENCES test_questions(question_id),
    answer_text TEXT,
    is_correct BOOLEAN,
    points_earned DECIMAL(5,2),
    time_taken_seconds INT,
    submitted_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL UNIQUE,
    region VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE districts (
    district_id SERIAL PRIMARY KEY,
    city_id INT REFERENCES cities(city_id) ON DELETE CASCADE,
    district_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE candidate_skills (
    candidate_skill_id SERIAL PRIMARY KEY,
    profile_id BIGINT REFERENCES candidate_profiles(profile_id) ON DELETE CASCADE,
    skill_id INT REFERENCES skills(skill_id) ON DELETE CASCADE,
    proficiency_level VARCHAR(20) CHECK (proficiency_level IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED')),
    years_experience INT CHECK (years_experience >= 0),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE candidate_interests (
    candidate_interests_id SERIAL PRIMARY KEY,
    profile_id BIGINT REFERENCES candidate_profiles(profile_id) ON DELETE CASCADE,
    interest_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE saved_jobs (
    saved_id SERIAL PRIMARY KEY,
    candidate_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    job_id BIGINT REFERENCES jobs(job_id) ON DELETE CASCADE,
    saved_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(candidate_id, job_id)
);


-- =============================================
-- SYSTEM EVENTS & LOGS
-- =============================================
CREATE TABLE email_queue (
    email_id BIGSERIAL PRIMARY KEY,
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(300),
    template_name VARCHAR(100),
    template_data JSONB,
    status VARCHAR(20) DEFAULT 'PENDING',  -- SENT, FAILED
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    clicked_at TIMESTAMP,
    error_message TEXT,
    email_type VARCHAR(30), -- SYSTEM, OTP, JOB_ALERT
    metadata JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE notifications (
    notification_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    title VARCHAR(200),
    message TEXT,
    type VARCHAR(30),
    priority VARCHAR(20),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    data JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE chat_sessions (
    session_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    started_at TIMESTAMP DEFAULT NOW(),
    ended_at TIMESTAMP,
    platform VARCHAR(30),
    ip_address INET,
    user_agent TEXT,
    language VARCHAR(10)
);

CREATE TABLE chat_messages (
    message_id BIGSERIAL PRIMARY KEY,
    session_id BIGINT REFERENCES chat_sessions(session_id) ON DELETE CASCADE,
    sender_type VARCHAR(10) CHECK (sender_type IN ('USER', 'BOT')),
    sender_id BIGINT,
    message_text TEXT,
    message_type VARCHAR(20),
    intent VARCHAR(100),
    confidence DECIMAL(4,3),
    response_time_ms INT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE chat_feedback (
    feedback_id BIGSERIAL PRIMARY KEY,
    session_id BIGINT REFERENCES chat_sessions(session_id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(user_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE faq_embeddings (
    embedding_id BIGSERIAL PRIMARY KEY,
    content_type VARCHAR(50) CHECK (content_type IN ('FAQ', 'DOC', 'HELP_CENTER')),
    original_text TEXT NOT NULL,
    embedding VECTOR(1536),
    model_version VARCHAR(50),
    tags TEXT[],
    language VARCHAR(10),
    created_at TIMESTAMP DEFAULT NOW()
);



CREATE TABLE chat_message_embeddings (
    embedding_id BIGSERIAL PRIMARY KEY,
    message_id BIGINT REFERENCES chat_messages(message_id) ON DELETE CASCADE,
    embedding VECTOR(1536),
    model_version VARCHAR(50),
    intent VARCHAR(100),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_preference_embeddings (
    embedding_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    preference_summary TEXT,
    embedding VECTOR(1536),
    model_version VARCHAR(50),
    generated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE chat_feedback (
    feedback_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id) ON DELETE CASCADE,
    message_id BIGINT REFERENCES chat_messages(message_id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    feedback_type VARCHAR(20) CHECK (feedback_type IN ('LIKE', 'DISLIKE', 'REPORT_ISSUE')),
    created_at TIMESTAMP DEFAULT NOW()
);





CREATE TABLE audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    action VARCHAR(100),
    entity_type VARCHAR(50),
    entity_id BIGINT,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    session_id VARCHAR(100),
    success BOOLEAN,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE security_events (
    event_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    event_type VARCHAR(50),
    severity VARCHAR(20),
    description TEXT,
    ip_address INET,
    location VARCHAR(255),
    user_agent TEXT,
    metadata JSONB,
    resolved BOOLEAN DEFAULT FALSE,
    resolved_by BIGINT REFERENCES users(user_id),
    resolved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

