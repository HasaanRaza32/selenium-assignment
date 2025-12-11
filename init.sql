-- Create the database if it doesn't exist
CREATE DATABASE IF NOT EXISTS testdb;
USE testdb;

-- Create a people table (adjust based on your app needs)
CREATE TABLE IF NOT EXISTS people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert some test data (optional)
INSERT INTO people (name) VALUES ('John Doe');
INSERT INTO people (name) VALUES ('Jane Smith');
