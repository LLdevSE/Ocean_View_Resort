-- ============================================================
--  Ocean View Resort — MySQL Database Setup Script
--  Run this script ONCE to create the schema, tables,
--  stored procedures, triggers, and seed data.
-- ============================================================

-- Create & select database
CREATE DATABASE IF NOT EXISTS Ocean_View_Resort_Database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE Ocean_View_Resort_Database;

-- ============================================================
--  1. TABLES
-- ============================================================

-- Drop existing tables (in FK-safe order)
DROP TABLE IF EXISTS reservations;

DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS rooms;

-- ---- users ----
CREATE TABLE users (
    id INT NOT NULL AUTO_INCREMENT,
    staff_id VARCHAR(20) DEFAULT NULL, -- e.g. STF-001 (null for admin)
    role ENUM('ADMIN', 'STAFF') NOT NULL,
    username VARCHAR(80) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- BCrypt hash
    mobile_num VARCHAR(20) DEFAULT NULL,
    address VARCHAR(255) DEFAULT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_staff_id (staff_id)
) ENGINE = InnoDB;

-- ---- rooms ----
CREATE TABLE rooms (
    id INT NOT NULL AUTO_INCREMENT,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type ENUM('STANDARD', 'DELUXE', 'SUITE') NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    status ENUM(
        'AVAILABLE',
        'BOOKED',
        'MAINTENANCE'
    ) NOT NULL DEFAULT 'AVAILABLE',
    PRIMARY KEY (id)
) ENGINE = InnoDB;

-- ---- reservations ----
CREATE TABLE reservations (
    res_no VARCHAR(20) NOT NULL,
    customer_name VARCHAR(150) NOT NULL,
    customer_mobile_num VARCHAR(20) NOT NULL,
    customer_address VARCHAR(255) NOT NULL,
    room_type ENUM('STANDARD', 'DELUXE', 'SUITE') NOT NULL,
    room_id INT DEFAULT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_days INT DEFAULT NULL, -- Calculated by trigger
    total_price DECIMAL(10, 2) DEFAULT NULL, -- Calculated by trigger
    reservation_by VARCHAR(20) NOT NULL, -- FK → users.staff_id
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (res_no),
    CONSTRAINT fk_res_staff FOREIGN KEY (reservation_by) REFERENCES users (staff_id),
    CONSTRAINT fk_res_room FOREIGN KEY (room_id) REFERENCES rooms (id)
) ENGINE = InnoDB;

-- ============================================================
--  2. STORED PROCEDURE — Auto-Generate staff_id
-- ============================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_create_staff$$

CREATE PROCEDURE sp_create_staff (
    IN  p_username   VARCHAR(80),
    IN  p_password   VARCHAR(255),   -- Already BCrypt-hashed by Java
    IN  p_mobile_num VARCHAR(20),
    IN  p_address    VARCHAR(255)
)
BEGIN
    DECLARE v_next_num   INT;
    DECLARE v_staff_id   VARCHAR(20);

    -- Determine next sequential number
    SELECT COALESCE(MAX(CAST(SUBSTRING(staff_id, 5) AS UNSIGNED)), 0) + 1
    INTO   v_next_num
    FROM   users
    WHERE  role = 'STAFF'
      AND  staff_id IS NOT NULL;

    -- Format: STF-001, STF-002, ...
    SET v_staff_id = CONCAT('STF-', LPAD(v_next_num, 3, '0'));

    INSERT INTO users (staff_id, role, username, password, mobile_num, address)
    VALUES (v_staff_id, 'STAFF', p_username, p_password, p_mobile_num, p_address);
END$$

DELIMITER;

-- ============================================================
--  3. TRIGGER — Calculate total_days & total_price on INSERT
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS trg_reservation_before_insert$$

CREATE TRIGGER trg_reservation_before_insert
BEFORE INSERT ON reservations
FOR EACH ROW
BEGIN
    DECLARE v_price DECIMAL(10,2);

    -- Calculate total days (minimum 1)
    SET NEW.total_days = GREATEST(DATEDIFF(NEW.check_out, NEW.check_in), 1);

    -- Look up the price_per_night for the requested room type (uses cheapest available)
    SELECT MIN(price_per_night) INTO v_price
    FROM   rooms
    WHERE  room_type = NEW.room_type;

    -- Calculate total price
    IF v_price IS NOT NULL THEN
        SET NEW.total_price = NEW.total_days * v_price;
    ELSE
        SET NEW.total_price = 0.00;
    END IF;
END$$

DELIMITER;

-- ============================================================
--  4. TRIGGER — Auto-generate res_no on INSERT
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS trg_reservation_res_no$$

CREATE TRIGGER trg_reservation_res_no
BEFORE INSERT ON reservations
FOR EACH ROW
BEGIN
    DECLARE v_next INT;

    SELECT COALESCE(MAX(CAST(SUBSTRING(res_no, 5) AS UNSIGNED)), 0) + 1
    INTO   v_next
    FROM   reservations;

    SET NEW.res_no = CONCAT('RES-', LPAD(v_next, 4, '0'));
END$$

DELIMITER;

-- ============================================================
--  5. SEED DATA
-- ============================================================

-- Default Admin user (Username: admin, Password: admin678)
-- BCrypt hash for "admin678" with cost factor 12:
INSERT INTO
    users (
        staff_id,
        role,
        username,
        password,
        mobile_num,
        address
    )
VALUES (
        NULL,
        'ADMIN',
        'admin',
        '$2a$12$lZkGqZ3yqFSLO1fHTZm8z.ebN3PEJDVwnRuOFYSX0wnq3p5wW7.i6',
        '0771234567',
        'Ocean View Resort HQ, Colombo'
    );

-- Sample Rooms
INSERT INTO
    rooms (
        room_number,
        room_type,
        price_per_night,
        status
    )
VALUES (
        '101',
        'STANDARD',
        5500.00,
        'AVAILABLE'
    ),
    (
        '102',
        'STANDARD',
        5500.00,
        'AVAILABLE'
    ),
    (
        '103',
        'STANDARD',
        5500.00,
        'BOOKED'
    ),
    (
        '201',
        'DELUXE',
        9500.00,
        'AVAILABLE'
    ),
    (
        '202',
        'DELUXE',
        9500.00,
        'AVAILABLE'
    ),
    (
        '203',
        'DELUXE',
        9500.00,
        'BOOKED'
    ),
    (
        '301',
        'SUITE',
        18000.00,
        'AVAILABLE'
    ),
    (
        '302',
        'SUITE',
        18000.00,
        'AVAILABLE'
    );