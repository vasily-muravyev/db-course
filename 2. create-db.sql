CREATE DATABASE IF NOT EXISTS example;

USE example;

CREATE TABLE IF NOT EXISTS users (
	id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Имя пользователя'
) COMMENT = 'Пользователи';

INSERT INTO users VALUES(DEFAULT, 'Vasily Muravyev');