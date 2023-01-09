DROP DATABASE IF EXISTS `airlineReservationSystem`;
CREATE DATABASE `airlineReservationSystem`; 
USE `airlineReservationSystem`;
SET @@session.time_zone='+05:30';


CREATE TABLE aircraft_models(
	model_id VARCHAR(5) PRIMARY KEY,
	model VARCHAR(15) NOT NULL,
	economy_class_seats INT NOT NULL DEFAULT 0,
	business_class_seats INT NOT NULL DEFAULT 0,
	platinum_class_seats INT NOT NULL DEFAULT 0,
	aircraft_count INT NOT NULL DEFAULT 0,
	
    -- UNIQUE KEY same_mode(Model, Brand), NO NEED
    
    CHECK (economy_class_seats >= 0 AND business_class_seats >= 0 AND platinum_class_seats >= 0 AND aircraft_count >= 0)
);
-- TODO should check no.of seats for eack class for each aircraft
-- INSERT INTO aircraft_models(model_id, model, economy_class_seats, business_class_seats, platinum_class_seats, aircraft_count) VALUES
-- ('B737', 'Boeing 737', 20, 50, 400, 3),
-- ('B757', 'Boeing 757', 20, 50, 400, 4),
-- ('AA380', 'Airbus A380', 20, 50, 400, 1);


CREATE TABLE aircrafts(
	aircraft_id VARCHAR(15) PRIMARY KEY,
	model VARCHAR(5) NOT NULL,

	FOREIGN KEY(model) REFERENCES aircraft_models(model_id) 
);
-- CREATE INDEX idx_Airplane_ID ON Airplanes (Airplane_ID); NO NEED
-- INSERT INTO aircrafts (aircraft_id, model) VALUES
-- ('B737001', 'B737'),
-- ('B737002', 'B737'),
-- ('B737003', 'B737'),
-- ('B757001', 'B757'),
-- ('B757002', 'B757'),
-- ('B757003', 'B757'),
-- ('B757004', 'B757'),
-- ('AA380001', 'AA380');


CREATE TABLE seating_class(
	class_id CHAR(1) PRIMARY KEY,
	class VARCHAR(10) ,
	per_km_price FLOAT(2, 1) NOT NULL,
	
    Check (per_km_price > 0)
);

-- INSERT INTO class_types(class_id, class, per_km_price) VALUES 
-- ('E', 'Economy', 0.5),
-- ('B', 'Business', 1.0),
-- ('P', 'Platinum', 2.0);


CREATE TABLE country_city (
	country_city_id INT PRIMARY KEY, -- 1-100:Countries, 101-1000:States, 1001-..:Cities
	country_city VARCHAR(30),
    parent_id INT DEFAULT NULL, 
    
    FOREIGN KEY(parent_id) REFERENCES country_city(country_city_id));
-- INSERT INTO country_city(country_city_id, country_city) VALUES (1, 'Sri Lanka');
-- INSERT INTO country_city(country_city_id, country_city, parent_id) VALUES (1001, 'Colombo', 1);

CREATE TABLE airports (
	IATA_code CHAR(3) PRIMARY KEY,
	airport VARCHAR(100) NOT NULL UNIQUE,
	city_id INT NOT NULL,
	
    FOREIGN KEY(city_id) REFERENCES country_city(country_city_id));
-- INSERT INTO airports(IATA_code, airport, city_id) VALUES ('BIA', 'Bandaranaike International Airport', 1);


