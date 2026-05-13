CREATE DATABASE CarRentalManagement;
USE CarRentalManagement;

CREATE TABLE Vehicles (
    vehicle_id VARCHAR(5) PRIMARY KEY,
    vehicle_name VARCHAR(100) NOT NULL,
    vehicle_type ENUM('Sedan', 'SUV', 'Van', 'Hatchback') NOT NULL,
    daily_rate DECIMAL(12,2) NOT NULL CHECK (daily_rate > 0),
    status ENUM('Available', 'Rented', 'Maintenance') DEFAULT 'Available'
);

CREATE TABLE Clients (
    client_id VARCHAR(10) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    citizen_id VARCHAR(20) UNIQUE NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    register_date DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE Rentals (
    rental_id VARCHAR(5) PRIMARY KEY,
    client_id VARCHAR(5),
    vehicle_id VARCHAR(5),
    start_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    total_amount DECIMAL(12,2) CHECK (total_amount >= 0),
    status ENUM('Active', 'Completed', 'Cancelled') DEFAULT 'Active',
    CONSTRAINT fk_rentals_clients
    FOREIGN KEY (client_id) REFERENCES Clients(client_id),
    CONSTRAINT fk_rentals_vehicles
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);

CREATE TABLE Payments (
    payment_id VARCHAR(5) PRIMARY KEY,
    rental_id VARCHAR(5),
    payment_date DATE NOT NULL,
    amount DECIMAL(12,2) CHECK (amount > 0),
    method ENUM('Cash', 'Card', 'Transfer') NOT NULL,
    CONSTRAINT fk_payments_rentals
    FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id)
);

CREATE TABLE Maintenance_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id VARCHAR(5),
    description VARCHAR(255) NOT NULL,
    maintenance_date DATE NOT NULL,
    cost DECIMAL(12,2) DEFAULT 0 CHECK (cost >= 0),
    CONSTRAINT fk_maintenance_vehicle
    FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);

INSERT INTO Vehicles(vehicle_id, vehicle_name, vehicle_type, daily_rate, status)
VALUES
('V001', 'Toyota Vios', 'Sedan', 700000, 'Available'),
('V002', 'Hyundai Tucson', 'SUV', 1200000, 'Rented'),
('V003', 'Ford Transit', 'Van', 1800000, 'Available'),
('V004', 'Mazda CX5', 'SUV', 1300000, 'Maintenance'),
('V005', 'Kia Morning', 'Hatchback', 500000, 'Available');

INSERT INTO Clients(client_id, full_name, citizen_id, phone_number, register_date)
VALUES
('C001', 'Nguyen Van An', '001199900001', '0901112223', '2024-01-15'),
('C002', 'Tran Thi Bich', '001198800002', '0988877766', '2024-06-20'),
('C003', 'Le Hoang Nam', '001200000003', '0903334445', '2025-03-10'),
('C004', 'Nguyen Minh Duc', '001199500004', '0355556667', '2023-12-05'),
('C005', 'Pham Thu Ha', '001200100005', '0779998881', '2026-01-01');


INSERT INTO Rentals(rental_id, client_id, vehicle_id, start_date, expected_return_date, total_amount, status)
VALUES
('R001', 'C001', 'V002', '2025-01-10', '2025-01-15', 6000000, 'Active'),
('R002', 'C002', 'V001', '2025-02-05', '2025-02-08', 2100000, 'Completed'),
('R003', 'C003', 'V003', '2025-03-12', '2025-03-15', 5400000, 'Completed'),
('R004', 'C004', 'V005', '2024-12-20', '2024-12-22', 1000000, 'Completed'),
('R005', 'C005', 'V004', '2026-01-05', '2026-01-10', 6500000, 'Cancelled');

INSERT INTO Payments(payment_id, rental_id, payment_date, amount, method)
VALUES
('P001', 'R002', '2025-02-08', 2100000, 'Cash'),
('P002', 'R003', '2025-03-15', 5400000, 'Transfer'),
('P003', 'R004', '2024-12-22', 1000000, 'Card'),
('P004', 'R001', '2025-01-10', 3000000, 'Transfer'),
('P005', 'R005', '2026-01-05', 2000000, 'Cash');

