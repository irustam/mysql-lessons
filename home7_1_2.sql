-- Часть 1
-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", 
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
USE shop
DELIMITER //

DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
  DECLARE hnow TINYINT DEFAULT HOUR(CURTIME());
  CASE
    WHEN hnow BETWEEN 0 AND 5 THEN RETURN 'Good night';
    WHEN hnow BETWEEN 6 AND 11 THEN RETURN 'Good morning';
    WHEN hnow BETWEEN 12 AND 17 THEN RETURN 'Good day';
    WHEN hnow BETWEEN 18 AND 23 THEN RETURN 'Good everning';
  END CASE;
END//

SELECT hello()//
DELIMITER ;

-- Вариант 2, если нужно более точно время определять:
USE shop
DELIMITER //

DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS TEXT DETERMINISTIC
BEGIN
  DECLARE hnow MEDIUMINT DEFAULT TIME_TO_SEC(CURTIME());
  CASE
    WHEN hnow BETWEEN 0 AND 21599 THEN RETURN 'Good night';
    WHEN hnow BETWEEN 21600 AND 43199 THEN RETURN 'Good morning';
    WHEN hnow BETWEEN 43200 AND 64799 THEN RETURN 'Good day';
    WHEN hnow BETWEEN 64800 AND 86399 THEN RETURN 'Good everning';
  END CASE;
END//

SELECT hello()//
DELIMITER ;

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. 
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. 
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

USE shop
DELIMITER //

DROP TRIGGER IF EXISTS products_check_insert//
CREATE TRIGGER products_check_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF new.name IS NULL 
    AND
	new.description IS NULL
  THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name or description cant be NULL';
  END IF;
END//

DROP TRIGGER IF EXISTS products_check_update//
CREATE TRIGGER products_check_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  IF new.name IS NULL 
    AND
	new.description IS NULL
  THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Name or description cant be NULL';
  END IF;
END//

INSERT INTO products (price, catalog_id) VALUES (1200, 1)//
UPDATE products SET name = NULL, description = NULL WHERE id=1//

DELIMITER ;


-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. 
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. 
-- Вызов функции FIBONACCI(10) должен возвращать число 55.
USE shop
DELIMITER //

DROP FUNCTION IF EXISTS FIBONACCI//
CREATE FUNCTION FIBONACCI (val INT)
RETURNS INT DETERMINISTIC
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE x INT DEFAULT 0;
  DECLARE y INT DEFAULT 1;
  WHILE i <= val DO
    SET y = x + y;
    SET x = y - x;
    SET i = i + 1;
  END WHILE;
  RETURN x;
END//

SELECT FIBONACCI(7)//
DELIMITER ;

-- Часть 2
-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs
-- помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

DELIMITER //

DROP TABLE IF EXISTS logs//
CREATE TABLE logs (
  table_name VARCHAR(255) NOT NULL,
  value_id INT UNSIGNED NOT NULL,
  value_name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=ARCHIVE//


DROP TRIGGER IF EXISTS products_log//
CREATE TRIGGER products_log AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, value_id, value_name, created_at) VALUES ('products', new.id, new.name, new.created_at);
END//

DROP TRIGGER IF EXISTS catalogs_log//
CREATE TRIGGER catalogs_log AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, value_id, value_name) VALUES ('catalogs', new.id, new.name);
END//

DROP TRIGGER IF EXISTS users_log//
CREATE TRIGGER users_log AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, value_id, value_name, created_at) VALUES ('users', new.id, new.name, new.created_at);
END//

INSERT INTO products (name, price, catalog_id) VALUES ('Pentium', 1200, 1)//
INSERT INTO catalogs (name) VALUES ('New +')//
INSERT INTO users (name) VALUES ('Bobby')//

SELECT * FROM logs//

DELIMITER ;

-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
-- я создал файл users_data2.csv с 1 млн. записей, подгрузил его в специальную папку /var/lib/mysql-files/ и добавляю его в БД:
USE SHOP
LOAD DATA INFILE '/var/lib/mysql-files/users_data2.csv' 
  INTO TABLE users
  FIELDS TERMINATED BY ','
  (name);
  
SELECT COUNT(*) FROM users;
