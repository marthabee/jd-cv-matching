-- Reset sequences to avoid duplicate key errors
ALTER SEQUENCE cities_city_id_seq RESTART WITH 1;
ALTER SEQUENCE districts_district_id_seq RESTART WITH 1;
ALTER SEQUENCE skills_skill_id_seq RESTART WITH 1;
ALTER SEQUENCE users_user_id_seq RESTART WITH 1;
ALTER SEQUENCE user_verification_verification_id_seq RESTART WITH 1;
ALTER SEQUENCE candidate_profiles_profile_id_seq RESTART WITH 1;
ALTER SEQUENCE candidate_skills_candidate_skill_id_seq RESTART WITH 1;
ALTER SEQUENCE candidate_interests_candidate_interests_id_seq RESTART WITH 1;
ALTER SEQUENCE companies_company_id_seq RESTART WITH 1;
ALTER SEQUENCE recruiter_profiles_profile_id_seq RESTART WITH 1;
ALTER SEQUENCE jobs_job_id_seq RESTART WITH 1;
ALTER SEQUENCE job_skills_id_seq RESTART WITH 1;
ALTER SEQUENCE candidate_cvs_cv_id_seq RESTART WITH 1;
ALTER SEQUENCE cv_content_content_id_seq RESTART WITH 1;
ALTER SEQUENCE applications_application_id_seq RESTART WITH 1;
ALTER SEQUENCE application_status_history_history_id_seq RESTART WITH 1;
ALTER SEQUENCE job_tests_test_id_seq RESTART WITH 1;
ALTER SEQUENCE test_questions_question_id_seq RESTART WITH 1;
ALTER SEQUENCE question_options_option_id_seq RESTART WITH 1;
ALTER SEQUENCE test_results_result_id_seq RESTART WITH 1;
ALTER SEQUENCE question_answers_answer_id_seq RESTART WITH 1;
ALTER SEQUENCE saved_jobs_saved_id_seq RESTART WITH 1;
ALTER SEQUENCE email_queue_email_id_seq RESTART WITH 1;
ALTER SEQUENCE notifications_notification_id_seq RESTART WITH 1;
ALTER SEQUENCE chat_sessions_session_id_seq RESTART WITH 1;
ALTER SEQUENCE chat_messages_message_id_seq RESTART WITH 1;
ALTER SEQUENCE chat_feedback_feedback_id_seq RESTART WITH 1;
ALTER SEQUENCE audit_logs_log_id_seq RESTART WITH 1;
ALTER SEQUENCE security_events_event_id_seq RESTART WITH 1;

-- Sample data for cities
INSERT INTO cities (city_name, region) VALUES
('Hanoi', 'North'),
('Ho Chi Minh City', 'South'),
('Da Nang', 'Central'),
('Hai Phong', 'North'),
('Can Tho', 'South');

-- Sample data for districts
INSERT INTO districts (city_id, district_name) VALUES
(1, 'Ba Dinh'),
(1, 'Hoan Kiem'),
(2, 'District 1'),
(2, 'District 7'),
(3, 'Hai Chau'),
(4, 'Hong Bang'),
(5, 'Ninh Kieu');

-- Sample data for skills
INSERT INTO skills (skill_name, description, category) VALUES
('Python', 'Python programming language', 'Programming'),
('JavaScript', 'JavaScript programming language', 'Programming'),
('Project Management', 'Project management skills', 'Management'),
('SQL', 'Database management and querying', 'Database'),
('Java', 'Java programming language', 'Programming'),
('React', 'React JavaScript library', 'Programming'),
('AWS', 'Amazon Web Services', 'Cloud Computing');

-- Sample data for users (10 users)
INSERT INTO users (email, password_hash, phone, full_name, role, auth_provider, is_active) VALUES
('john.doe@example.com', '$2a$10$hashedpassword1', '+84912345678', 'John Doe', 'CANDIDATE', 'LOCAL', TRUE),
('jane.smith@example.com', '$2a$10$hashedpassword2', '+84987654321', 'Jane Smith', 'RECRUITER', 'LOCAL', TRUE),
('admin@example.com', '$2a$10$hashedpassword3', '+84911223344', 'Admin User', 'ADMIN', 'LOCAL', TRUE),
('alice.brown@example.com', '$2a$10$hashedpassword4', '+84922334455', 'Alice Brown', 'CANDIDATE', 'LOCAL', TRUE),
('bob.johnson@example.com', '$2a$10$hashedpassword5', '+84933445566', 'Bob Johnson', 'CANDIDATE', 'LOCAL', TRUE),
('emma.wilson@example.com', '$2a$10$hashedpassword6', '+84944556677', 'Emma Wilson', 'RECRUITER', 'LOCAL', TRUE),
('david.lee@example.com', '$2a$10$hashedpassword7', '+84955667788', 'David Lee', 'CANDIDATE', 'LOCAL', TRUE),
('sophia.martin@example.com', '$2a$10$hashedpassword8', '+84966778899', 'Sophia Martin', 'CANDIDATE', 'LOCAL', TRUE),
('michael.nguyen@example.com', '$2a$10$hashedpassword9', '+84977889900', 'Michael Nguyen', 'RECRUITER', 'LOCAL', TRUE),
('linda.tran@example.com', '$2a$10$hashedpassword10', '+84988990011', 'Linda Tran', 'CANDIDATE', 'LOCAL', TRUE);