INSERT INTO Maintenance_Logs(log_id, vehicle_id, description, maintenance_date, cost)
VALUES
(1, 'V004', 'Bao duong dong co', '2025-12-01', 1500000),
(2, 'V001', 'Thay dau may', '2023-11-15', 300000),
(3, 'V003', 'Kiem tra phanh', '2024-05-20', 700000),
(4, 'V005', 'Ve sinh noi that', '2023-10-10', 200000),
(5, 'V002', 'Sua dieu hoa', '2025-01-05', 900000);

-- Câu UPDATE. 
UPDATE Vehicles
SET daily_rate = daily_rate * 1.1
WHERE vehicle_type = 'SUV';

-- Câu DELETE. 
DELETE FROM Maintenance_Logs
WHERE cost < 500000 AND maintenance_date < '2024-01-01';

-- Phần 2:
-- Câu 1. 
SELECT rental_id, client_id, vehicle_id, start_date, expected_return_date, total_amount, status
FROM Rentals
WHERE start_date BETWEEN '2025-01-01' AND '2025-03-31';

-- Câu 2. 
SELECT full_name, phone_number
FROM Clients
WHERE full_name LIKE 'Nguyen%' AND YEAR(register_date) < 2025;

-- Câu 3
SELECT payment_id, rental_id, payment_date, amount, method
FROM Payments
ORDER BY amount DESC
LIMIT 4 OFFSET 2;

-- Phần 3:
-- Câu 1. 
SELECT
    v.vehicle_name,
    v.vehicle_type,
    r.start_date,
    r.total_amount
FROM Rentals r
LEFT JOIN Vehicles v
ON r.vehicle_id = v.vehicle_id;

-- Câu 2.
SELECT
    c.client_id,
    c.full_name,
    SUM(p.amount) AS total_paid
FROM Rentals r 
INNER JOIN Clients c
ON r.client_id = c.client_id
INNER JOIN Payments p
ON r.rental_id = p.rental_id
GROUP BY c.full_name
HAVING SUM(p.amount) > 20000000;

-- Câu 3.
SELECT v.vehicle_type, COUNT(*) AS total_rentals
FROM Rentals r 
INNER JOIN Vehicles v
ON r.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY total_rentals DESC
LIMIT 1;

-- Phần 4:
-- Câu 1.
CREATE INDEX idx_rental_dates
ON Rentals(start_date, expected_return_date);

-- Câu 2
CREATE VIEW vw_vehicle_status_summary AS
SELECT v.vehicle_name, v.vehicle_type, COUNT(r.rental_id) AS total_rentals, SUM(r.total_amount) AS total_revenue
FROM Rentals r 
LEFT JOIN Vehicles v
ON r.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_name, v.vehicle_type;

-- Phần 5:
-- Câu 1. 
DELIMITER $$
CREATE TRIGGER trg_after_payment_insert
AFTER INSERT 
ON Payments
FOR EACH ROW
BEGIN
    UPDATE Rentals
    SET status = 'Completed'
    WHERE rental_id = NEW.rental_id;

    UPDATE Vehicles
    SET status = 'Available'
    WHERE vehicle_id = (
        SELECT vehicle_id
        FROM Rentals
        WHERE rental_id = NEW.rental_id);
END $$
DELIMITER ;

-- Câu 2. 
DELIMITER $$
CREATE TRIGGER trg_prevent_delete_active_client
BEFORE DELETE 
ON Clients
FOR EACH ROW
BEGIN
    DECLARE active_count INT;
    
    SELECT COUNT(*)
    INTO active_count
    FROM Rentals
    WHERE client_id = OLD.client_id
    AND status = 'Active';
    IF active_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT ='Cannot delete client with active rentals';
    END IF;
END $$
DELIMITER ;

-- Phần 6:
-- Câu 1. 
DELIMITER $$
CREATE PROCEDURE sp_get_vehicle_availability(
    IN p_vehicle_id VARCHAR(10),
    OUT p_message VARCHAR(50)
)
BEGIN
    DECLARE vehicle_exists INT;
    DECLARE active_rental INT;

    SELECT COUNT(*)
    INTO vehicle_exists
    FROM Vehicles
    WHERE vehicle_id = p_vehicle_id;
    IF vehicle_exists = 0 THEN
        SET p_message = 'Vehicle not found';
    ELSE
        SELECT COUNT(*)
        INTO active_rental
        FROM Rentals
        WHERE vehicle_id = p_vehicle_id
        AND status = 'Active';
        IF active_rental > 0 THEN
            SET p_message = 'Busy';
        ELSE
            SET p_message = 'Ready';
        END IF;
    END IF;
END $$
DELIMITER ;
