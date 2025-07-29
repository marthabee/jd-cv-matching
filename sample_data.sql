-- USERS & PROFILE
INSERT INTO users (user_id, email, full_name, role) VALUES
  (1, 'candidate@example.com', 'Nguyen Van A', 'CANDIDATE')
ON CONFLICT DO NOTHING;

INSERT INTO candidate_profiles (profile_id, user_id, education_level, years_experience, current_job_title)
VALUES (1, 1, 'Bachelor', 5, 'Kỹ sư hệ thống')
ON CONFLICT DO NOTHING;

-- SKILLS & CANDIDATE SKILLS
INSERT INTO skills (skill_id, skill_name) VALUES
  (1, 'Python'), (2, 'Docker'), (3, 'Kubernetes'), (4, 'SQL'), (5, 'Quản lý dự án')
ON CONFLICT DO NOTHING;

INSERT INTO candidate_skills (profile_id, skill_id, proficiency_level, years_experience) VALUES
  (1, 1, 'ADVANCED', 3),
  (1, 2, 'INTERMEDIATE', 2),
  (1, 5, 'ADVANCED', 5)
ON CONFLICT DO NOTHING;

-- CVS & PARSED CONTENT
INSERT INTO candidate_cvs (cv_id, candidate_id, cv_name, is_primary)
VALUES (1001, 1, 'CV Nguyen Van A', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO cv_content (cv_id, parsed_content) VALUES (
  1001,
  '{
    "mo_ta_ban_than": "Tôi là kỹ sư hệ thống có kinh nghiệm về triển khai dịch vụ cloud.",
    "ky_nang": ["Python", "AWS", "Docker"],
    "kinh_nghiem_lam_viec": [
      {
        "vi_tri": "DevOps Engineer",
        "cong_ty": "ABC Cloud",
        "thoi_gian": "2019-2023",
        "mo_ta": "Quản lý CI/CD pipeline và hạ tầng Docker"
      }
    ],
    "hoc_van": [
      {
        "truong": "Đại học Bách Khoa",
        "nganh": "Công nghệ thông tin",
        "trinh_do": "Cử nhân"
      }
    ],
    "du_an": [
      {
        "ten_du_an": "Triển khai hệ thống giám sát",
        "vai_tro": "Kỹ sư chính",
        "mo_ta": "Xây dựng hệ thống sử dụng Prometheus và Grafana"
      }
    ]
  }'::jsonb
)
ON CONFLICT DO NOTHING;

-- JOB & COMPANY
INSERT INTO companies (company_id, company_name)
VALUES (1, 'Công ty AI Việt Nam')
ON CONFLICT DO NOTHING;

INSERT INTO jobs (job_id, recruiter_id, company_id, title, description, requirements) VALUES (
  101, 1, 1,
  'DevOps Engineer',
  'Chúng tôi tìm kiếm ứng viên triển khai và giám sát hệ thống',
  'Thành thạo Docker, CI/CD, có kinh nghiệm DevOps là lợi thế'
)
ON CONFLICT DO NOTHING;
