-- ==============================================================================
-- MASTER SAMPLE DATA SCRIPT FOR ALL 4 DATABASES
-- System: Sport Swear Shop Management (Team 6)
-- Usage via psql or Docker:
--   psql -U postgres -f master_sample_data.sql
--   docker exec -i sport-swear-shop-postgres psql -U postgres -f /path/to/master_sample_data.sql
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. AUTH DATABASE (auth_db)
-- ------------------------------------------------------------------------------
\connect auth_db;
\i 01_auth_db.sql

-- ------------------------------------------------------------------------------
-- 2. PRODUCT CATALOG DATABASE (product_catalog_db)
-- ------------------------------------------------------------------------------
\connect product_catalog_db;
\i 02_product_catalog_db.sql

-- ------------------------------------------------------------------------------
-- 3. ORDER FULFILLMENT DATABASE (order_fulfillment_db)
-- ------------------------------------------------------------------------------
\connect order_fulfillment_db;
\i 03_order_fulfillment_db.sql

-- ------------------------------------------------------------------------------
-- 4. SUPPORT CHAT DATABASE (support_chat_db)
-- ------------------------------------------------------------------------------
\connect support_chat_db;
\i 04_support_chat_db.sql

-- Complete!
\echo '=============================================================================='
\echo 'Successfully seeded sample data for all 4 databases: auth_db, product_catalog_db, order_fulfillment_db, support_chat_db!'
\echo '=============================================================================='
