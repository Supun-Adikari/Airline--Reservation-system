DROP DATABASE IF EXISTS `airlineReservationSystem`;
CREATE DATABASE `airlineReservationSystem`; 
USE `airlineReservationSystem`;
SET @@session.time_zone='+05:30';

CREATE TABLE admins (
  id INT PRIMARY KEY,
  username VARCHAR(30) NOT NULL,
  email VARCHAR(30) NOT NULL,
  password_ VARCHAR(30) NOT NULL
);


CREATE TABLE aircraft_models(
	model_id VARCHAR(5) PRIMARY KEY,
	model VARCHAR(15) NOT NULL,
	no_of_seats INT NOT NULL DEFAULT 0,
	aircraft_count INT NOT NULL DEFAULT 0);


CREATE TABLE aircrafts(
	aircraft_id VARCHAR(15) PRIMARY KEY,
	model VARCHAR(5) NOT NULL,

	FOREIGN KEY(model) REFERENCES aircraft_models(model_id) 
);


CREATE TABLE seating_class(
	class_id CHAR(1) PRIMARY KEY,
	class VARCHAR(10) ,
	price_multiplier NUMERIC(2, 1) NOT NULL);


CREATE TABLE airports (
	id INT PRIMARY KEY, -- 1-100:Countries, 101-1000:States, 1001-..:Airports
	IATA_code VARCHAR(3) UNIQUE,
	country_city VARCHAR(30) NOT NULL,
	parent_id INT,
	
    FOREIGN KEY(parent_id) REFERENCES airports(id));


