USE airlineReservationSystem;

DELETE FROM aircraft_models;
INSERT INTO aircraft_models (id, model, seating_capacity) VALUES
(1, 'Boeing 737', 200),
(2, 'Boeing 757', 240),
(3, 'Airbus A380', 550);

DELETE FROM aircrafts;
INSERT INTO aircrafts (id, model_id) VALUES
('B737001', 1),
('B737002', 1),
('B737003', 1),
('B757001', 2),
('B757002', 2),
('B757003', 2),
('B757004', 2),
('A380001', 3);

DELETE FROM airports;
INSERT INTO airports (id, IATA_code, city_country, parent_id) VALUES
(1, 'IDN', 'Indonesia', NULL),
(2, 'LKA', 'Sri Lanka', NULL),
(3, 'IND', 'India', NULL),
(4, 'THA', 'Thailand', NULL),
(5, 'SGP', 'Singapore', NULL),
(6, 'USA', 'United States', NULL),
(101, 'NY', 'New York State', 6),
(1001, 'CGK', 'Jakarta', 1),
(1002, 'DPS', 'Denpasar', 1),
(1003, 'BIA', 'Colombo', 2),
(1004, 'HRI', 'Hambantota', 2),
(1005, 'DEL', 'Delhi', 3),
(1006, 'BOM', 'Mumbai', 3),
(1007, 'MAA', 'Chennai', 3),
(1008, 'BKK', 'Bangkok', 4),
(1009, 'DMK', 'Bangkok', 4),
(1010, 'SIN', 'Singapore', 5),
(1011, 'JFK', 'New York City', 101);