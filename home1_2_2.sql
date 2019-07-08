CREATE DATABASE IF NOT EXISTS media;
USE media;

DROP TABLE IF EXISTS keywords_links;
DROP TABLE IF EXISTS keywords;
DROP TABLE IF EXISTS media;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS media_types;

CREATE TABLE users (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name       varchar(255) NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT NOW() ON UPDATE NOW(),
    PRIMARY KEY (id)
);

CREATE TABLE media_types (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name     varchar(100) NOT NULL UNIQUE,
    PRIMARY KEY (id)
);

CREATE TABLE media (
    id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name          varchar(255) NOT NULL,
    description   TEXT,
    media_type_id INT UNSIGNED NOT NULL,
    url_path      varchar(255) NOT NULL UNIQUE,
    user_id       INT UNSIGNED NOT NULL,
    created_at    DATETIME DEFAULT NOW(),
    updated_at    DATETIME DEFAULT NOW() ON UPDATE NOW(),
    PRIMARY KEY (id),
    CONSTRAINT media_user_id FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT media_media_type_id FOREIGN KEY (media_type_id) REFERENCES media_types(id)
);

CREATE TABLE keywords (
    id       INT UNSIGNED NOT NULL AUTO_INCREMENT,
    name     varchar(255) NOT NULL,
    PRIMARY KEY (id)  
);

CREATE TABLE keywords_links (
    key_id       INT UNSIGNED NOT NULL,
    media_id     INT UNSIGNED NOT NULL,
    PRIMARY KEY (key_id, media_id),
    CONSTRAINT keywords_links_key_id FOREIGN KEY (key_id) REFERENCES keywords(id),
    CONSTRAINT keywords_links_media_id FOREIGN KEY (media_id) REFERENCES media(id)
);
