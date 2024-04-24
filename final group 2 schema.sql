-- Start by dropping tables in the reverse order of dependencies
DROP TABLE IF EXISTS managing CASCADE;
DROP TABLE IF EXISTS property_amenities CASCADE;
DROP TABLE IF EXISTS expense CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS client_feedback CASCADE;
DROP TABLE IF EXISTS transaction CASCADE;
DROP TABLE IF EXISTS listing CASCADE;
DROP TABLE IF EXISTS property CASCADE;
DROP TABLE IF EXISTS school CASCADE;
DROP TABLE IF EXISTS client CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS personal_info CASCADE;
DROP TABLE IF EXISTS office CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS neighborhood CASCADE;


CREATE TABLE neighborhood (
    neighborhood_id INT,
    neighborhood_name VARCHAR(100) NOT NULL,
    crime_rate NUMERIC(3,1) CHECK (crime_rate BETWEEN 0.0 AND 10.0),
    PRIMARY KEY (neighborhood_id)
);

CREATE TABLE address (
    address_id INT,
    state VARCHAR(100),
    city VARCHAR(100),
    street VARCHAR(200),
    zip_code VARCHAR(10),
    neighborhood_id INT,
    PRIMARY KEY (address_id),
    FOREIGN KEY (neighborhood_id) REFERENCES neighborhood(neighborhood_id)
);

CREATE TABLE office (
    office_id INT,
	office_name VARCHAR(100) NOT NULL,
    address_id INT,
    PRIMARY KEY (office_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE personal_info (
    personal_info_id INT,
    name VARCHAR(100),
    phone_number VARCHAR(50),
    email VARCHAR(50),
    PRIMARY KEY (personal_info_id)
);

CREATE TABLE employee (
    employees_id INT,
    office_id INT,
    personal_info_id INT,
    PRIMARY KEY (employees_id),
    FOREIGN KEY (office_id) REFERENCES office(office_id),
    FOREIGN KEY (personal_info_id) REFERENCES personal_info(personal_info_id)
);

CREATE TABLE client (
    clients_id INT,
    preferred_home_type VARCHAR(50) ,
    personal_info_id INT,
    PRIMARY KEY (clients_id),
    FOREIGN KEY (personal_info_id) REFERENCES personal_info(personal_info_id)
);

CREATE TABLE school (
    school_id INT,
    school_name VARCHAR(100) NOT NULL,
    school_rating NUMERIC(3,1) CHECK (school_rating BETWEEN 0.0 AND 10.0),
    school_type VARCHAR(100) NOT NULL,
    school_level VARCHAR(100) NOT NULL,
    address_id INT,
    PRIMARY KEY (school_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE property (
    property_id INT,
    address_id INT,
    bedrooms INT NOT NULL,
    bathrooms INT NOT NULL,
    sqft INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT,
    PRIMARY KEY (property_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id)
);

CREATE TABLE listing (
    listing_id BIGINT,
    property_id INT,
    listing_date DATE NOT NULL,
    list_price NUMERIC(15,2) NOT NULL,
    sale_type VARCHAR(50),
    PRIMARY KEY (listing_id),
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE transaction (
    transaction_id INT,
    listing_id BIGINT UNIQUE,
    employees_id INT,
    clients_id INT,
    time DATE NOT NULL,
    price NUMERIC(15,2) NOT NULL,
    revenues NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (transaction_id, listing_id),
    FOREIGN KEY (listing_id) REFERENCES listing(listing_id),
    FOREIGN KEY (employees_id) REFERENCES employee(employees_id),
    FOREIGN KEY (clients_id) REFERENCES client(clients_id)
);

CREATE TABLE client_feedback (
    clients_id INT,
    employees_id INT,
    time TIMESTAMP,
    rating INT NOT NULL CHECK (rating BETWEEN 0 AND 10),
    comment TEXT,
    PRIMARY KEY (clients_id, employees_id, time),
    FOREIGN KEY (employees_id) REFERENCES employee(employees_id),
    FOREIGN KEY (clients_id) REFERENCES client(clients_id)
);

CREATE TABLE appointments (
    employees_id INT,
    clients_id INT,
    time DATE,
    listing_id BIGINT NOT NULL,
    PRIMARY KEY (employees_id, clients_id, time),
    FOREIGN KEY (employees_id) REFERENCES employee(employees_id),
    FOREIGN KEY (clients_id) REFERENCES client(clients_id),
    FOREIGN KEY (listing_id) REFERENCES listing(listing_id)
);

CREATE TABLE expense (
    expense_id INT,
    office_id INT,
    expense_amount NUMERIC(10,2),
    expense_type VARCHAR(100) NOT NULL,
    expense_date DATE,
    PRIMARY KEY (expense_id),
    FOREIGN KEY (office_id) REFERENCES office(office_id)
);

CREATE TABLE property_amenities (
    property_id INT,
    amenities VARCHAR(100) NOT NULL,
    PRIMARY KEY (property_id, amenities),
    FOREIGN KEY (property_id) REFERENCES property(property_id)
);

CREATE TABLE managing (
    employees_id INT,
    manager_id INT,
    PRIMARY KEY (employees_id),
    FOREIGN KEY (employees_id) REFERENCES employee(employees_id),
    FOREIGN KEY (manager_id) REFERENCES employee(employees_id)
);

SELECT * FROM property