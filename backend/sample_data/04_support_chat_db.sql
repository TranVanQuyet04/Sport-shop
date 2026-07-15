-- ==============================================================================
-- DATABASE: support_chat_db
-- SERVICE: support-chat-service
-- DESCRIPTION: Schema definition and rich sample data for Chat Rooms, Chat Messages & Product References
-- ==============================================================================

-- 1. CREATE TABLES IF NOT EXISTS
CREATE TABLE IF NOT EXISTS chat_rooms (
    id BIGSERIAL PRIMARY KEY,
    customer_name VARCHAR(255),
    admin_name VARCHAR(255),
    last_message_at TIMESTAMP,
    has_unread BOOLEAN DEFAULT false,
    type VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS chat_messages (
    id BIGSERIAL PRIMARY KEY,
    room_id BIGINT REFERENCES chat_rooms(id) ON DELETE CASCADE,
    content TEXT,
    sender VARCHAR(255),
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    type VARCHAR(255),
    file_url VARCHAR(255)
);

-- Tạo các bảng tham chiếu sản phẩm trong support_chat_db để hỗ trợ tính năng tư vấn/gợi ý sản phẩm khi chat
CREATE TABLE IF NOT EXISTS brands (
    id BIGSERIAL PRIMARY KEY,
    brand_name VARCHAR(255),
    slug VARCHAR(255) UNIQUE,
    logo VARCHAR(1000),
    banner VARCHAR(1000),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(255) UNIQUE,
    description VARCHAR(255),
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS sports (
    id BIGSERIAL PRIMARY KEY,
    sport_name VARCHAR(255) UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(255),
    description TEXT,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    brand_id BIGINT REFERENCES brands(id) ON DELETE SET NULL,
    sport_id BIGINT REFERENCES sports(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS product_variants (
    id BIGSERIAL PRIMARY KEY,
    sku VARCHAR(255),
    color VARCHAR(255),
    size VARCHAR(255),
    price NUMERIC(38,2),
    stock_quantity INTEGER,
    product_id BIGINT REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    image_url VARCHAR(255),
    is_primary BOOLEAN DEFAULT false,
    variant_id BIGINT REFERENCES product_variants(id) ON DELETE CASCADE
);

-- 2. INSERT CHAT ROOMS
INSERT INTO chat_rooms (id, customer_name, admin_name, last_message_at, has_unread, type) VALUES
(1, 'Đặng Quang Khách (Khách hàng VIP)', 'Nguyễn Văn Quản Trị (Admin)', CURRENT_TIMESTAMP - INTERVAL '15 minutes', false, 'ADMIN_SUPPORT'),
(2, 'Hoàng Mai Thảo (Khách hàng)', 'AI Assistant SportShop', CURRENT_TIMESTAMP - INTERVAL '5 minutes', false, 'AI_SUPPORT'),
(3, 'Vũ Đức Anh (Khách hàng)', 'Lê Hoàng Nhân Viên (Staff)', CURRENT_TIMESTAMP - INTERVAL '2 hours', true, 'ADMIN_SUPPORT'),
(4, 'Khách Vãng Lai #9821', 'AI Assistant SportShop', CURRENT_TIMESTAMP - INTERVAL '1 day', false, 'AI_SUPPORT')
ON CONFLICT (id) DO UPDATE SET customer_name = EXCLUDED.customer_name, last_message_at = EXCLUDED.last_message_at, has_unread = EXCLUDED.has_unread;

SELECT setval('chat_rooms_id_seq', (SELECT MAX(id) FROM chat_rooms));

-- 3. INSERT CHAT MESSAGES
INSERT INTO chat_messages (id, room_id, content, sender, sent_at, type, file_url) VALUES
-- Room 1 (Admin Support - Đặng Quang Khách)
(1, 1, 'Xin chào shop, cho mình hỏi mẫu Giày Chạy Bộ Nike Air Zoom Pegasus 40 size 42 màu Đen Trắng bên mình hiện tại còn hàng ở chi nhánh TP.HCM không ạ?', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '25 minutes', 'TEXT', NULL),
(2, 1, 'Chào bạn Khách ạ! Hiện tại mẫu giày Nike Air Zoom Pegasus 40 size 42 bên shop đang sẵn 15 đôi tại kho chính TP.HCM ạ. Bạn có thể đặt trực tiếp qua giỏ hàng nhé!', 'ADMIN', CURRENT_TIMESTAMP - INTERVAL '20 minutes', 'TEXT', NULL),
(3, 1, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 'ADMIN', CURRENT_TIMESTAMP - INTERVAL '19 minutes', 'IMAGE', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff'),
(4, 1, 'Cảm ơn shop nhé, mình vừa đặt đơn hàng thanh toán VNPAY rồi, shop đóng gói gửi sớm giúp mình nhé!', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '15 minutes', 'TEXT', NULL),

-- Room 2 (AI Support - Hoàng Mai Thảo)
(5, 2, 'Tôi muốn nhờ tư vấn chọn size cho giày bóng đá Adidas Predator Accuracy.3 TF, chân tôi dài khoảng 26cm.', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '10 minutes', 'TEXT', NULL),
(6, 2, 'Chân tôi hơi bè ngang thì có bị bó đau không?', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '8 minutes', 'TEXT', NULL),
(7, 2, 'Chào bạn! Với chiều dài bàn chân 26cm và form chân có độ bè ngang, AI Assistant khuyên bạn nên chọn Size 41.5 hoặc 42 đối với dòng giày Adidas Predator Accuracy.3 TF. Chất liệu da tổng hợp mềm mại có độ đàn hồi tốt và sẽ co dãn nhẹ theo form chân sau 1-2 trận đấu giúp ôm chân cực kỳ thoải mái và chính xác ạ.', 'AI', CURRENT_TIMESTAMP - INTERVAL '5 minutes', 'TEXT', NULL),

-- Room 3 (Admin Support - Vũ Đức Anh - Có tin nhắn chưa đọc)
(8, 3, 'Shop ơi cho mình hỏi đơn hàng #4 của mình đặt áo cầu lông Li-Ning khi nào thì được giao đi ạ?', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'TEXT', NULL),

-- Room 4 (AI Support - Khách Vãng Lai)
(9, 4, 'Shop có chương trình khuyến mãi nào cho mùa hè này không?', 'CUSTOMER', CURRENT_TIMESTAMP - INTERVAL '1 day', 'TEXT', NULL),
(10, 4, 'Chào bạn! Hiện tại SportSwearShop đang diễn ra chương trình Sale Khủng Mid-Year giảm giá đến 50% cho các mẫu giày chạy bộ và bộ sưu tập Summer Energy 2026. Bạn có thể truy cập mục Khuyến Mãi trên trang chủ để xem chi tiết nhé!', 'AI', CURRENT_TIMESTAMP - INTERVAL '1 day' + INTERVAL '1 minute', 'TEXT', NULL)
ON CONFLICT (id) DO UPDATE SET content = EXCLUDED.content, sender = EXCLUDED.sender, sent_at = EXCLUDED.sent_at;

SELECT setval('chat_messages_id_seq', (SELECT MAX(id) FROM chat_messages));

-- 4. INSERT PRODUCT REFERENCES (Đồng bộ dữ liệu cơ bản cho tính năng tư vấn sản phẩm)
INSERT INTO brands (id, brand_name, slug, logo, banner, description, is_active) VALUES
(1, 'Nike', 'nike', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 'https://images.unsplash.com/photo-1552346154-21d32810aba3', 'Thương hiệu đồ thể thao hàng đầu thế giới từ Mỹ.', true),
(2, 'Adidas', 'adidas', 'https://images.unsplash.com/photo-1518002171953-a080ee817e1f', 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2', 'Thương hiệu thời trang thể thao huyền thoại từ Đức.', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO categories (id, category_name, description, parent_id) VALUES
(1, 'Quần áo thể thao', 'Trang phục thể thao nam, nữ hiệu suất cao', NULL),
(5, 'Giày thể thao', 'Giày chạy bộ, bóng đá, cầu lông chuyên nghiệp', NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO sports (id, sport_name, description) VALUES
(1, 'Chạy bộ (Running)', 'Trang phục và giày chuyên dụng cho người chạy bộ'),
(2, 'Bóng đá (Football)', 'Trang phục thi đấu và giày bóng đá chuyên nghiệp')
ON CONFLICT (id) DO NOTHING;

INSERT INTO products (id, product_name, description, category_id, brand_id, sport_id) VALUES
(1, 'Áo Chạy Bộ Nam Nike Dri-FIT Miler', 'Áo thun thể thao thoáng khí chống tia UV', 1, 1, 1),
(2, 'Giày Chạy Bộ Nike Air Zoom Pegasus 40', 'Đôi giày chạy bộ đệm React kết hợp Air Zoom', 5, 1, 1),
(4, 'Giày Bóng Đá Adidas Predator Accuracy.3 TF', 'Giày đá bóng sân cỏ nhân tạo kiểm soát bóng tối ưu', 5, 2, 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO product_variants (id, product_id, sku, color, size, price, stock_quantity) VALUES
(1, 1, 'NK-MILER-BLK-M', 'Đen', 'M', 650000.00, 50),
(7, 2, 'NK-PEG40-BLK-42', 'Đen Trắng', '42', 3200000.00, 15),
(13, 4, 'AD-PRED-RED-41', 'Đỏ Đen', '41', 1850000.00, 20)
ON CONFLICT (id) DO NOTHING;
