-- 1. Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

-- На примере пользователя 1. Поскольку у нас в таблице friendship друг может быть записан как в user_id, 
-- так и в friend_id, здесь обязательно нужен UNION:
SELECT friend FROM
(SELECT f.user_id, f.friend_id AS friend, m.from_user_id, m.to_user_id 
	FROM 
		friendship AS f
		JOIN
			messages AS m
			ON (m.from_user_id = f.friend_id 
				AND 
				m.to_user_id = f.user_id)
				OR
				(m.from_user_id = f.user_id 
				AND 
				m.to_user_id = f.friend_id)
	WHERE 
		f.user_id = 1
		AND
		f.status != 0
		AND
		f.confirmed_at IS NOT NULL	
UNION ALL
SELECT f.friend_id, f.user_id AS friend, m.from_user_id, m.to_user_id 
	FROM 
		friendship AS f
		JOIN
			messages AS m
			ON (m.from_user_id = f.friend_id 
				AND 
				m.to_user_id = f.user_id)
				OR
				(m.from_user_id = f.user_id 
				AND 
				m.to_user_id = f.friend_id)
	WHERE 
		f.friend_id = 1
		AND
		f.status != 0
		AND
		f.confirmed_at IS NOT NULL
) a
GROUP BY friend
ORDER BY COUNT(*) DESC LIMIT 1
;



-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- Без вложенного запроса здесь я не смог обойтись. Как и в прошлый раз, я считаю только лайки по медиафайлам:
SELECT SUM(total_likes) AS total
FROM
	(SELECT
		p.user_id,
		COUNT(l.to_subject_id) AS total_likes
		FROM 
			profiles AS p
			LEFT JOIN
				media AS m 
				ON p.user_id = m.user_id
			LEFT JOIN
				likes AS l
				ON l.to_subject_id = m.id
				AND
				l.subject_type_id = 1
		GROUP BY p.user_id
		ORDER BY birthday DESC LIMIT 10
	) a
;


-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?


SELECT
	IF(p.sex=1,'пол 1','пол 2') AS sex ,
	COUNT(l.from_user_id) AS total
	FROM 
		profiles AS p
		JOIN
			likes AS l
			ON l.from_user_id = p.user_id
	GROUP BY p.sex
	ORDER BY total DESC 
	LIMIT 1
;



-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

-- За активность я буду считать: кол-во лайков, кол-во медиафайлов и кол-во сообщений пользователя.
SELECT 
	u.id,
	SUM(if(m.id IS NOT NULL,1,0) +
		if(l.to_subject_id IS NOT NULL,1,0) +
		if(ms.to_user_id IS NOT NULL,1,0)
		) AS total
	FROM
		users AS u
		LEFT JOIN
			media AS m
			ON u.id = m.user_id
		LEFT JOIN
			likes AS l
			ON u.id = l.from_user_id
		LEFT JOIN
			messages AS ms
			ON u.id = ms.from_user_id
	GROUP BY u.id
	ORDER BY 
		total, 
		u.id
	LIMIT 10
;
