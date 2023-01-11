USE airlineReservationSystem;

DELETE FROM admins;
INSERT INTO admins (id, username, email, password_) VALUES
(1, 'user', 'user@email.com', 'user');


DELETE FROM aircraft_models;
INSERT INTO aircraft_models(model_id, model, no_of_seats, aircraft_count) VALUES
('B737', 'Boeing 737', 200, 3),
('B757', 'Boeing 757', 240, 4),
('AA380', 'Airbus A380', 550, 1);


DELETE FROM aircrafts;
INSERT INTO aircrafts (aircraft_id, model) VALUES
('B737001', 'B737'),
('B737002', 'B737'),
('B737003', 'B737'),
('B757001', 'B757'),
('B757002', 'B757'),
('B757003', 'B757'),
('B757004', 'B757'),
('AA380001', 'AA380');


DELETE FROM seating_class;
INSERT INTO seating_class (class_id, class, price_multiplier) VALUES 
('E', 'Economy', 1.0),
('B', 'Business', 1.2),
('P', 'Platinum', 1.5);


DELETE FROM airports;
INSERT INTO airports (id, IATA_code, country_city, parent_id) VALUES
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


DELETE FROM routes;
INSERT INTO routes (route_id, origin_id, destination_id, base_price) VALUES
('R001', 1001, 1003, 2200.00),
('R002', 1001, 1004, 2300.00),
('R003', 1001, 1005, 1800.00),
('R004', 1001, 1006, 1900.00),
('R005', 1001, 1007, 1950.00),
('R006', 1001, 1008, 750.00),
('R007', 1001, 1009, 700.00),
('R008', 1001, 1010, 230.00),
('R009', 1001, 1011, 4000.00),

('R010', 1002, 1003, 2500.00),
('R011', 1002, 1004, 2600.00),
('R012', 1002, 1005, 2000.00),
('R013', 1002, 1006, 2200.00),
('R014', 1002, 1007, 2250.00),
('R015', 1002, 1008, 1050.00),
('R016', 1002, 1009, 1000.00),
('R017', 1002, 1010, 550.00),
('R018', 1002, 1011, 4100.00),

('R019', 1003, 1001, 2200.00),
('R020', 1004, 1001, 2300.00),
('R021', 1005, 1001, 1800.00),
('R022', 1006, 1001, 1900.00),
('R023', 1007, 1001, 1950.00),
('R024', 1008, 1001, 750.00),
('R025', 1009, 1001, 700.00),
('R026', 1010, 1001, 230.00),
('R027', 1011, 1001, 4000.00),

('R028', 1003, 1002, 2500.00),
('R029', 1004, 1002, 2600.00),
('R030', 1005, 1002, 2000.00),
('R031', 1006, 1002, 2200.00),
('R032', 1007, 1002, 2250.00),
('R033', 1008, 1002, 1050.00),
('R034', 1009, 1002, 1000.00),
('R035', 1010, 1002, 550.00),
('R036', 1011, 1002, 4100.00);


DELETE FROM flights;
INSERT INTO flights (flight_id, aircraft_id, route_id, flight_date, depature_time) VALUES
('F001','B737001','R001','2023-01-10','08:20:00'),
('F002','B737001','R019','2023-01-10','14:00:00'),
('F003','B737001','R003','2023-01-11','05:00:00'),
('F004','B737001','R030','2023-01-11','13:13:00'),
('F005','B737001','R017','2023-01-12','09:13:00'),
('F006','B737001','R026','2023-01-12','15:43:00'),
('F007','B737001','R009','2023-01-13','10:13:00'),
('F008','B737001','R036','2023-01-14','14:00:00'),
('F009','B737001','R011','2023-01-15','16:45:00'),
('F010','B737001','R029','2023-01-16','10:13:00'),

('F011','B737002','R001','2023-01-10','05:00:00'),
('F012','B737002','R028','2023-01-10','12:00:00'),
('F013','B737002','R018','2023-01-11','02:00:00'),
('F014','B737002','R027','2023-01-12','05:00:00'),
('F015','B737002','R009','2023-01-13','10:13:00'),
('F016','B737002','R036','2023-01-14','14:00:00'),
('F017','B737002','R018','2023-01-15','15:15:00'),
('F018','B737002','R027','2023-01-16','18:00:00'),

('F019','B737003','R010','2023-01-10','10:00:00'),
('F020','B737003','R019','2023-01-10','18:40:00'),
('F021','B737003','R005','2023-01-11','04:22:00'),
('F022','B737003','R032','2023-01-11','11:00:00'),
('F023','B737003','R016','2023-01-12','05:00:00'),
('F024','B737003','R025','2023-01-13','08:00:00'),
('F025','B737003','R002','2023-01-14','11:30:00'),
('F026','B737003','R029','2023-01-15','10:00:00'),
('F027','B737003','R015','2023-01-16','15:00:00'),