-- Sample data for user_profile
INSERT INTO user_profile (user_id, profile_image_url, bio, website_url, languages, profile_completed, account_status, last_login_at, login_attempts) VALUES
(1, 'https://example.com/images/john.jpg', 'Software developer with 5 years experience', 'https://johndoe.com', ARRAY['English', 'Vietnamese'], TRUE, 'ACTIVE', NOW(), 0),
(2, 'https://example.com/images/jane.jpg', 'Experienced recruiter specializing in tech', 'https://janesmith.com', ARRAY['English'], TRUE, 'ACTIVE', NOW(), 0),
(3, NULL, 'System administrator', NULL, ARRAY['English'], TRUE, 'ACTIVE', NOW(), 0),
(4, 'https://example.com/images/alice.jpg', 'Frontend developer with React experience', 'https://alicebrown.com', ARRAY['English', 'French'], TRUE, 'ACTIVE', NOW(), 0),
(5, 'https://example.com/images/bob.jpg', 'Backend developer skilled in Python', 'https://bobjohnson.com', ARRAY['English'], TRUE, 'ACTIVE', NOW(), 0),
(6, 'https://example.com/images/emma.jpg', 'HR manager with 10 years experience', 'https://emmawilson.com', ARRAY['English', 'Vietnamese'], TRUE, 'ACTIVE', NOW(), 0),
(7, 'https://example.com/images/david.jpg', 'Full-stack developer', 'https://davidlee.com', ARRAY['English', 'Spanish'], TRUE, 'ACTIVE', NOW(), 0),
(8, 'https://example.com/images/sophia.jpg', 'Data scientist with machine learning expertise', 'https://sophiamartin.com', ARRAY['English'], TRUE, 'ACTIVE', NOW(), 0),
(9, 'https://example.com/images/michael.jpg', 'Tech recruiter for startups', 'https://michaelnguyen.com', ARRAY['English', 'Vietnamese'], TRUE, 'ACTIVE', NOW(), 0),
(10, 'https://example.com/images/linda.jpg', 'DevOps engineer with AWS experience', 'https://lindatran.com', ARRAY['English'], TRUE, 'ACTIVE', NOW(), 0);

-- Sample data for user_verification
INSERT INTO user_verification (user_id, verification_type, verification_code, email_verified, phone_verified, ip_address, user_agent, created_at) VALUES
(1, 'EMAIL', 'abc123', TRUE, FALSE, '192.168.1.1', 'Mozilla/5.0', NOW()),
(2, 'PHONE', 'xyz789', FALSE, TRUE, '192.168.1.2', 'Mozilla/5.0', NOW()),
(4, 'EMAIL', 'def456', TRUE, FALSE, '192.168.1.3', 'Mozilla/5.0', NOW()),
(5, 'PHONE', 'ghi789', FALSE, TRUE, '192.168.1.4', 'Mozilla/5.0', NOW()),
(7, 'EMAIL', 'jkl012', TRUE, FALSE, '192.168.1.5', 'Mozilla/5.0', NOW()),
(8, 'PHONE', 'mno345', FALSE, TRUE, '192.168.1.6', 'Mozilla/5.0', NOW());

-- Sample data for candidate_profiles
INSERT INTO candidate_profiles (user_id, date_of_birth, gender, address, city_id, district_id, education_level, years_experience, current_job_title, current_salary, expected_salary, notice_period_days, willing_to_relocate, remote_work_preference) VALUES
(1, '1990-05-15', 'MALE', '123 Main St', 1, 1, 'BACHELOR', 5, 'Software Engineer', 30000.00, 35000.00, 30, TRUE, 'HYBRID'),
(4, '1992-03-22', 'FEMALE', '456 Oak St', 2, 3, 'MASTER', 3, 'Frontend Developer', 25000.00, 30000.00, 15, FALSE, 'REMOTE'),
(5, '1988-07-10', 'MALE', '789 Pine St', 3, 5, 'BACHELOR', 7, 'Backend Developer', 35000.00, 40000.00, 45, TRUE, 'ONSITE'),
(7, '1993-11-05', 'MALE', '101 Maple St', 4, 6, 'BACHELOR', 4, 'Full-stack Developer', 28000.00, 32000.00, 30, TRUE, 'HYBRID'),
(8, '1991-09-18', 'FEMALE', '202 Cedar St', 5, 7, 'MASTER', 6, 'Data Scientist', 40000.00, 45000.00, 60, FALSE, 'REMOTE'),
(10, '1994-02-25', 'FEMALE', '303 Birch St', 1, 2, 'BACHELOR', 3, 'DevOps Engineer', 27000.00, 31000.00, 30, TRUE, 'HYBRID');

