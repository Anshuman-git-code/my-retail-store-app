-- Initialize databases for the retail store application

-- Create catalog database and user (already created by environment variables)
-- MYSQL_DATABASE=catalog and MYSQL_USER=catalog_user are set in docker-compose

-- Create orders database and user
CREATE DATABASE IF NOT EXISTS orders;
CREATE USER IF NOT EXISTS 'orders_user'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON orders.* TO 'orders_user'@'%';

-- Grant permissions to catalog user
GRANT ALL PRIVILEGES ON catalog.* TO 'catalog_user'@'%';

-- Flush privileges to ensure all changes take effect
FLUSH PRIVILEGES;

-- Show created databases
SHOW DATABASES;
