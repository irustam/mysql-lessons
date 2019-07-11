-- Часть 1
-- Задача 1
-- Вариант 1 – отдельными запросами: 
UPDATE users SET created_at = NOW() WHERE created_at IS NULL;
UPDATE users SET updated_at = NOW() WHERE updated_at IS NULL;
-- Вариант 2 – с помощью case
UPDATE users SET created_at = CASE WHEN created_at IS NULL THEN NOW() ELSE created_at END, updated_at = CASE WHEN updated_at IS NULL THEN NOW() ELSE updated_at END WHERE created_at IS NULL OR updated_at IS NULL;

-- Задача 2	
UPDATE users SET created_at = DATE_FORMAT(STR_TO_DATE(created_at,'%d.%m.%Y %H:%i'), '%Y-%m-%d %H:%i:00');
ALTER TABLE users MODIFY created_at DATETIME, MODIFY updated_at DATETIME;

-- Задача 3
SELECT * FROM storehouses_products ORDER BY IF(value=0, 1, 0), value;

-- Задача 4
SELECT * FROM users WHERE MONTHNAME(birthday_at) IN ('may', 'august');

-- Задача 5.
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- Часть 2
-- Задача 1
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) FROM users;

-- Задача 2
SELECT DATE_FORMAT(MAKEDATE(YEAR(NOW()), DAYOFYEAR(birthday_at)), '%W') as week_day, COUNT(*) as birthdays FROM users GROUP BY week_day;

-- Задача 3
CREATE TABLE value_table (value int);
INSERT INTO value_table VALUES(1);
INSERT INTO value_table VALUES(2);
INSERT INTO value_table VALUES(3);
INSERT INTO value_table VALUES(4);
INSERT INTO value_table VALUES(5);
SELECT ROUND(EXP(SUM(LOG(value)))) FROM value_table;