-- Sample data for candidate_skills
INSERT INTO candidate_skills (profile_id, skill_id, proficiency_level, years_experience) VALUES
(1, 1, 'ADVANCED', 5),
(1, 2, 'INTERMEDIATE', 3),
(1, 4, 'ADVANCED', 4),
(2, 2, 'ADVANCED', 3),
(2, 6, 'INTERMEDIATE', 2),
(3, 1, 'ADVANCED', 7),
(3, 4, 'INTERMEDIATE', 5),
(4, 2, 'ADVANCED', 4),
(4, 6, 'ADVANCED', 4),
(5, 1, 'INTERMEDIATE', 3),
(5, 7, 'ADVANCED', 3),
(6, 1, 'INTERMEDIATE', 2),
(6, 7, 'ADVANCED', 3);

-- Sample data for candidate_interests
INSERT INTO candidate_interests (profile_id, interest_name) VALUES
(1, 'Machine Learning'),
(1, 'Web Development'),
(2, 'UI/UX Design'),
(3, 'Cloud Computing'),
(4, 'Web Development'),
(5, 'Data Analysis'),
(6, 'DevOps');

-- Sample data for companies
INSERT INTO companies (company_name, tax_code, description, industry, company_size, address, district_id, website, logo_url, company_status, is_verified) VALUES
('Tech Corp', 'TAX123456', 'Leading technology company', 'Technology', 'LARGE', '456 Tech Rd', 3, 'https://techcorp.com', 'https://techcorp.com/logo.png', 'ACTIVE', TRUE),
('Hiring Solutions', 'TAX789012', 'Recruitment agency', 'HR', 'MEDIUM', '789 Business St', 4, 'https://hiringsolutions.com', 'https://hiringsolutions.com/logo.png', 'ACTIVE', TRUE),
('Innovate Tech', 'TAX345678', 'Innovative software solutions', 'Technology', 'SMALL', '101 Innovation Ave', 1, 'https://innovatetech.com', 'https://innovatetech.com/logo.png', 'ACTIVE', TRUE),
('Data Dynamics', 'TAX901234', 'Data analytics firm', 'Data Science', 'MEDIUM', '202 Data St', 5, 'https://datadynamics.com', 'https://datadynamics.com/logo.png', 'ACTIVE', TRUE);

-- Sample data for recruiter_profiles
INSERT INTO recruiter_profiles (user_id, company_id, position, department) VALUES
(2, 1, 'Senior Recruiter', 'Human Resources'),
(6, 2, 'HR Manager', 'Human Resources'),
(9, 3, 'Tech Recruiter', 'Recruitment');