('F028','B757001','R010','2023-01-10','10:00:00'),
('F029','B757001','R019','2023-01-10','18:40:00'),
('F030','B757001','R005','2023-01-11','04:22:00'),
('F031','B757001','R032','2023-01-11','11:00:00'),
('F032','B757001','R016','2023-01-12','05:00:00'),
('F033','B757001','R025','2023-01-13','08:00:00'),
('F034','B757001','R002','2023-01-14','11:30:00'),
('F035','B757001','R029','2023-01-15','10:00:00'),
('F036','B757001','R015','2023-01-16','15:00:00'),

('F037','B757002','R001','2023-01-10','05:00:00'),
('F038','B757002','R028','2023-01-10','12:00:00'),
('F039','B757002','R018','2023-01-11','02:00:00'),
('F040','B757002','R027','2023-01-12','05:00:00'),
('F041','B757002','R009','2023-01-13','10:13:00'),
('F042','B757002','R036','2023-01-14','14:00:00'),
('F043','B757002','R018','2023-01-15','15:15:00'),
('F044','B757002','R027','2023-01-16','18:00:00'),

('F045','B757003','R001','2023-01-10','08:20:00'),
('F046','B757003','R019','2023-01-10','14:00:00'),
('F047','B757003','R003','2023-01-11','05:00:00'),
('F048','B757003','R030','2023-01-11','13:13:00'),
('F049','B757003','R017','2023-01-12','09:13:00'),
('F050','B757003','R026','2023-01-12','15:43:00'),
('F051','B757003','R009','2023-01-13','10:13:00'),
('F052','B757003','R036','2023-01-14','14:00:00'),
('F053','B757003','R011','2023-01-15','16:45:00'),
('F054','B757003','R029','2023-01-16','10:13:00'),

('F055','B757004','R030','2023-01-10','08:15:00'),
('F056','B757004','R014','2023-01-10','13:45:00'),
('F057','B757004','R023','2023-01-11','12:05:00'),
('F058','B757004','R004','2023-01-12','20:13:00'),
('F059','B757004','R031','2023-01-13','06:00:00'),
('F060','B757004','R017','2023-01-13','16:20:00'),
('F061','B757004','R026','2023-01-14','11:13:00'),
('F062','B757004','R006','2023-01-15','18:15:00'),
('F063','B757004','R024','2023-01-16','04:42:00'),

('F064','AA380001','R001','2023-01-10','07:30:00'),
('F065','AA380001','R019','2023-01-10','15:00:00'),
('F066','AA380001','R003','2023-01-11','06:30:00'),
('F067','AA380001','R030','2023-01-11','15:45:00'),
('F068','AA380001','R017','2023-01-12','08:13:00'),
('F069','AA380001','R026','2023-01-12','17:10:00'),
('F070','AA380001','R009','2023-01-13','10:13:00'),
('F071','AA380001','R036','2023-01-14','12:00:00'),
('F072','AA380001','R011','2023-01-15','13:05:00'),
('F073','AA380001','R029','2023-01-16','07:35:00');


DELETE FROM reg_user_types;
INSERT INTO reg_user_types(userTypeID, userType, discount, bookingThresh) VALUES
('P', 'Pending', 0.00, 0),
('F', 'Frequent', 0.05, 5),
('G', 'Gold', 0.09, 15);


DELETE FROM users;
INSERT INTO users (id, title, f_name, l_name, DoB, email, country) VALUES
(1, 'Mr.', 'test1', 'test1', '2000-01-12', 'test1@mail.com', 'testlanka'),
(2, 'Mr.', 'test2', 'test2', '2000-01-12', 'test2@mail.com', 'testlanka'),
(3, 'Mrs.', 'test3', 'test3', '2000-01-12', 'test3@mail.com', 'testlanka');


CALL new_user_registered("Mr.", 'reg_test', 'reg_test', '2000-01-12', 'regtest@mail.com', 'testlanka', 'testlanka', 'testlanka', 'testlanka');

CALL create_new_ticket('F001', 'E', 'S001', 2, 'A' );
CALL create_new_ticket('F001', 'E', 'S002', 2, 'A' );
CALL create_new_ticket('F001', 'B', 'S003', 1, 'A' );
CALL create_new_ticket('F018', 'P', 'S002', 3, 'A' );
CALL create_new_ticket('F073', 'P', 'S004', 4, 'C' );

CALL get_passenger_details("F001");

CALL get_passenger_count('2023-01-08', '2023-01-20', 'Colombo');

CALL get_no_of_bookings('2023-01-11', '2023-01-12');

CALL get_old_passengers('Jakarta', 'Colombo');

SELECT * FROM total_revenue_by_type;
