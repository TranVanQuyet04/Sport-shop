-- ==============================================================================
-- DATABASE: product_catalog_db
-- SERVICE: product-catalog-service
-- DESCRIPTION: Schema definition and rich sample data for Brands, Categories, Sports, Products, Variants, Images & Collections
-- ==============================================================================

-- 1. CREATE TABLES IF NOT EXISTS
CREATE TABLE IF NOT EXISTS brands (
    id BIGSERIAL PRIMARY KEY,
    brand_name VARCHAR(255),
    slug VARCHAR(255) NOT NULL UNIQUE,
    logo VARCHAR(1000),
    banner VARCHAR(1000),
    description TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(255),
    parent_id BIGINT REFERENCES categories(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS sports (
    id BIGSERIAL PRIMARY KEY,
    sport_name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS collections (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255),
    slug VARCHAR(255) UNIQUE,
    description VARCHAR(255),
    image_url VARCHAR(255),
    type VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
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
    image_url VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    variant_id BIGINT NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS collection_products (
    id BIGSERIAL PRIMARY KEY,
    collection_id BIGINT REFERENCES collections(id) ON DELETE CASCADE,
    variant_id BIGINT REFERENCES product_variants(id) ON DELETE CASCADE,
    sort_order INTEGER
);

-- 2. INSERT BRANDS
INSERT INTO brands (id, brand_name, slug, logo, banner, description, is_active, created_at, updated_at) VALUES
(1, 'Nike', 'nike', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', 'https://images.unsplash.com/photo-1552346154-21d32810aba3', 'Thương hiệu đồ thể thao hàng đầu thế giới từ Mỹ với công nghệ đột phá Dri-FIT, Air Zoom chuyên nghiệp.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'Adidas', 'adidas', 'https://images.unsplash.com/photo-1518002171953-a080ee817e1f', 'https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2', 'Thương hiệu thời trang thể thao huyền thoại với 3 sọc đặc trưng đến từ Đức, công nghệ Boost và Aeroready.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'Puma', 'puma', 'https://images.unsplash.com/photo-1608231387042-66d1773070a5', 'https://images.unsplash.com/photo-1579338559194-a162d19bf842', 'Thương hiệu thể thao năng động chuyên nghiệp cho bóng đá, chạy bộ và phong cách đường phố.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(4, 'Under Armour', 'under-armour', 'https://images.unsplash.com/photo-1581655353564-df123a1eb820', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd', 'Trang phục hiệu suất cao dành cho vận động viên chuyên nghiệp và những người đam mê gym, fitness.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(5, 'Yonex', 'yonex', 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea', 'https://images.unsplash.com/photo-1613918431703-931fae83fecf', 'Thương hiệu cầu lông và tennis số 1 thế giới đến từ Nhật Bản, lựa chọn của các vận động viên đỉnh cao.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(6, 'Li-Ning', 'li-ning', 'https://images.unsplash.com/photo-1511886929837-354d827aae26', 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48', 'Thương hiệu thể thao hàng đầu châu Á với thiết kế mang đậm tính chuyên nghiệp và sáng tạo thời thượng.', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO UPDATE SET brand_name = EXCLUDED.brand_name, slug = EXCLUDED.slug, description = EXCLUDED.description;

SELECT setval('brands_id_seq', (SELECT MAX(id) FROM brands));

-- 3. INSERT CATEGORIES
INSERT INTO categories (id, category_name, description, parent_id) VALUES
(1, 'Quần áo thể thao', 'Trang phục thể thao nam, nữ hiệu suất cao', NULL),
(2, 'Áo thun & Áo chạy bộ', 'Áo thun thể thao thoáng khí, thấm hút mồ hôi nhanh chóng', 1),
(3, 'Quần short & Quần dài', 'Quần tập gym, chạy bộ co dãn 4 chiều thoải mái', 1),
(4, 'Áo khoác thể thao', 'Áo gió, áo khoác giữ ấm chống nước khi vận động ngoài trời', 1),
(5, 'Giày thể thao', 'Giày chạy bộ, bóng đá, cầu lông chuyên nghiệp', NULL),
(6, 'Giày chạy bộ (Running)', 'Giày chạy bộ êm ái, giảm chấn và bảo vệ khớp gối tối đa', 5),
(7, 'Giày bóng đá', 'Giày đinh sân cỏ nhân tạo (TF) và sân cỏ tự nhiên (FG)', 5),
(8, 'Giày cầu lông & Tennis', 'Giày bám sân tốt, chống lật cổ chân khi di chuyển tốc độ cao', 5),
(9, 'Phụ kiện thể thao', 'Balo, túi thể thao, găng tay, tất dớ và phụ kiện tập luyện', NULL),
(10, 'Balo & Túi thể thao', 'Túi đựng giày, balo đa năng chống thấm nước cho gym và du lịch', 9),
(11, 'Bảo hộ chấn thương', 'Băng bảo vệ đầu gối, cổ tay, mắt cá chân khi cường độ cao', 9)
ON CONFLICT (id) DO UPDATE SET category_name = EXCLUDED.category_name, description = EXCLUDED.description, parent_id = EXCLUDED.parent_id;

SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

-- 4. INSERT SPORTS
INSERT INTO sports (id, sport_name, description) VALUES
(1, 'Chạy bộ (Running)', 'Trang phục và giày chuyên dụng cho người chạy bộ, marathon và chạy đường mòn'),
(2, 'Bóng đá (Football)', 'Trang phục thi đấu, giày đá bóng và phụ kiện bóng đá chuyên nghiệp'),
(3, 'Cầu lông (Badminton)', 'Trang phục, giày và dụng cụ thi đấu cầu lông cho người chơi phong trào đến pro'),
(4, 'Gym & Fitness', 'Quần áo co dãn, găng tay và dụng cụ tập thể hình, cardio'),
(5, 'Bóng rổ (Basketball)', 'Quần áo form rộng thoáng mát, giày bóng rổ bám sân cực tốt'),
(6, 'Tennis', 'Trang phục thanh lịch, thoáng mát và giày bám sân chuyên cho tennis')
ON CONFLICT (id) DO UPDATE SET sport_name = EXCLUDED.sport_name, description = EXCLUDED.description;

SELECT setval('sports_id_seq', (SELECT MAX(id) FROM sports));

-- 5. INSERT COLLECTIONS
INSERT INTO collections (id, name, slug, description, image_url, type, is_active, start_date, end_date) VALUES
(1, 'Bộ Sưu Tập Mùa Hè 2026 - Summer Energy', 'summer-energy-2026', 'Trang phục chạy bộ và luyện tập mát mẻ, siêu nhẹ, thoáng khí tối đa cho mùa hè rực rỡ', 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd', 'SEASONAL', true, '2026-06-01', '2026-08-31'),
(2, 'Bộ Sưu Tập Siêu Phẩm Cầu Lông Yonex & Li-Ning', 'badminton-pro-series', 'Dòng sản phẩm thi đấu chuyên nghiệp dành cho tay vợt đỉnh cao trên sân đấu', 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea', 'LIMITED', true, '2026-05-01', '2026-12-31'),
(3, 'Sale Khủng Mid-Year - Giảm Đến 50%', 'mid-year-mega-sale', 'Cơ hội sở hữu giày thể thao chính hãng Nike, Adidas với mức giá siêu ưu đãi trong năm', 'https://images.unsplash.com/photo-1556906781-9a412961c28c', 'SALE', true, '2026-07-01', '2026-07-31')
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, slug = EXCLUDED.slug, description = EXCLUDED.description;

SELECT setval('collections_id_seq', (SELECT MAX(id) FROM collections));

-- 6. INSERT PRODUCTS
INSERT INTO products (id, product_name, description, category_id, brand_id, sport_id) VALUES
(1, 'Áo Chạy Bộ Nam Nike Dri-FIT Miler', 'Áo thun thể thao Nike Dri-FIT Miler mang lại cảm giác siêu nhẹ, thoáng khí cùng công nghệ chống tia UV và thoát mồ hôi siêu tốc cho cự ly dài.', 2, 1, 1),
(2, 'Giày Chạy Bộ Nike Air Zoom Pegasus 40', 'Đôi giày chạy bộ huyền thoại thế hệ thứ 40 với đệm React êm ái kết hợp 2 túi khí Air Zoom đem lại độ nảy tuyệt vời trên mọi cung đường.', 6, 1, 1),
(3, 'Quần Short Tập Gym Nam Adidas Aeroready', 'Quần short thể thao Adidas co dãn 4 chiều, trọng lượng nhẹ với cạp chun đàn hồi và túi cọc khóa kéo an toàn khi tập gym hay chạy bộ.', 3, 2, 4),
(4, 'Giày Bóng Đá Adidas Predator Accuracy.3 TF', 'Giày đá bóng sân cỏ nhân tạo Adidas Predator với vân nổi High Definition Texture giúp kiểm soát bóng tối ưu và những cú sút chính xác.', 7, 2, 2),
(5, 'Áo Polo Thể Thao Nam Under Armour Tech 2.0', 'Áo polo Under Armour sử dụng chất liệu vải UA Tech mềm mại tuyệt đối, không nhăn và nhanh khô cho cả sân tennis và trang phục thường ngày.', 2, 4, 6),
(6, 'Giày Cầu Lông Yonex Power Cushion 65 Z3', 'Dòng giày cầu lông được các tay vợt số 1 thế giới tin dùng với công nghệ Power Cushion+ hấp thụ chấn động và hoàn lực tức thì.', 8, 5, 3),
(7, 'Áo Thi Đấu Cầu Lông Li-Ning Pro Tournament', 'Áo thi đấu chuyên nghiệp Li-Ning với công nghệ AT-DRY hút ẩm và đường may không gờ giảm ma sát tối đa khi vận động cường độ cao.', 2, 6, 3),
(8, 'Áo Khoác Gió Thể Thao Puma Ultralight Windbreaker', 'Áo khoác gió thể thao Puma siêu mỏng nhẹ, cản gió và chống nước nhẹ, có thể gấp gọn vào túi riêng rất tiện lợi cho chạy bộ sáng sớm.', 4, 3, 1),
(9, 'Băng Bảo Vệ Đầu Gối Khớp Gối Đa Năng Nike Pro', 'Băng bảo vệ khớp gối co dãn cao cấp hỗ trợ giảm tải lực lên sụn chêm và dây chằng, cực kỳ phù hợp khi chạy bộ hoặc tập gánh tạ nặng.', 11, 1, 4),
(10, 'Balo Thể Thao Đa Năng Adidas Duffel Bag 40L', 'Balo trống thể thao Adidas dung tích 40 lít với ngăn đựng giày tách biệt thoáng khí và vải tráng PU chống thấm hoàn hảo.', 10, 2, 4),
(11, 'Quần Dài Thể Thao Nam Nike Sportswear Club Fleece', 'Quần nỉ thể thao Nike mang lại sự ấm áp và thoải mái tối đa với lớp lót lông cừu mềm mại, form dáng jogger trẻ trung năng động.', 3, 1, 4),
(12, 'Giày Bóng Rổ Under Armour Curry Flow 10', 'Giày bóng rổ chữ ký Stephen Curry thế hệ thứ 10 với công nghệ đế UA Flow không cao su siêu nhẹ và độ bám sàn đột phá.', 6, 4, 5)
ON CONFLICT (id) DO UPDATE SET product_name = EXCLUDED.product_name, description = EXCLUDED.description;

SELECT setval('products_id_seq', (SELECT MAX(id) FROM products));

-- 7. INSERT PRODUCT VARIANTS
INSERT INTO product_variants (id, product_id, sku, color, size, price, stock_quantity) VALUES
-- Product 1: Áo Chạy Bộ Nam Nike Dri-FIT Miler
(1, 1, 'NK-MILER-BLK-M', 'Đen', 'M', 650000.00, 50),
(2, 1, 'NK-MILER-BLK-L', 'Đen', 'L', 650000.00, 45),
(3, 1, 'NK-MILER-WHT-M', 'Trắng', 'M', 650000.00, 30),
(4, 1, 'NK-MILER-WHT-L', 'Trắng', 'L', 650000.00, 25),

-- Product 2: Giày Chạy Bộ Nike Air Zoom Pegasus 40
(5, 2, 'NK-PEG40-BLK-40', 'Đen Trắng', '40', 3200000.00, 20),
(6, 2, 'NK-PEG40-BLK-41', 'Đen Trắng', '41', 3200000.00, 25),
(7, 2, 'NK-PEG40-BLK-42', 'Đen Trắng', '42', 3200000.00, 15),
(8, 2, 'NK-PEG40-BLU-41', 'Xanh Navy', '41', 3200000.00, 18),

-- Product 3: Quần Short Tập Gym Nam Adidas Aeroready
(9, 3, 'AD-SHORT-BLK-M', 'Đen', 'M', 550000.00, 60),
(10, 3, 'AD-SHORT-BLK-L', 'Đen', 'L', 550000.00, 50),
(11, 3, 'AD-SHORT-GRY-L', 'Xám', 'L', 550000.00, 40),

-- Product 4: Giày Bóng Đá Adidas Predator Accuracy.3 TF
(12, 4, 'AD-PRED-RED-40', 'Đỏ Đen', '40', 1850000.00, 15),
(13, 4, 'AD-PRED-RED-41', 'Đỏ Đen', '41', 1850000.00, 20),
(14, 4, 'AD-PRED-RED-42', 'Đỏ Đen', '42', 1850000.00, 12),

-- Product 5: Áo Polo Thể Thao Nam Under Armour Tech 2.0
(15, 5, 'UA-POLO-NAVY-M', 'Xanh Navy', 'M', 850000.00, 35),
(16, 5, 'UA-POLO-NAVY-L', 'Xanh Navy', 'L', 850000.00, 30),

-- Product 6: Giày Cầu Lông Yonex Power Cushion 65 Z3
(17, 6, 'YN-65Z3-WHT-40', 'Trắng Vàng', '40', 2950000.00, 14),
(18, 6, 'YN-65Z3-WHT-41', 'Trắng Vàng', '41', 2950000.00, 22),
(19, 6, 'YN-65Z3-WHT-42', 'Trắng Vàng', '42', 2950000.00, 18),

-- Product 7: Áo Thi Đấu Cầu Lông Li-Ning Pro Tournament
(20, 7, 'LN-PRO-RED-M', 'Đỏ', 'M', 720000.00, 40),
(21, 7, 'LN-PRO-RED-L', 'Đỏ', 'L', 720000.00, 35),

-- Product 8: Áo Khoác Gió Thể Thao Puma Ultralight Windbreaker
(22, 8, 'PU-WIND-BLK-L', 'Đen', 'L', 1250000.00, 20),
(23, 8, 'PU-WIND-BLK-XL', 'Đen', 'XL', 1250000.00, 15),

-- Product 9: Băng Bảo Vệ Đầu Gối Khớp Gối Đa Năng Nike Pro
(24, 9, 'NK-KNEE-BLK-FREE', 'Đen', 'FreeSize', 350000.00, 100),

-- Product 10: Balo Thể Thao Đa Năng Adidas Duffel Bag 40L
(25, 10, 'AD-BAG-BLK-40L', 'Đen', '40L', 890000.00, 30),

-- Product 11: Quần Dài Thể Thao Nam Nike Sportswear Club Fleece
(26, 11, 'NK-JOG-BLK-M', 'Đen', 'M', 1150000.00, 25),
(27, 11, 'NK-JOG-BLK-L', 'Đen', 'L', 1150000.00, 28),

-- Product 12: Giày Bóng Rổ Under Armour Curry Flow 10
(28, 12, 'UA-CURRY-BLU-42', 'Xanh Dương', '42', 3850000.00, 10),
(29, 12, 'UA-CURRY-BLU-43', 'Xanh Dương', '43', 3850000.00, 8)
ON CONFLICT (id) DO UPDATE SET sku = EXCLUDED.sku, price = EXCLUDED.price, stock_quantity = EXCLUDED.stock_quantity;

SELECT setval('product_variants_id_seq', (SELECT MAX(id) FROM product_variants));

-- 8. INSERT PRODUCT IMAGES
INSERT INTO product_images (id, variant_id, image_url, is_primary) VALUES
-- Áo Nike Dri-FIT Miler
(1, 1, 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518', true),
(2, 1, 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a', false),
(3, 2, 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518', true),
(4, 3, 'https://images.unsplash.com/photo-1581655353564-df123a1eb820', true),
(5, 4, 'https://images.unsplash.com/photo-1581655353564-df123a1eb820', true),

-- Giày Nike Pegasus 40
(6, 5, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', true),
(7, 5, 'https://images.unsplash.com/photo-1608231387042-66d1773070a5', false),
(8, 6, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', true),
(9, 7, 'https://images.unsplash.com/photo-1542291026-7eec264c27ff', true),
(10, 8, 'https://images.unsplash.com/photo-1518002171953-a080ee817e1f', true),

-- Quần Short Adidas
(11, 9, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b', true),
(12, 10, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b', true),
(13, 11, 'https://images.unsplash.com/photo-1591195853828-11db59a44f6b', true),

-- Giày Adidas Predator
(14, 12, 'https://images.unsplash.com/photo-1511886929837-354d827aae26', true),
(15, 13, 'https://images.unsplash.com/photo-1511886929837-354d827aae26', true),
(16, 14, 'https://images.unsplash.com/photo-1511886929837-354d827aae26', true),

-- Polo Under Armour
(17, 15, 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990', true),
(18, 16, 'https://images.unsplash.com/photo-1618354691373-d851c5c3a990', true),

-- Giày Cầu Lông Yonex 65 Z3
(19, 17, 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea', true),
(20, 18, 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea', true),
(21, 19, 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea', true),

-- Áo Li-Ning Pro
(22, 20, 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a', true),
(23, 21, 'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a', true),

-- Áo Gió Puma
(24, 22, 'https://images.unsplash.com/photo-1556906781-9a412961c28c', true),
(25, 23, 'https://images.unsplash.com/photo-1556906781-9a412961c28c', true),

-- Băng Gối Nike Pro
(26, 24, 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd', true),

-- Balo Adidas
(27, 25, 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62', true),

-- Quần Jogger Nike
(28, 26, 'https://images.unsplash.com/photo-1506634572416-48cdfe530110', true),
(29, 27, 'https://images.unsplash.com/photo-1506634572416-48cdfe530110', true),

-- Giày Bóng Rổ Under Armour
(30, 28, 'https://images.unsplash.com/photo-1579338559194-a162d19bf842', true),
(31, 29, 'https://images.unsplash.com/photo-1579338559194-a162d19bf842', true)
ON CONFLICT (id) DO UPDATE SET image_url = EXCLUDED.image_url, is_primary = EXCLUDED.is_primary;

SELECT setval('product_images_id_seq', (SELECT MAX(id) FROM product_images));

-- 9. INSERT COLLECTION PRODUCTS
INSERT INTO collection_products (id, collection_id, variant_id, sort_order) VALUES
-- Collection 1: Summer Energy 2026
(1, 1, 1, 1),
(2, 1, 3, 2),
(3, 1, 5, 3),
(4, 1, 9, 4),
(5, 1, 22, 5),

-- Collection 2: Badminton Pro Series
(6, 2, 17, 1),
(7, 2, 18, 2),
(8, 2, 20, 3),
(9, 2, 21, 4),

-- Collection 3: Mid-Year Sale
(10, 3, 5, 1),
(11, 3, 12, 2),
(12, 3, 15, 3),
(13, 3, 25, 4),
(14, 3, 28, 5)
ON CONFLICT (id) DO UPDATE SET collection_id = EXCLUDED.collection_id, variant_id = EXCLUDED.variant_id;

SELECT setval('collection_products_id_seq', (SELECT MAX(id) FROM collection_products));