-- Sample data for jobs (8 jobs)
INSERT INTO jobs (recruiter_id, company_id, title, description, requirements, responsibilities, experience_level, employment_type, salary_min, salary_max, city_id, work_arrangement, min_experience_years, max_experience_years, category, education_requirements, language_requirements, application_deadline, auto_review_threshold, priority_level, featured, status, published_at) VALUES
(2, 1, 'Senior Software Engineer', 'Develop web applications', '5+ years experience in Python', 'Build and maintain web apps', 'SENIOR', 'FULL_TIME', 40000.00, 60000.00, 1, 'HYBRID', 5, 10, 'Software Development', 'Bachelor in Computer Science', ARRAY['English'], '2025-12-31', 0.75, 'HIGH', TRUE, 'OPEN', NOW()),
(2, 1, 'Frontend Developer', 'Create responsive UI', '3+ years in React', 'Develop user interfaces', 'MID_LEVEL', 'FULL_TIME', 30000.00, 45000.00, 2, 'REMOTE', 3, 7, 'Web Development', 'Bachelor in IT', ARRAY['English'], '2025-11-30', 0.70, 'MEDIUM', FALSE, 'OPEN', NOW()),
(6, 2, 'Data Scientist', 'Analyze large datasets', '4+ years in data analysis', 'Build predictive models', 'SENIOR', 'FULL_TIME', 45000.00, 65000.00, 3, 'REMOTE', 4, 8, 'Data Science', 'Master in Data Science', ARRAY['English'], '2025-12-15', 0.80, 'HIGH', TRUE, 'OPEN', NOW()),
(6, 2, 'DevOps Engineer', 'Manage cloud infrastructure', '3+ years in AWS', 'Maintain CI/CD pipelines', 'MID_LEVEL', 'FULL_TIME', 35000.00, 50000.00, 4, 'HYBRID', 3, 6, 'DevOps', 'Bachelor in Computer Engineering', ARRAY['English'], '2025-12-20', 0.70, 'MEDIUM', FALSE, 'OPEN', NOW()),
(9, 3, 'Full-stack Developer', 'Develop full-stack applications', '4+ years in JavaScript and Python', 'End-to-end development', 'MID_LEVEL', 'CONTRACT', 32000.00, 48000.00, 1, 'ONSITE', 4, 8, 'Software Development', 'Bachelor in Computer Science', ARRAY['English', 'Vietnamese'], '2025-11-15', 0.75, 'HIGH', TRUE, 'OPEN', NOW()),
(9, 3, 'Backend Developer', 'Build server-side applications', '5+ years in Java', 'API development', 'SENIOR', 'FULL_TIME', 38000.00, 55000.00, 5, 'HYBRID', 5, 10, 'Software Development', 'Bachelor in IT', ARRAY['English'], '2025-12-31', 0.80, 'MEDIUM', FALSE, 'OPEN', NOW()),
(2, 1, 'Mobile Developer', 'Develop mobile applications', '3+ years in Flutter', 'Create cross-platform apps', 'MID_LEVEL', 'FULL_TIME', 32000.00, 47000.00, 2, 'REMOTE', 3, 6, 'Mobile Development', 'Bachelor in Computer Science', ARRAY['English'], '2025-12-10', 0.70, 'MEDIUM', FALSE, 'OPEN', NOW()),
(6, 2, 'Machine Learning Engineer', 'Develop ML models', '5+ years in ML frameworks', 'Implement AI solutions', 'SENIOR', 'FULL_TIME', 42000.00, 62000.00, 3, 'REMOTE', 5, 10, 'AI/ML', 'Master in AI', ARRAY['English'], '2025-12-25', 0.80, 'HIGH', TRUE, 'OPEN', NOW());

-- Sample data for job_skills
INSERT INTO job_skills (job_id, skill_name, is_required, importance_level, min_years_experience) VALUES
(1, 'Python', TRUE, 'HIGH', 5),
(1, 'JavaScript', FALSE, 'MEDIUM', 2),
(2, 'React', TRUE, 'HIGH', 3),
(2, 'JavaScript', TRUE, 'HIGH', 3),
(3, 'Python', TRUE, 'HIGH', 4),
(3, 'SQL', FALSE, 'MEDIUM', 2),
(4, 'AWS', TRUE, 'HIGH', 3),
(4, 'Python', FALSE, 'MEDIUM', 2),
(5, 'JavaScript', TRUE, 'HIGH', 4),
(5, 'Python', TRUE, 'HIGH', 4),
(6, 'Java', TRUE, 'HIGH', 5),
(6, 'SQL', FALSE, 'MEDIUM', 3),
(7, 'Flutter', TRUE, 'HIGH', 3),
(7, 'JavaScript', FALSE, 'MEDIUM', 2),
(8, 'Python', TRUE, 'HIGH', 5),
(8, 'TensorFlow', FALSE, 'MEDIUM', 3);

-- Sample data for candidate_cvs
INSERT INTO candidate_cvs (candidate_id, cv_name, file_name, file_path, file_size, file_type, is_primary, parsing_status, language, cv_version) VALUES
(1, 'John Doe CV', 'john_doe_cv.pdf', '/uploads/cvs/john_doe_cv.pdf', 102400, 'PDF', TRUE, 'COMPLETED', 'en', 1),
(4, 'Alice Brown CV', 'alice_brown_cv.pdf', '/uploads/cvs/alice_brown_cv.pdf', 112640, 'PDF', TRUE, 'COMPLETED', 'en', 1),
(5, 'Bob Johnson CV', 'bob_johnson_cv.pdf', '/uploads/cvs/bob_johnson_cv.pdf', 98765, 'PDF', TRUE, 'COMPLETED', 'en', 1),
(7, 'David Lee CV', 'david_lee_cv.pdf', '/uploads/cvs/david_lee_cv.pdf', 104857, 'PDF', TRUE, 'COMPLETED', 'en', 1),
(8, 'Sophia Martin CV', 'sophia_martin_cv.pdf', '/uploads/cvs/sophia_martin_cv.pdf', 115200, 'PDF', TRUE, 'COMPLETED', 'en', 1),
(10, 'Linda Tran CV', 'linda_tran_cv.pdf', '/uploads/cvs/linda_tran_cv.pdf', 102400, 'PDF', TRUE, 'COMPLETED', 'en', 1);

