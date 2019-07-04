CREATE DATABASE media;
USE media;
CREATE TABLE media (
    id          INT PRIMARY KEY AUTO_INCREMENT,
    name        varchar(255) NOT NULL,
    description TEXT,
    media_type  ENUM('photo', 'audio', 'video'),
    url_path    varchar(255) NOT NULL  UNIQUE
);
CREATE TABLE users (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    media_id INT NOT NULL REFERENCES media (id) 
);
CREATE TABLE keywords (
    id       INT PRIMARY KEY AUTO_INCREMENT,
    name     varchar(255) NOT NULL,
    media_id INT REFERENCES media (id) 
);
