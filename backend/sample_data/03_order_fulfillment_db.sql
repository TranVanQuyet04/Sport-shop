-- ==============================================================================
-- DATABASE: order_fulfillment_db
-- SERVICE: order-fulfillment-service
-- DESCRIPTION: Schema definition and rich sample data for Carts, Orders, Work Shifts, Assignments, Leave Requests & Delivery Reports
-- ==============================================================================

-- 1. CREATE TABLES IF NOT EXISTS
CREATE TABLE IF NOT EXISTS carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT REFERENCES carts(id) ON DELETE CASCADE,
    variant_id BIGINT NOT NULL,
    product_name VARCHAR(255),
    size VARCHAR(255),
    color VARCHAR(255),
    unit_price NUMERIC(38,2),
    image_url VARCHAR(255),
    available_stock INTEGER,
    quantity INTEGER
);

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(255),
    total_amount NUMERIC(38,2),
    payment_method VARCHAR(255),
    recipient_name VARCHAR(255),
    phone_number VARCHAR(255),
    shipping_address VARCHAR(255),
    note VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    variant_id BIGINT NOT NULL,
    product_name VARCHAR(255),
    size VARCHAR(255),
    color VARCHAR(255),
    variant_image VARCHAR(255),
    quantity INTEGER,
    price NUMERIC(38,2)
);

