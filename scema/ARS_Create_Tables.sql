-- drop database airlineReservationSystem;
create database airlineReservationSystem;
use airlineReservationSystem;

CREATE TABLE aircraft_models (
  id INT NOT NULL,
  model VARCHAR(30) NOT NULL,
  seating_capacity INT NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE aircrafts (
  id VARCHAR(30) PRIMARY KEY,
  model_id INT NOT NULL,
  FOREIGN KEY (model_id) REFERENCES aircraft_models(id)
);

CREATE TABLE airports (
  id INT PRIMARY KEY,
  IATA_code CHAR(3) NOT NULL,
  city_country VARCHAR(255) NOT NULL,
  parent_id INT,
  FOREIGN KEY (parent_id) REFERENCES airports(id)
);

CREATE TABLE flights (
  id INT PRIMARY KEY AUTO_INCREMENT,
  origin INT NOT NULL,
  destination INT NOT NULL,
  scheduled_time DATETIME NOT NULL,
  aircraft_id VARCHAR(30) NOT NULL,
  FOREIGN KEY (origin) REFERENCES airports(id),
  FOREIGN KEY (destination) REFERENCES airports(id),
  FOREIGN KEY (aircraft_id) REFERENCES aircrafts(id)
);

CREATE TABLE admins (
  id INT PRIMARY KEY,
  uname VARCHAR(30) NOT NULL,
  email VARCHAR(30) NOT NULL,
  pwd VARCHAR(30) NOT NULL
);

CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  uname VARCHAR(30) NOT NULL,
  email VARCHAR(30) NOT NULL,
  pwd VARCHAR(30) NOT NULL,
  full_name VARCHAR(255) NOT NULL,
  age INT NOT NULL,
  user_type ENUM('frequent', 'gold') NOT NULL,
  no_of_bookings INT NOT NULL
);

CREATE TABLE passengers (
  id INT PRIMARY KEY AUTO_INCREMENT,
  passenger_name VARCHAR(255) NOT NULL,
  age INT NOT NULL,
  passenger_type ENUM('guest', 'user') NOT NULL,
  flight_id INT NOT NULL,
  user_id INT,
  FOREIGN KEY (flight_id) REFERENCES flights(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE bookings (
  id INT PRIMARY KEY AUTO_INCREMENT,
  flight_id INT NOT NULL,
  passenger_id INT NOT NULL,
  seat VARCHAR(10) NOT NULL,
  traveler_class ENUM('economy', 'business', 'platinum') NOT NULL,
  booking_status ENUM('completed', 'incomplete') NOT NULL,
  FOREIGN KEY (flight_id) REFERENCES flights(id),
  FOREIGN KEY (passenger_id) REFERENCES passengers(id)
);