-- Sample data for cv_content
INSERT INTO cv_content (cv_id, raw_text, parsed_content) VALUES
(1, 'John Doe Software Engineer...', '{"o_ten": "John Doe", "ngay_sinh": "1990-01-01", "gioi_tinh": "Nam", "email": "john.doe@example.com", "so_dien_thoai": "0912 345 111", "dia_chi": "123 Le Loi, District 1, HCMC", "vi_tri_ung_tuyen": "Senior Software Engineer", "mo_ta_ban_than": "Tôi là một kỹ sư phần mềm với hơn 10 năm kinh nghiệm phát triển ứng dụng web hiệu suất cao.", "kinh_nghiem_lam_viec": [{"vi_tri": "Senior Software Engineer", "cong_ty": "Tech Corp", "thoi_gian": "01/2015 - nay", "mo_ta": "Xây dựng và triển khai các hệ thống backend phức tạp."}], "hoc_van": [{"truong": "Đại học Bách Khoa", "nganh": "Kỹ thuật phần mềm", "trinh_do": "Cử nhân", "thoi_gian": "2006 - 2010", "xep_loai": "Khá"}], "ky_nang": ["Python", "Django", "AWS"], "nguoi_tham_chieu": {"ten": "Ms. Lan", "chuc_vu": "Manager", "cong_ty": "Tech Corp", "email": "lan@techcorp.com"}}'),
(2, 'Alice Brown Frontend Developer...', '{"o_ten": "Alice Brown", "ngay_sinh": "1992-03-22", "gioi_tinh": "Nữ", "email": "alice.brown@example.com", "so_dien_thoai": "0912 345 222", "dia_chi": "456 Nguyen Trai, District 5, HCMC", "vi_tri_ung_tuyen": "Frontend Developer", "mo_ta_ban_than": "Tôi có kinh nghiệm thiết kế giao diện người dùng tương tác cao và tối ưu hóa hiệu năng.", "kinh_nghiem_lam_viec": [{"vi_tri": "Frontend Developer", "cong_ty": "Innovate Tech", "thoi_gian": "06/2018 - nay", "mo_ta": "Phát triển các giao diện ReactJS cho hệ thống web"}], "hoc_van": [{"truong": "Đại học Khoa học Tự nhiên", "nganh": "Công nghệ thông tin", "trinh_do": "Cử nhân", "thoi_gian": "2010 - 2014", "xep_loai": "Giỏi"}], "ky_nang": ["HTML", "CSS", "JavaScript", "React"], "nguoi_tham_chieu": {"ten": "Mr. Huy", "chuc_vu": "Tech Lead", "cong_ty": "Innovate Tech", "email": "huy@innovate.vn"}}'),
(3, 'Bob Johnson Backend Developer...', '{"o_ten": "Bob Johnson", "ngay_sinh": "1988-07-10", "gioi_tinh": "Nam", "email": "bob.johnson@example.com", "so_dien_thoai": "0912 345 333", "dia_chi": "789 Le Thanh Ton, District 1, HCMC", "vi_tri_ung_tuyen": "Backend Developer", "mo_ta_ban_than": "Chuyên xây dựng API hiệu quả và bảo trì hệ thống backend quy mô lớn.", "kinh_nghiem_lam_viec": [{"vi_tri": "Backend Developer", "cong_ty": "Data Dynamics", "thoi_gian": "2016 - nay", "mo_ta": "Xây dựng API RESTful và quản lý cơ sở dữ liệu PostgreSQL."}], "hoc_van": [{"truong": "Đại học CNTT", "nganh": "Khoa học máy tính", "trinh_do": "Thạc sĩ", "thoi_gian": "2012 - 2015", "xep_loai": "Khá"}], "ky_nang": ["Java", "Spring Boot", "PostgreSQL"], "nguoi_tham_chieu": {"ten": "Mr. An", "chuc_vu": "CTO", "cong_ty": "Data Dynamics", "email": "an@datady.vn"}}'),
(4, 'David Lee Full-stack Developer...', '{"o_ten": "David Lee", "ngay_sinh": "1993-11-05", "gioi_tinh": "Nam", "email": "david.lee@example.com", "so_dien_thoai": "0912 345 444", "dia_chi": "101 Phan Dang Luu, Binh Thanh, HCMC", "vi_tri_ung_tuyen": "Full-stack Developer", "mo_ta_ban_than": "Tôi là một kỹ sư phần mềm đa năng với kinh nghiệm cả frontend và backend.", "kinh_nghiem_lam_viec": [{"vi_tri": "Full-stack Developer", "cong_ty": "Hiring Solutions", "thoi_gian": "2019 - nay", "mo_ta": "Phát triển ứng dụng nội bộ sử dụng Node.js và Vue.js"}], "hoc_van": [{"truong": "Đại học FPT", "nganh": "Công nghệ phần mềm", "trinh_do": "Cử nhân", "thoi_gian": "2010 - 2014", "xep_loai": "Khá"}], "ky_nang": ["Node.js", "Vue.js", "MongoDB"], "nguoi_tham_chieu": {"ten": "Ms. Trang", "chuc_vu": "Quản lý kỹ thuật", "cong_ty": "Hiring Solutions", "email": "trang@hiringsolutions.vn"}}'),
(5, 'Sophia Martin Data Scientist...', '{"o_ten": "Sophia Martin", "ngay_sinh": "1991-09-18", "gioi_tinh": "Nữ", "email": "sophia.martin@example.com", "so_dien_thoai": "0912 345 555", "dia_chi": "202 Tran Hung Dao, District 1, HCMC", "vi_tri_ung_tuyen": "Data Scientist", "mo_ta_ban_than": "Tôi chuyên phân tích dữ liệu lớn và phát triển mô hình học máy.", "kinh_nghiem_lam_viec": [{"vi_tri": "Data Scientist", "cong_ty": "Data Dynamics", "thoi_gian": "2017 - nay", "mo_ta": "Xây dựng mô hình ML phân loại dữ liệu và dự đoán xu hướng"}], "hoc_van": [{"truong": "Đại học Quốc gia", "nganh": "Khoa học dữ liệu", "trinh_do": "Thạc sĩ", "thoi_gian": "2014 - 2016", "xep_loai": "Xuất sắc"}], "ky_nang": ["Python", "Pandas", "Scikit-learn", "SQL"], "nguoi_tham_chieu": {"ten": "Mr. Bao", "chuc_vu": "Data Manager", "cong_ty": "Data Dynamics", "email": "bao@dd.vn"}}'),
(6, 'Linda Tran DevOps Engineer...', '{"o_ten": "Linda Tran", "ngay_sinh": "1994-02-25", "gioi_tinh": "Nữ", "email": "linda.tran@example.com", "so_dien_thoai": "0912 345 666", "dia_chi": "303 Nguyen Dinh Chieu, District 3, HCMC", "vi_tri_ung_tuyen": "DevOps Engineer", "mo_ta_ban_than": "Tôi có kinh nghiệm triển khai hệ thống CI/CD và quản lý hạ tầng cloud.", "kinh_nghiem_lam_viec": [{"vi_tri": "DevOps Engineer", "cong_ty": "Innovate Tech", "thoi_gian": "2020 - nay", "mo_ta": "Thiết lập Jenkins pipelines, quản lý AWS và Docker"}], "hoc_van": [{"truong": "Đại học CNTT", "nganh": "Hệ thống thông tin", "trinh_do": "Cử nhân", "thoi_gian": "2012 - 2016", "xep_loai": "Giỏi"}], "ky_nang": ["AWS", "Docker", "Jenkins", "Linux"], "nguoi_tham_chieu": {"ten": "Ms. Hoa", "chuc_vu": "Lead DevOps", "cong_ty": "Innovate Tech", "email": "hoa@innovate.vn"}}');

