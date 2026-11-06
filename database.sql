-- 1. Create Lookup/Independent Tables First
CREATE TABLE role (
    role_id INT PRIMARY KEY,
    role_name VARCHAR(20) NOT NULL CHECK (role_name IN ('student', 'staff'))
);

CREATE TABLE category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL CHECK (category_name IN ('water', 'electricity', 'facility', 'safety', 'sanitation','other'))
);

CREATE TABLE status (
    status_id INT PRIMARY KEY,
    status_name VARCHAR(20) NOT NULL CHECK (status_name IN ('in progress', 'resolved', 'closed'))
);

-- 2. Create Tables with Foreign Keys
CREATE TABLE `user` (
    email VARCHAR(255) PRIMARY KEY,
    password VARCHAR(255) NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES role(role_id)
);

CREATE TABLE incident (
    incident_id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category_id INT NOT NULL,
    status_id INT NOT NULL,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES category(category_id),
    FOREIGN KEY (status_id) REFERENCES status(status_id)
);

CREATE TABLE staff (
    id INT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    position VARCHAR(100) NOT NULL CHECK (position IN ('maintenance', 'security', 'cleaning', 'campus operations', 'nurse', 'other')),
    FOREIGN KEY (email) REFERENCES `user`(email)
);
-- openinary_key = 'oik_sFjKykWxIIRKckzVlcZspcKmmXEwaRvGiKHktHVpgynSyVeaqhiTCQvMCyXMPWLf'