CREATE TABLE IF NOT EXISTS work_shifts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    user_full_name VARCHAR(255),
    user_role VARCHAR(255),
    shift_date DATE,
    shift_code VARCHAR(255),
    note VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_assignments (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    staff_id BIGINT NOT NULL,
    staff_name VARCHAR(255),
    staff_role VARCHAR(255),
    assigned_by BIGINT,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    note VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS leave_requests (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    user_full_name VARCHAR(255),
    user_role VARCHAR(255),
    start_date DATE,
    days INTEGER,
    reason VARCHAR(255),
    status VARCHAR(255) DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    decided_at TIMESTAMP,
    decided_by BIGINT
);

CREATE TABLE IF NOT EXISTS delivery_reports (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    reported_by BIGINT,
    reported_by_name VARCHAR(255),
    status VARCHAR(255),
    reason VARCHAR(255),
    note VARCHAR(255),
    evidence_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERT CARTS & CART ITEMS
INSERT INTO carts (id, user_id) VALUES
(1, 5), -- Đặng Quang Khách
(2, 6), -- Hoàng Mai Thảo
(3, 7)  -- Vũ Đức Anh
ON CONFLICT (user_id) DO NOTHING;

SELECT setval('carts_id_seq', (SELECT MAX(id) FROM carts));

INSERT INTO cart_items (id, cart_id, variant_id, product_name, size, color, unit_price, image_url, available_stock, quantity) VALUES
(1, 1, 3, 'Áo Chạy Bộ Nam Nike Dri-FIT Miler', 'M', 'Trắng', 650000.00, 'https://images.unsplash.com/photo-1581655353564-df123a1eb820', 30, 1),
(2, 1, 9, 'Quần Short Tập Gym Nam Adidas Aeroready', 'M', 'Đen', 550000.00, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b', 60, 2),
(3, 2, 6, 'Giày Chạy Bộ Nike Air Zoom Pegasus 40', '41', 'Đen Trắng', 3200000.00, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 25, 1),
(4, 3, 24, 'Băng Bảo Vệ Đầu Gối Khớp Gối Đa Năng Nike Pro', 'FreeSize', 'Đen', 350000.00, 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd', 100, 2)
ON CONFLICT (id) DO UPDATE SET quantity = EXCLUDED.quantity, unit_price = EXCLUDED.unit_price;

SELECT setval('cart_items_id_seq', (SELECT MAX(id) FROM cart_items));

-- 3. INSERT ORDERS
INSERT INTO orders (id, user_id, order_date, status, total_amount, payment_method, recipient_name, phone_number, shipping_address, note) VALUES
(1, 5, CURRENT_TIMESTAMP - INTERVAL '6 days', 'COMPLETED', 3850000.00, 'VNPAY', 'Đặng Quang Khách', '0911223344', '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, Hồ Chí Minh', 'Giao hàng giờ hành chính, gọi trước 15 phút'),
(2, 6, CURRENT_TIMESTAMP - INTERVAL '3 days', 'SHIPPING', 1950000.00, 'COD', 'Hoàng Mai Thảo', '0912334455', '45 Xuân Thủy, Phường Dịch Vọng, Quận Cầu Giấy, Hà Nội', 'Đóng gói cẩn thận giúp em nhé'),
(3, 5, CURRENT_TIMESTAMP - INTERVAL '1 day', 'PACKING', 3200000.00, 'MOMO', 'Đặng Quang Khách', '0911223344', '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, Hồ Chí Minh', 'Giao buổi chiều'),
(4, 7, CURRENT_TIMESTAMP - INTERVAL '5 hours', 'PENDING', 720000.00, 'COD', 'Vũ Đức Anh', '0913445566', '88 Bạch Đằng, Phường Thạch Thang, Quận Hải Châu, Đà Nẵng', 'Gọi trước khi giao'),
(5, 6, CURRENT_TIMESTAMP - INTERVAL '10 days', 'CANCELLED', 1300000.00, 'COD', 'Hoàng Mai Thảo', '0912334455', '45 Xuân Thủy, Phường Dịch Vọng, Quận Cầu Giấy, Hà Nội', 'Khách báo đổi màu áo')
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, total_amount = EXCLUDED.total_amount;

SELECT setval('orders_id_seq', (SELECT MAX(id) FROM orders));

-- 4. INSERT ORDER ITEMS
INSERT INTO order_items (id, order_id, variant_id, product_name, size, color, variant_image, quantity, price) VALUES
-- Order 1 (Total: 3,850,000)
(1, 1, 5, 'Giày Chạy Bộ Nike Air Zoom Pegasus 40', '40', 'Đen Trắng', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 1, 3200000.00),
(2, 1, 1, 'Áo Chạy Bộ Nam Nike Dri-FIT Miler', 'M', 'Đen', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518', 1, 650000.00),

-- Order 2 (Total: 1,950,000)
(3, 2, 12, 'Giày Bóng Đá Adidas Predator Accuracy.3 TF', '40', 'Đỏ Đen', 'https://images.unsplash.com/photo-1511886929837-354d827aae26', 1, 1850000.00),

-- Order 3 (Total: 3,200,000)
(4, 3, 6, 'Giày Chạy Bộ Nike Air Zoom Pegasus 40', '41', 'Đen Trắng', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 1, 3200000.00),

-- Order 4 (Total: 720,000)
(5, 4, 20, 'Áo Thi Đấu Cầu Lông Li-Ning Pro Tournament', 'M', 'Đỏ', 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a', 1, 720000.00),

-- Order 5 (Total: 1,300,000)
(6, 5, 1, 'Áo Chạy Bộ Nam Nike Dri-FIT Miler', 'M', 'Đen', 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518', 2, 650000.00)
ON CONFLICT (id) DO UPDATE SET quantity = EXCLUDED.quantity, price = EXCLUDED.price;

SELECT setval('order_items_id_seq', (SELECT MAX(id) FROM order_items));

-- 5. INSERT WORK SHIFTS
INSERT INTO work_shifts (id, user_id, user_full_name, user_role, shift_date, shift_code, note, created_at) VALUES
(1, 3, 'Lê Hoàng Nhân Viên', 'STAFF', CURRENT_DATE, 'MORNING_08_12', 'Ca sáng kiểm tra kho và đóng gói đơn COD', CURRENT_TIMESTAMP - INTERVAL '5 days'),
(2, 4, 'Phạm Minh Giao Hàng', 'STAFF', CURRENT_DATE, 'AFTERNOON_13_17', 'Ca chiều giao các đơn nội thành HCM', CURRENT_TIMESTAMP - INTERVAL '5 days'),
(3, 3, 'Lê Hoàng Nhân Viên', 'STAFF', CURRENT_DATE + INTERVAL '1 day', 'FULL_DAY', 'Trực quầy hỗ trợ khách hàng và điều phối kho', CURRENT_TIMESTAMP - INTERVAL '3 days'),
(4, 4, 'Phạm Minh Giao Hàng', 'STAFF', CURRENT_DATE + INTERVAL '1 day', 'MORNING_08_12', 'Giao hàng khu vực Quận 1 và Quận 3', CURRENT_TIMESTAMP - INTERVAL '3 days')
ON CONFLICT (id) DO UPDATE SET shift_code = EXCLUDED.shift_code, note = EXCLUDED.note;

SELECT setval('work_shifts_id_seq', (SELECT MAX(id) FROM work_shifts));

-- 6. INSERT ORDER ASSIGNMENTS
INSERT INTO order_assignments (id, order_id, staff_id, staff_name, staff_role, assigned_by, assigned_at, note) VALUES
(1, 1, 4, 'Phạm Minh Giao Hàng', 'STAFF', 2, CURRENT_TIMESTAMP - INTERVAL '5 days', 'Giao nhanh cho khách ưu tiên VIP'),
(2, 2, 4, 'Phạm Minh Giao Hàng', 'STAFF', 2, CURRENT_TIMESTAMP - INTERVAL '2 days', 'Đơn ngoại tỉnh đã gửi qua bên đối tác GHTK'),
(3, 3, 3, 'Lê Hoàng Nhân Viên', 'STAFF', 2, CURRENT_TIMESTAMP - INTERVAL '12 hours', 'Đóng gói bọc xốp chống sốc')
ON CONFLICT (order_id) DO UPDATE SET staff_id = EXCLUDED.staff_id, note = EXCLUDED.note;

SELECT setval('order_assignments_id_seq', (SELECT MAX(id) FROM order_assignments));

-- 7. INSERT LEAVE REQUESTS
INSERT INTO leave_requests (id, user_id, user_full_name, user_role, start_date, days, reason, status, created_at, decided_at, decided_by) VALUES
(1, 3, 'Lê Hoàng Nhân Viên', 'STAFF', CURRENT_DATE + INTERVAL '5 days', 2, 'Xin nghỉ phép giải quyết việc gia đình', 'APPROVED', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '3 days', 2),
(2, 4, 'Phạm Minh Giao Hàng', 'STAFF', CURRENT_DATE + INTERVAL '10 days', 1, 'Xin nghỉ khám sức khỏe định kỳ', 'PENDING', CURRENT_TIMESTAMP - INTERVAL '1 day', NULL, NULL)
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, reason = EXCLUDED.reason;

SELECT setval('leave_requests_id_seq', (SELECT MAX(id) FROM leave_requests));

-- 8. INSERT DELIVERY REPORTS
INSERT INTO delivery_reports (id, order_id, reported_by, reported_by_name, status, reason, note, evidence_image_url, created_at) VALUES
(1, 1, 4, 'Phạm Minh Giao Hàng', 'SUCCESS', 'Giao hàng thành công', 'Khách hàng đã kiểm tra giày và hài lòng, đã ký nhận đầy đủ', 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d', CURRENT_TIMESTAMP - INTERVAL '5 days'),
(2, 2, 4, 'Phạm Minh Giao Hàng', 'DELAYED', 'Khách hàng không có nhà', 'Đã liên hệ nhưng khách xin dời sang ngày mai giao lại vào buổi sáng', NULL, CURRENT_TIMESTAMP - INTERVAL '1 day')
ON CONFLICT (id) DO UPDATE SET status = EXCLUDED.status, note = EXCLUDED.note;

SELECT setval('delivery_reports_id_seq', (SELECT MAX(id) FROM delivery_reports));