-- Sample data for applications
INSERT INTO applications (job_id, candidate_id, cv_id, cover_letter, ai_match_score, ai_analysis, priority, current_status, submitted_at) VALUES
(1, 1, 1, 'Dear Hiring Manager...', 0.85, '{"match_confidence": 0.85}', 'HIGH', 'SUBMITTED', NOW()),
(2, 4, 2, 'Dear Recruiter...', 0.88, '{"match_confidence": 0.88}', 'MEDIUM', 'SUBMITTED', NOW()),
(3, 8, 5, 'Dear HR Manager...', 0.90, '{"match_confidence": 0.90}', 'HIGH', 'SUBMITTED', NOW()),
(4, 10, 6, 'Dear Hiring Team...', 0.87, '{"match_confidence": 0.87}', 'MEDIUM', 'SUBMITTED', NOW()),
(5, 7, 4, 'Dear Recruiter...', 0.86, '{"match_confidence": 0.86}', 'HIGH', 'SUBMITTED', NOW()),
(6, 5, 3, 'Dear Hiring Manager...', 0.89, '{"match_confidence": 0.89}', 'MEDIUM', 'SUBMITTED', NOW()),
(7, 1, 1, 'Dear Hiring Manager...', 0.84, '{"match_confidence": 0.84}', 'MEDIUM', 'SUBMITTED', NOW()),
(8, 8, 5, 'Dear HR Manager...', 0.91, '{"match_confidence": 0.91}', 'HIGH', 'SUBMITTED', NOW());

