-- ==============================================================================
-- DATABASE INITIALIZATION SCRIPT
-- Creates the 4 core databases for Sport Swear Shop Microservices
-- Note: For detailed sample data & seeding, see the scripts inside backend/sample_data/
-- Or run: .\scripts\seed_sample_data.ps1 from PowerShell after containers start.
-- ==============================================================================

CREATE DATABASE auth_db;
CREATE DATABASE product_catalog_db;
CREATE DATABASE order_fulfillment_db;
CREATE DATABASE support_chat_db;