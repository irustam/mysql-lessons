-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- Я изменил запрос, убрав l.subject_type_id = 1. Но избавиться от хардкода здесь все равно не получится, поскольку 
-- такова структура БД. Мне в любом случае надо указать, что я выбираю только лайки по медиафайлам.
-- И в этом варианте у меня добавился еще один вложенный запрос. Я пробовал вместо него добавить третий JOIN,
-- но добиться правильных результатов у меня не получилось с ним.

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
			AND l.subject_type_id = 
				(SELECT s.id 
					FROM subject_types AS s 
					WHERE s.name = 'media'
				)
		GROUP BY p.user_id
		ORDER BY p.birthday DESC LIMIT 10
	) a
;



/*
Предыдущая версия
 Без вложенного запроса здесь я не смог обойтись. Как и в прошлый раз, я считаю только лайки по медиафайлам:
 
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
*/