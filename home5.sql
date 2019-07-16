​-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
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