CREATE TABLE routes(
	route_id VARCHAR(5) PRIMARY KEY,
	origin_id VARCHAR(3),
	destination_id VARCHAR(3),
	kms INT,
	
	FOREIGN KEY(origin_id) REFERENCES airports(IATA_code) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(destination_id) REFERENCES airports(IATA_code) ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE flights(
	flight_id VARCHAR(5) PRIMARY KEY,
	aircraft_id VARCHAR(15),
	route_id VARCHAR(5),
	flight_date DATE,
	depature_time TIME,
	remaining_economy_tickets INT  NOT NULL DEFAULT 0,
	remaining_business_tickets INT  NOT NULL DEFAULT 0,
	remaining_platinum_tickets INT  NOT NULL DEFAULT 0,
	revenue NUMERIC(8,2) NOT NULL DEFAULT 0,
	flight_status VARCHAR(10) NOT NULL DEFAULT 'Scheduled',
	
	FOREIGN KEY(aircraft_id) REFERENCES aircrafts(aircraft_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(route_id) REFERENCES routes(route_id) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE KEY (flight_date, aircraft_id),

	CHECK (remaining_economy_tickets >= 0 AND remaining_business_tickets >=0 AND  remaining_platinum_tickets >=0)
);


CREATE TABLE reg_user_types ( 
	userTypeID CHAR(1) DEFAULT 'P',
    userType  VARCHAR(10),
	discount FLOAT(3, 2) NOT NULL DEFAULT 0.00 , -- 0.00 to 1.00 ???
	bookingThresh INT NOT NULL DEFAULT 0,

	PRIMARY KEY(userTypeID),
	
	CHECK (discount >= 0 AND bookingThresh >= 0)
);


-- both guest and registered users data included  
CREATE TABLE users(
    id int PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(5),
	f_Name VARCHAR(30) NOT NULL,
    l_Name VARCHAR(30) NOT NULL,
	DoB DATE NOT NULL, -- YYYY-MM-DD
    -- Age VARCHAR(30) NOT NULL,
	email VARCHAR(30) NOT NULL,
	-- Telephone VARCHAR(15) NOT NULL,
	country VARCHAR(20) NOT NULL,	
	user_category CHAR(1) NOT NULL DEFAULT 'G'); -- G-Guest, R-Registered
            
-- register weddi users ekatai registered users ekatai dekatama data watenawa. issella update wenne user dable eka
-- guestlage user eka witharai update wenne
CREATE TABLE registered_users(
	id int PRIMARY KEY,
	username VARCHAR(30) NOT NULL UNIQUE,
	password_ VARCHAR(100) NOT NULL,
	address_ VARCHAR(100),
	date_registered DATETIME DEFAULT CURRENT_TIMESTAMP, -- YYYY-MM-DD HH:MM:SS (is this required)
    user_type CHAR(1) NOT NULL DEFAULT 'P',
	total_bookings INT NOT NULL DEFAULT 0,
	
	FOREIGN KEY(user_type) REFERENCES reg_user_types(userTypeID) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY(id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    
	CHECK (total_bookings >= 0));

CREATE TABLE tickets(
	ticket_id INT PRIMARY KEY AUTO_INCREMENT ,
	booking_time DATETIME DEFAULT CURRENT_TIMESTAMP,
	flight_id VARCHAR(5),
	class_id CHAR(1),
	seat_id INT(3),
	price NUMERIC(8,2),
	user_id INT,
	adult_child ENUM("A", "C"),
	
	FOREIGN KEY(flight_id) REFERENCES flights(flight_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(class_id) REFERENCES seating_class(class_id) ON UPDATE CASCADE ON DELETE RESTRICT,
	UNIQUE KEY seat_allocation(flight_id, class_id, seat_id),

	CHECK (price >= 300), -- ??
	check (seat_id >= 0 AND seat_id <= 300)
);


CREATE TABLE sessions( 	
	session_id VARCHAR(40),
	user_id INT,
	end_time DATETIME,

	PRIMARY KEY(session_id, user_id),
	FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE
);


-- FUNCTIONS
-- needs in the procedure new ticket to update the tickets table's price
DELIMITER //
CREATE FUNCTION get_priceOfTicket(user_id INT, route_id VARCHAR(5), class CHAR(1))
RETURNS INT
DETERMINISTIC
BEGIN
DECLARE price INT DEFAULT 0;
DECLARE discount INT DEFAULT 0;
DECLARE user_type CHAR(1);
SET price = (SELECT per_km_price FROM seating_class WHERE class_id = class) * (SELECT kms FROM routes WHERE route_id = route_id);
IF (SELECT user_category FROM users WHERE id = user_id LIMIT 1) <=> 'R' THEN
	SET user_type = (SELECT user_type FROM registered_users WHERE id = user_id);
	SET discount = (SELECT discount FROM reg_user_types WHERE userTypeID = user_type);
END IF;
SET price = price - (price * discount);
RETURN price;
END//
DELIMITER ;


-- PROCEDURES
DELIMITER //
CREATE PROCEDURE new_user_registered(title VARCHAR(5), f_name VARCHAR(30), l_name VARCHAR(30), DoB DATE, email VARCHAR(30), country VARCHAR(30), username VARCHAR(30), password_ VARCHAR(100), address_ VARCHAR(100))
BEGIN
	DECLARE last_id INT DEFAULT 0;
	START TRANSACTION;
	INSERT INTO users(title, f_name, l_name, DoB, email, country, user_category) VALUES (title, f_name, l_name, DoB, email, country, 'R');
	SET last_id = LAST_INSERT_ID();
	INSERT INTO registered_users(id, username, password_, address_) VALUES (last_id, username, password_, address_);
	COMMIT;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE create_new_ticket(flight_id VARCHAR(5), class_id CHAR(1), seat_id VARCHAR(5), user_id INT, adult_child CHAR(1))
BEGIN
	DECLARE price INT;
    DECLARE route_id VARCHAR(5);
	START TRANSACTION;	
	
    SET route_id = (SELECT route_id FROM flights WHERE flight_id = flight_id);
    SET price = get_priceOfTicket(user_id, route_id, class_id);
    
    INSERT INTO tickets(flight_id, class_id, seat_id, price, user_id, adult_child) VALUES (flight_id, class_id, seat_id, price, user_id, adult_child);
    
	IF class_id = 'E' THEN
    	UPDATE flights SET flights.remaining_economy_tickets = flights.remaining_economy_tickets - 1 WHERE flight_id = flight_id;
	ELSEIF class_id = 'B' THEN
		UPDATE flights SET flights.remaining_business_tickets = flights.remaining_business_tickets - 1 WHERE flight_id = flight_id;
	ELSEIF class_id = 'P' THEN
		UPDATE flights SET flights.remaining_platinum_tickets = flights.remaining_platinum_tickets - 1 WHERE flight_id = flight_id;
	END IF;

	UPDATE registered_users SET total_bookings = total_bookings + 1 WHERE user_id = user_id;

	UPDATE flights SET revenue = revenue + price WHERE flight_id = flight_id;

    COMMIT;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE cancel_ticket(ticket_id INT)
BEGIN
	DECLARE user_id INT;
	DECLARE flight_id VARCHAR(5);
	DECLARE class_id CHAR(1);
	DECLARE price INT;

	SET user_id = (SELECT user_id FROM tickets WHERE ticket_id = ticket_id);
	SET flight_id = (SELECT flight_id FROM tickets WHERE ticket_id = ticket_id);
	SET class_id = (SELECT class_id FROM tickets WHERE ticket_id = ticket_id);
	SET price = (SELECT price FROM tickets WHERE ticket_id = ticket_id);
	
	DELETE FROM tickets WHERE ticket_id = ticket_id;

	IF class_id = 'E' THEN
    	UPDATE flights SET flights.remaining_economy_tickets = flights.remaining_economy_tickets + 1 WHERE flight_id = flight_id;
	ELSEIF class_id = 'B' THEN
		UPDATE flights SET flights.remaining_business_tickets = flights.remaining_business_tickets + 1 WHERE flight_id = flight_id;
	ELSEIF class_id = 'P' THEN
		UPDATE flights SET flights.remaining_platinum_tickets = flights.remaining_platinum_tickets + 1 WHERE flight_id = flight_id;
	END IF;

	UPDATE registered_users SET total_bookings = total_bookings - 1 WHERE user_id = user_id;
    UPDATE flights SET revenue = revenue - price WHERE flight_id = flight_id;
END//
DELIMITER;


DELIMITER //
CREATE PROCEDURE flight_delay(flight_id VARCHAR(5), delay_time TIME)
BEGIN
	UPDATE flights SET depature_time = depature_time + delay_time WHERE flight_id = flight_id;
	UPDATE flights SET flight_status = 'Delayed' WHERE flight_id = flight_id;
END//
DELIMITER ;

-- TRIGGERS
DELIMITER //
CREATE TRIGGER update_user_type
AFTER UPDATE ON registered_users FOR EACH ROW
BEGIN
	UPDATE registered_users, reg_user_types
	SET  user_type = 
	(Case 
		WHEN Total_bookings >= (select bookingThresh FROM reg_user_types WHERE userTypeID = 'G')  THEN 'G'
		WHEN Total_bookings >= (select bookingThresh FROM reg_user_types WHERE userTypeID = 'F')  THEN 'F'
		ELSE 'P' END);
END//
DELIMITER ;



-- select * from Flights;
-- select * from airplanes;
-- select * from tickets;
-- SELECT * FROM Users;
-- Select * from Locations;
-- select * from AirPlane_Models;
-- select * from routes order by Route_ID;

-- select route_ID From routes Where Origin_ID = 'Origin' AND Destination_ID = 'destination';

-- Create view Airplanes_w_seasts as
-- SELECT Airplane_ID, (seat_count_First_Class+seat_count_Economy_Class+seat_count_Buisness_Class) as seat_count
-- FROM Airplanes, Airplane_Models 
-- WHERE Airplanes.Model = Airplane_Models.Model_ID;

-- SELECT Flight_ID, Airplane, Date_of_travel, Dep_time, Arr_time, (seat_count-(Tickets_Remaining_Business_Class+Tickets_Remaining_Economy_Class+Tickets_Remaining_First_Class)) as passenger_count 
-- FROM (Flights Left Join Airplanes_w_seasts on Airplane = Airplane_ID), Routes 
-- WHERE route In (select route_ID 
-- 				FROM routes 
-- 				WHERE Origin_ID = "BIA" AND Destination_ID = "JFK");
                
-- select * from Airplanes_w_seasts;
-- Drop view Airplanes_w_seasts;


INSERT INTO reg_user_types(userTypeID, userType, discount, bookingThresh) VALUES
('P', 'Pending', 0.00, 0),
('F', 'Frequent', 0.05, 5),
('G', 'Gold', 0.09, 15);