CREATE TABLE routes(
	route_id VARCHAR(5) PRIMARY KEY,
	origin_id INT,
	destination_id INT,
	base_price NUMERIC(8,2),
	
	FOREIGN KEY(origin_id) REFERENCES airports(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(destination_id) REFERENCES airports(id) ON UPDATE CASCADE ON DELETE CASCADE
);

-- on update on delete removed
CREATE TABLE flights(
	flight_id VARCHAR(5) PRIMARY KEY,
	aircraft_id VARCHAR(15),
	route_id VARCHAR(5),
	flight_date DATE,
	depature_time TIME,
	remaining_tickets INT  NOT NULL DEFAULT 0,
	revenue NUMERIC(20,2) NOT NULL DEFAULT 0,
	flight_status VARCHAR(10) NOT NULL DEFAULT 'Scheduled',
	
	FOREIGN KEY(aircraft_id) REFERENCES aircrafts(aircraft_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(route_id) REFERENCES routes(route_id) ON UPDATE CASCADE ON DELETE CASCADE,
    UNIQUE KEY (aircraft_id, flight_date, depature_time),

	CHECK (remaining_tickets >= 0)
);


CREATE TABLE reg_user_types ( 
	userTypeID CHAR(1) DEFAULT 'P', -- Pending, Frequent, Gold
    userType  VARCHAR(10),
	discount NUMERIC(3, 2) NOT NULL DEFAULT 0.00 , -- 0.00, 0.05, 0.09
	bookingThresh INT NOT NULL DEFAULT 0,

	PRIMARY KEY(userTypeID),
	
	CHECK (discount >= 0 AND bookingThresh >= 0)
);


-- both guest and registered users data included  
CREATE TABLE users(
    id int PRIMARY KEY AUTO_INCREMENT,
	title VARCHAR(4),
	f_Name VARCHAR(30) NOT NULL,
    l_Name VARCHAR(30) NOT NULL,
	DoB DATE NOT NULL, -- YYYY-MM-DD
	email VARCHAR(30) NOT NULL,
	country VARCHAR(20) NOT NULL,	
	user_category CHAR(1) NOT NULL DEFAULT 'G'); -- G-Guest, R-Registered
            
-- register weddi users ekatai registered users ekatai dekatama data watenawa. issella update wenne user dable eka
-- guestlage user eka witharai update wenne
CREATE TABLE registered_users(
	id int PRIMARY KEY,
	username VARCHAR(30) NOT NULL UNIQUE,
	password_ VARCHAR(100) NOT NULL,
	address_ VARCHAR(100),
	date_registered DATETIME DEFAULT CURRENT_TIMESTAMP, -- YYYY-MM-DD HH:MM:SS
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
	seat_id VARCHAR(5),
	price NUMERIC(8,2), -- NOT NULL DEFAULT 0
	user_id INT,
	adult_child ENUM("A", "C"),
	
	FOREIGN KEY(flight_id) REFERENCES flights(flight_id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY(class_id) REFERENCES seating_class(class_id) ON UPDATE CASCADE ON DELETE RESTRICT,

	UNIQUE KEY seat_allocation(flight_id, class_id, seat_id)
);


CREATE TABLE sessions( 	
	session_id VARCHAR(50),
	user_id INT,
	end_time DATETIME,

	PRIMARY KEY(session_id, user_id),
	FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE
);


-- VIEWS
CREATE VIEW total_revenue_by_type AS
SELECT aircraft_models.model AS aircraft_type, SUM(flights.revenue) AS total_revenue FROM
flights LEFT JOIN (aircrafts LEFT JOIN aircraft_models ON aircrafts.model = aircraft_models.model_id) ON flights.aircraft_id = aircrafts.aircraft_id GROUP BY aircrafts.model;


-- FUNCTIONS
-- needs in the procedure new ticket to update the tickets table's price
DELIMITER //
CREATE FUNCTION get_priceOfTicket(user_id INT, rute_id VARCHAR(5), class CHAR(1))
RETURNS NUMERIC(8,2)
DETERMINISTIC
BEGIN
DECLARE price NUMERIC(8,2) DEFAULT 0;
DECLARE dscount NUMERIC(3, 2) DEFAULT 0.00;
DECLARE usr_type CHAR(1);
SET price = (SELECT price_multiplier FROM seating_class WHERE class_id = class) * (SELECT base_price FROM routes WHERE route_id = rute_id);
IF (SELECT user_category FROM users WHERE id = user_id LIMIT 1) Like'R' THEN
	SET usr_type = (SELECT user_type FROM registered_users WHERE id = user_id);
	SET dscount = (SELECT discount FROM reg_user_types WHERE userTypeID = usr_type);
END IF;
SET price = price - (price * dscount);
RETURN price;
END//
DELIMITER ;



-- PROCEDURES
DELIMITER //
CREATE PROCEDURE new_user_registered(title VARCHAR(4), f_name VARCHAR(30), l_name VARCHAR(30), DoB DATE, email VARCHAR(30), country VARCHAR(30), username VARCHAR(30), password_ VARCHAR(100), address_ VARCHAR(100))
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
CREATE PROCEDURE create_new_ticket(fligt_id VARCHAR(5), class_id CHAR(1), seat_id VARCHAR(5), u_id INT, adult_child CHAR(1))
BEGIN
	DECLARE price NUMERIC(8,2);
    DECLARE rute_id VARCHAR(5);
	START TRANSACTION;	
	
    SET rute_id = (SELECT route_id FROM flights WHERE flight_id = fligt_id LIMIT 1);
    SET price = get_priceOfTicket(u_id, rute_id, class_id);
    
    INSERT INTO tickets(flight_id, class_id, seat_id, price, user_id, adult_child) VALUES (fligt_id, class_id, seat_id, price, u_id, adult_child);
    
    UPDATE flights SET flights.remaining_tickets = flights.remaining_tickets - 1 WHERE flight_id = fligt_id;
	UPDATE registered_users SET total_bookings = total_bookings + 1 WHERE id = u_id;
	UPDATE flights SET revenue = revenue + price WHERE flight_id = fligt_id;

    COMMIT;
END//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_passenger_details(IN fligt_id VARCHAR(5))
BEGIN
    SET @sql = CONCAT('CREATE VIEW user_age AS SELECT user_id, adult_child FROM tickets WHERE flight_id = "', fligt_id, '"');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SELECT title, f_name, l_name, email, country, adult_child FROM (user_age LEFT JOIN users ON user_age.user_id = users.id);
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_passenger_count(from_ DATE, to_ DATE, where_ VARCHAR(30))
BEGIN
	DECLARE dest_id INT;
    SET dest_id = (SELECT id FROM airports WHERE country_city = where_);
    SELECT COUNT(user_id) AS passenger_count FROM (flights NATURAL JOIN tickets NATURAL JOIN routes)
				WHERE (flights.flight_date >= from_ AND 
						flights.flight_date <= to_ AND
                        routes.destination_id = dest_id);
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_no_of_bookings(from_ DATE, to_ DATE)
BEGIN
	SET @sql = CONCAT('CREATE VIEW tickets_in_range AS SELECT ticket_id, user_id FROM tickets WHERE booking_time >= "', from_, '" AND booking_time <= "', to_,'"');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SELECT * FROM tickets_in_range;
    SELECT user_category, count(user_category) FROM (tickets_in_range LEFT JOIN users ON tickets_in_range.user_id = users.id) GROUP BY user_category;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE get_old_passengers(origin VARCHAR(30), destination VARCHAR(30))
BEGIN
	DECLARE orign_id INT;
    DECLARE destnation_id INT;
	DECLARE rute_id VARCHAR(5);
    SET orign_id = (SELECT id FROM airports WHERE country_city = origin LIMIT 1);
    SET destnation_id = (SELECT id FROM airports WHERE country_city = destination LIMIT 1);
    SET rute_id = (SELECT route_id FROM routes WHERE (origin_id = orign_id AND destination_id = destnation_id));
    SELECT flight_id, (no_of_seats - remaining_tickets) AS passengers_travelled FROM
																				routes NATURAL JOIN (flights LEFT JOIN (aircrafts LEFT JOIN aircraft_models ON aircrafts.model = aircraft_models.model_id) ON flights.aircraft_id = aircrafts.aircraft_id) WHERE route_id = rute_id AND flights.flight_date < CURRENT_DATE();
    
END //
DELIMITER ;




-- TRIGGERS
DELIMITER //
CREATE TRIGGER update_user_type
BEFORE UPDATE ON registered_users FOR EACH ROW
BEGIN
	DECLARE usr_type CHAR(1);
    DECLARE tot_book INT DEFAULT 0;
    SET tot_book = NEW.total_bookings;
	SET usr_type = 
		(CASE 
			WHEN tot_book >= (SELECT bookingThresh FROM reg_user_types WHERE userTypeID = 'G')  THEN 'G'
			WHEN tot_book >= (SELECT bookingThresh FROM reg_user_types WHERE userTypeID = 'F')  THEN 'F'
			ELSE 'P' END);
    IF !(NEW.total_bookings <=> OLD.total_bookings) THEN
        SET NEW.user_type = usr_type;
   END IF;
END//
DELIMITER ;


DELIMITER //
CREATE TRIGGER put_remaining_tickets_to_new_flight
BEFORE INSERT ON flights
FOR EACH ROW
BEGIN
  SET @seats =  (SELECT no_of_seats FROM 
                (aircrafts JOIN aircraft_models ON aircrafts.model = aircraft_models.model_id)
                WHERE aircraft_id = NEW.aircraft_id);
  SET NEW.remaining_tickets = @seats;
END //
DELIMITER ;