-- Sample data for application_status_history
INSERT INTO application_status_history (application_id, from_status, to_status, changed_by, change_reason, automated) VALUES
(1, NULL, 'SUBMITTED', 2, 'Initial application submission', TRUE),
(2, NULL, 'SUBMITTED', 2, 'Initial application submission', TRUE),
(3, NULL, 'SUBMITTED', 6, 'Initial application submission', TRUE),
(4, NULL, 'SUBMITTED', 6, 'Initial application submission', TRUE),
(5, NULL, 'SUBMITTED', 9, 'Initial application submission', TRUE),
(6, NULL, 'SUBMITTED', 9, 'Initial application submission', TRUE),
(7, NULL, 'SUBMITTED', 2, 'Initial application submission', TRUE),
(8, NULL, 'SUBMITTED', 6, 'Initial application submission', TRUE);

-- Sample data for job_tests
INSERT INTO job_tests (job_id, test_name, test_type, difficulty_level, duration_minutes, passing_score, description, is_active) VALUES
(1, 'Python Coding Test', 'CODING', 'MEDIUM', 60, 70.00, 'Test Python programming skills', TRUE),
(2, 'React Coding Test', 'CODING', 'MEDIUM', 45, 65.00, 'Test React development skills', TRUE),
(3, 'Data Analysis Test', 'ANALYTICAL', 'HARD', 90, 75.00, 'Test data science skills', TRUE),
(4, 'AWS Infrastructure Test', 'TECHNICAL', 'MEDIUM', 60, 70.00, 'Test AWS skills', TRUE);

-- Sample data for test_questions
INSERT INTO test_questions (test_id, question_text, question_type, points, time_limit_seconds, order_index, explanation, required) VALUES
(1, 'Write a Python function to reverse a string', 'CODE', 20.00, 900, 1, 'Should return reversed string', TRUE),
(2, 'Create a React component for a button', 'CODE', 15.00, 600, 1, 'Should render a clickable button', TRUE),
(3, 'Analyze a dataset and identify trends', 'ANALYTICAL', 25.00, 1200, 1, 'Should provide accurate analysis', TRUE),
(4, 'Configure an AWS Lambda function', 'TECHNICAL', 20.00, 900, 1, 'Should deploy a working function', TRUE);

-- Sample data for question_options
INSERT INTO question_options (question_id, option_text, is_correct, order_index) VALUES
(1, 'def reverse(s): return s[::-1]', TRUE, 1),
(1, 'def reverse(s): return s.reverse()', FALSE, 2),
(2, 'function Button() { return <button>Click me</button> }', TRUE, 1),
(2, 'function Button() { return <div>Click me</div> }', FALSE, 2);

-- Sample data for test_results
INSERT INTO test_results (application_id, test_id, start_time, submit_time, total_score, percentage, status, passed, time_taken_seconds, graded_by, graded_at, feedback) VALUES
(1, 1, NOW(), NOW() + INTERVAL '30 minutes', 85.00, 85.00, 'COMPLETED', TRUE, 1800, 2, NOW(), 'Good coding skills'),
(2, 2, NOW(), NOW() + INTERVAL '25 minutes', 80.00, 80.00, 'COMPLETED', TRUE, 1500, 2, NOW(), 'Solid React skills'),
(3, 3, NOW(), NOW() + INTERVAL '60 minutes', 90.00, 90.00, 'COMPLETED', TRUE, 3600, 6, NOW(), 'Excellent analysis'),
(4, 4, NOW(), NOW() + INTERVAL '40 minutes', 75.00, 75.00, 'COMPLETED', TRUE, 2400, 6, NOW(), 'Good AWS knowledge');

-- Sample data for question_answers
INSERT INTO question_answers (result_id, question_id, answer_text, is_correct, points_earned, time_taken_seconds) VALUES
(1, 1, 'def reverse(s): return s[::-1]', TRUE, 20.00, 600),
(2, 2, 'function Button() { return <button>Click me</button> }', TRUE, 15.00, 500),
(3, 3, 'Identified positive correlation in dataset', TRUE, 25.00, 900),
(4, 4, 'Configured Lambda with correct triggers', TRUE, 20.00, 700);

-- Sample data for saved_jobs
INSERT INTO saved_jobs (candidate_id, job_id, saved_at) VALUES
(1, 1, NOW()),
(4, 2, NOW()),
(8, 3, NOW()),
(10, 4, NOW()),
(7, 5, NOW()),
(5, 6, NOW()),
(1, 7, NOW()),
(8, 8, NOW());

