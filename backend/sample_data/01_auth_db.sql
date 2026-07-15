-- ==============================================================================
-- DATABASE: auth_db
-- SERVICE: auth-service
-- DESCRIPTION: Schema definition and rich sample data for Authentication & Authorization
-- ==============================================================================

-- 1. CREATE TABLES (IF NOT EXISTS) TO ALLOW STANDALONE OR PRE-BOOT INITIALIZATION
CREATE TABLE IF NOT EXISTS roles (
    role_id BIGSERIAL PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL UNIQUE,
    role_code VARCHAR(255) NOT NULL UNIQUE,
    role_description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(255) NOT NULL UNIQUE,
    status BOOLEAN NOT NULL DEFAULT true,
    password VARCHAR(255) NOT NULL,
    failed_login_attempts INTEGER DEFAULT 0,
    lock_time TIMESTAMP,
    last_password_change_date TIMESTAMP,
    last_login_date TIMESTAMP,
    role_id BIGINT NOT NULL REFERENCES roles(role_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_addresses (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    district VARCHAR(255) NOT NULL,
    ward VARCHAR(255) NOT NULL,
    street VARCHAR(255) NOT NULL,
    is_default BOOLEAN DEFAULT false
);

CREATE TABLE IF NOT EXISTS system_settings (
    setting_key VARCHAR(255) PRIMARY KEY,
    setting_value TEXT,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS valid_refresh_tokens (
    id BIGSERIAL PRIMARY KEY,
    jwt_id VARCHAR(255) NOT NULL UNIQUE,
    expired_time TIMESTAMP NOT NULL,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    revoked BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS password_reset_token (
    id BIGSERIAL PRIMARY KEY,
    token VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expiry_date TIMESTAMP NOT NULL,
    created_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT false
);

-- 2. INSERT ROLES
INSERT INTO roles (role_id, role_name, role_code, role_description) VALUES
(1, 'Administrator', 'ADMIN', 'Quản trị viên hệ thống với toàn quyền kiểm soát') ON CONFLICT (role_id) DO UPDATE SET role_name = EXCLUDED.role_name, role_code = EXCLUDED.role_code, role_description = EXCLUDED.role_description;

INSERT INTO roles (role_id, role_name, role_code, role_description) VALUES
(2, 'Customer', 'USER', 'Khách hàng mua sắm trực tuyến') ON CONFLICT (role_id) DO UPDATE SET role_name = EXCLUDED.role_name, role_code = EXCLUDED.role_code, role_description = EXCLUDED.role_description;

INSERT INTO roles (role_id, role_name, role_code, role_description) VALUES
(3, 'Staff', 'STAFF', 'Nhân viên xử lý đơn hàng và chăm sóc khách hàng') ON CONFLICT (role_id) DO UPDATE SET role_name = EXCLUDED.role_name, role_code = EXCLUDED.role_code, role_description = EXCLUDED.role_description;

INSERT INTO roles (role_id, role_name, role_code, role_description) VALUES
(4, 'Manager', 'MANAGER', 'Quản lý cửa hàng, quản lý danh mục và nhân sự') ON CONFLICT (role_id) DO UPDATE SET role_name = EXCLUDED.role_name, role_code = EXCLUDED.role_code, role_description = EXCLUDED.role_description;

SELECT setval('roles_role_id_seq', (SELECT MAX(role_id) FROM roles));

-- 3. INSERT USERS
-- Lưu ý: Mật khẩu mặc định cho tất cả các user mẫu là '123456' (BCrypt hash strength 10: $2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.)
INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(1, 'Nguyễn Văn Quản Trị', 'admin@sportshop.vn', '0901234567', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_TIMESTAMP - INTERVAL '1 hour', 1, CURRENT_TIMESTAMP - INTERVAL '30 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(2, 'Trần Thị Quản Lý', 'manager@sportshop.vn', '0902345678', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_TIMESTAMP - INTERVAL '3 hours', 4, CURRENT_TIMESTAMP - INTERVAL '28 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(3, 'Lê Hoàng Nhân Viên', 'staff1@sportshop.vn', '0903456789', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 3, CURRENT_TIMESTAMP - INTERVAL '20 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(4, 'Phạm Minh Giao Hàng', 'staff2@sportshop.vn', '0904567890', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '12 days', CURRENT_TIMESTAMP - INTERVAL '2 hours', 3, CURRENT_TIMESTAMP - INTERVAL '18 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(5, 'Đặng Quang Khách', 'customer1@sportshop.vn', '0911223344', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '8 days', CURRENT_TIMESTAMP - INTERVAL '5 hours', 2, CURRENT_TIMESTAMP - INTERVAL '15 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(6, 'Hoàng Mai Thảo', 'customer2@sportshop.vn', '0912334455', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '1 day', 2, CURRENT_TIMESTAMP - INTERVAL '10 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

INSERT INTO users (id, full_name, email, phone_number, status, password, failed_login_attempts, last_password_change_date, last_login_date, role_id, created_at)
VALUES 
(7, 'Vũ Đức Anh', 'customer3@sportshop.vn', '0913445566', true, '$2a$10$eACCYoNOHEqXve8aIWT8Nu3PkMXWBaOxJ9aORUYzfmqEQVWTRfF3.', 0, CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '4 hours', 2, CURRENT_TIMESTAMP - INTERVAL '5 days')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name, email = EXCLUDED.email, role_id = EXCLUDED.role_id;

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- 4. INSERT USER ADDRESSES
INSERT INTO user_addresses (id, user_id, recipient_name, phone_number, city, district, ward, street, is_default)
VALUES 
(1, 5, 'Đặng Quang Khách', '0911223344', 'Hồ Chí Minh', 'Quận 1', 'Phường Bến Nghé', '123 Nguyễn Huệ', true),
(2, 5, 'Đặng Quang Khách (Cơ quan)', '0911223344', 'Hồ Chí Minh', 'Quận 3', 'Phường Võ Thị Sáu', '456 Điện Biên Phủ', false),
(3, 6, 'Hoàng Mai Thảo', '0912334455', 'Hà Nội', 'Quận Cầu Giấy', 'Phường Dịch Vọng', '45 Xuân Thủy', true),
(4, 7, 'Vũ Đức Anh', '0913445566', 'Đà Nẵng', 'Quận Hải Châu', 'Phường Thạch Thang', '88 Bạch Đằng', true)
ON CONFLICT (id) DO UPDATE SET recipient_name = EXCLUDED.recipient_name, street = EXCLUDED.street;

SELECT setval('user_addresses_id_seq', (SELECT MAX(id) FROM user_addresses));

-- 5. INSERT SYSTEM SETTINGS
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('STORE_NAME', 'Sport Swear Shop - Team 6 Official', 'Tên chính thức của cửa hàng thể thao'),
('STORE_HOTLINE', '1900-6868', 'Hotline chăm sóc khách hàng 24/7'),
('STORE_EMAIL', 'support@sportshop.vn', 'Email hỗ trợ kỹ thuật và đơn hàng'),
('FREE_SHIPPING_THRESHOLD', '500000', 'Đơn hàng tối thiểu để được miễn phí vận chuyển (VNĐ)'),
('SHIPPING_FEE_DEFAULT', '30000', 'Phí giao hàng tiêu chuẩn trên toàn quốc (VNĐ)'),
('MAINTENANCE_MODE', 'false', 'Bật/tắt chế độ bảo trì toàn hệ thống'),
('MAX_LOGIN_ATTEMPTS', '5', 'Số lần đăng nhập sai tối đa trước khi khóa tài khoản tạm thời')
ON CONFLICT (setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value, description = EXCLUDED.description;
