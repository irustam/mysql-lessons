​-- Часть 1
-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
-- Вариант 1
SELECT id, name FROM users WHERE id IN (SELECT user_id FROM orders);

-- Вариант 2
SELECT DISTINCT u.id, u.name FROM users AS u, orders AS o WHERE u.id = o.user_id;

-- ​2. Выведите список товаров products и разделов catalogs, который соответствует товару.
-- Вариант 1
SELECT id, name, (SELECT catalogs.name FROM catalogs WHERE products.catalog_id = catalogs.id) AS c FROM products;

-- Вариант 2
SELECT p.id, p.name, c.name AS catalog FROM products AS p, catalogs AS c WHERE p.catalog_id = c.id;

-- 3. ​(по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.
SELECT id, (SELECT c.name FROM cities AS c WHERE flights.`from` = c.label) AS "from", (SELECT c.name FROM cities AS c WHERE flights.`to` = c.label) AS "to" FROM flights;

-- Часть 2
-- 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
USE shop;
START TRANSACTION;
-- Я предполагаю, что структура таблиц одинаковая и id не надо переносить, поскольку оно автоинкрементируемое:
INSERT INTO sample.users (name) SELECT users.name FROM users WHERE users.id=1;
DELETE FROM users WHERE id=1;
COMMIT;

-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
CREATE VIEW prod AS SELECT p.name AS name, c.name AS catalog FROM products AS p, catalogs AS c WHERE p.catalog_id=c.id;

-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. 
-- Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
CREATE TABLE (id SERIAL, created_at DATE);
INSERT INTO tbl1 (created_at) VALUES ('2018-08-01'),('2016-08-04'),('2018-08-16'),('2018-08-17');
SET @i := 0;
SELECT 
	@i := @i + 1 AS august_date, 
	IF(
		(SELECT id 
			FROM tbl1 
			WHERE @i=DAYOFMONTH(tbl1.created_at)
		) IS NOT NULL,
		1,
		0
	) AS checking 
	FROM 
		(SELECT 1 a
		UNION ALL 
		SELECT 2 
		UNION ALL 
		SELECT 3 
		UNION ALL 
		SELECT 4 
		UNION ALL 
		SELECT 5 
		UNION ALL 
		SELECT 6
		) x
	CROSS JOIN  
		(SELECT 1 b 
		UNION ALL 
		SELECT 2 
		UNION ALL 
		SELECT 3 
		UNION ALL 
		SELECT 4  
		UNION ALL 
		SELECT 5 
		UNION ALL 
		SELECT 6
		) y 
	ORDER BY august_date 
	LIMIT 31;


-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
START TRANSACTION;
CREATE VIEW saveme AS SELECT id FROM users ORDER BY updated_at DESC LIMIT 5;
DELETE FROM users WHERE id NOT IN (SELECT * FROM saveme);
COMMIT;

-- Часть 3
-- 1. Создайте двух пользователей которые имеют доступ к базе данных shop. 
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных, 
-- второму пользователю shop — любые операции в пределах базы данных shop.
CREATE USER 'shop_read'@'localhost' IDENTIFIED BY 'new%P123';
CREATE USER 'shop'@'localhost' IDENTIFIED BY 'new%P123';
GRANT SELECT ON shop.* TO 'shop_read'@'localhost';
GRANT ALL ON shop.* TO 'shop'@'localhost';


-- 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. 
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. 
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
CREATE TABLE accounts (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, password VARCHAR(255) NOT NULL);
INSERT INTO accounts (name, password) VALUES ('Bob', '123'), ('Ben', '234'), ('Dan', '345');
CREATE VIEW username AS SELECT id, name FROM accounts;
CREATE USER 'user_read'@'localhost' IDENTIFIED BY 'new%P123';
GRANT SELECT ON sample.username TO 'user_read'@'localhost';