-- Sample data for email_queue
INSERT INTO email_queue (to_email, subject, template_name, template_data, status, scheduled_at, email_type) VALUES
('john.doe@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "John Doe"}', 'PENDING', NOW(), 'SYSTEM'),
('alice.brown@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "Alice Brown"}', 'PENDING', NOW(), 'SYSTEM'),
('bob.johnson@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "Bob Johnson"}', 'PENDING', NOW(), 'SYSTEM'),
('david.lee@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "David Lee"}', 'PENDING', NOW(), 'SYSTEM'),
('sophia.martin@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "Sophia Martin"}', 'PENDING', NOW(), 'SYSTEM'),
('linda.tran@example.com', 'Welcome to Our Platform', 'welcome_email', '{"name": "Linda Tran"}', 'PENDING', NOW(), 'SYSTEM');

-- Sample data for notifications
INSERT INTO notifications (user_id, title, message, type, priority, is_read) VALUES
(1, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'HIGH', FALSE),
(4, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'MEDIUM', FALSE),
(8, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'HIGH', FALSE),
(10, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'MEDIUM', FALSE),
(7, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'HIGH', FALSE),
(5, 'New Job Match', 'A new job matches your profile', 'JOB_MATCH', 'MEDIUM', FALSE);

-- Sample data for chat_sessions
INSERT INTO chat_sessions (user_id, platform, ip_address, user_agent, language) VALUES
(1, 'WEB', '192.168.1.1', 'Mozilla/5.0', 'en'),
(4, 'WEB', '192.168.1.3', 'Mozilla/5.0', 'en'),
(5, 'WEB', '192.168.1.4', 'Mozilla/5.0', 'en'),
(7, 'WEB', '192.168.1.5', 'Mozilla/5.0', 'en'),
(8, 'WEB', '192.168.1.6', 'Mozilla/5.0', 'en'),
(10, 'WEB', '192.168.1.7', 'Mozilla/5.0', 'en');

-- Sample data for chat_messages
INSERT INTO chat_messages (session_id, sender_type, sender_id, message_text, message_type, intent, confidence, response_time_ms) VALUES
(1, 'USER', 1, 'Hello, how can I find jobs?', 'TEXT', 'JOB_SEARCH', 0.95, 200),
(2, 'USER', 4, 'What are the latest frontend jobs?', 'TEXT', 'JOB_SEARCH', 0.90, 180),
(3, 'USER', 5, 'How to apply for backend roles?', 'TEXT', 'JOB_APPLICATION', 0.92, 190),
(4, 'USER', 7, 'Find full-stack jobs', 'TEXT', 'JOB_SEARCH', 0.89, 210),
(5, 'USER', 8, 'Data science job opportunities?', 'TEXT', 'JOB_SEARCH', 0.94, 200),
(6, 'USER', 10, 'DevOps job listings', 'TEXT', 'JOB_SEARCH', 0.91, 195);

-- Sample data for chat_feedback
INSERT INTO chat_feedback (session_id, user_id, rating, comment) VALUES
(1, 1, 4, 'Helpful response'),
(2, 4, 5, 'Very useful'),
(3, 5, 3, 'Could be clearer'),
(4, 7, 4, 'Good information'),
(5, 8, 5, 'Excellent support'),
(6, 10, 4, 'Helpful advice');

-- Sample data for audit_logs
INSERT INTO audit_logs (user_id, action, entity_type, entity_id, old_values, new_values, ip_address, user_agent, session_id, success) VALUES
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 1, '{}', '{"bio": "Updated bio"}', '192.168.1.1', 'Mozilla/5.0', 'session123', TRUE),
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 4, '{}', '{"bio": "Updated bio"}', '192.168.1.2', 'Mozilla/5.0', 'session124', TRUE),
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 5, '{}', '{"bio": "Updated bio"}', '192.168.1.3', 'Mozilla/5.0', 'session125', TRUE),
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 7, '{}', '{"bio": "Updated bio"}', '192.168.1.4', 'Mozilla/5.0', 'session126', TRUE),
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 8, '{}', '{"bio": "Updated bio"}', '192.168.1.5', 'Mozilla/5.0', 'session127', TRUE),
(3, 'UPDATE_PROFILE', 'USER_PROFILE', 10, '{}', '{"bio": "Updated bio"}', '192.168.1.6', 'Mozilla/5.0', 'session128', TRUE);

-- Sample data for security_events
INSERT INTO security_events (user_id, event_type, severity, description, ip_address, location, user_agent, metadata) VALUES
(1, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.1', 'Hanoi', 'Mozilla/5.0', '{}'),
(4, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.3', 'Ho Chi Minh City', 'Mozilla/5.0', '{}'),
(5, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.4', 'Da Nang', 'Mozilla/5.0', '{}'),
(7, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.5', 'Hai Phong', 'Mozilla/5.0', '{}'),
(8, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.6', 'Can Tho', 'Mozilla/5.0', '{}'),
(10, 'LOGIN_ATTEMPT', 'LOW', 'Successful login', '192.168.1.7', 'Hanoi', 'Mozilla/5.0', '{}');