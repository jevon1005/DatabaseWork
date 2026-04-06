DROP TABLE IF EXISTS orders, trains, passengers, users, admins, stations, cities CASCADE;

CREATE TABLE cities (
    city_id SERIAL PRIMARY KEY,
    city_name VARCHAR(50) UNIQUE NOT NULL,
    province VARCHAR(50),
    longitude DOUBLE PRECISION,
    latitude DOUBLE PRECISION
);

CREATE TABLE stations (
    station_id SERIAL PRIMARY KEY,
    station_name VARCHAR(100) UNIQUE NOT NULL,
    city_id INT REFERENCES cities(city_id),
    province VARCHAR(50)
);

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    locked BOOLEAN DEFAULT FALSE,
    full_name VARCHAR(50),
    phone VARCHAR(20),
    id_card VARCHAR(18)
);

CREATE TABLE admins (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    locked BOOLEAN DEFAULT FALSE
);

CREATE TABLE passengers (
    passenger_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    id_number VARCHAR(18) UNIQUE NOT NULL,
    phone VARCHAR(20),
    passenger_type VARCHAR(20)
);

CREATE TABLE trains (
    train_id SERIAL PRIMARY KEY,
    train_number VARCHAR(20) UNIQUE NOT NULL,
    start_station_id INT REFERENCES stations(station_id),
    end_station_id INT REFERENCES stations(station_id),
    seat_config TEXT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    train_id INT REFERENCES trains(train_id),
    passenger_id INT REFERENCES passengers(passenger_id),
    start_station_id INT REFERENCES stations(station_id),
    end_station_id INT REFERENCES stations(station_id),
    seat_level VARCHAR(20),
    carriage_number INT,
    seat_row INT,
    seat_col INT,
    price DECIMAL(10,2) NOT NULL,
    travel_date DATE,
    status VARCHAR(20) DEFAULT '待乘坐',
    timetable_snapshot TEXT
);