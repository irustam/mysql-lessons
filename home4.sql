-- 1. Пусть задан некоторый пользователь. 
-- Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.

-- На примере пользователя 1
SELECT 
  friend, 
  COUNT(*) AS total 
  FROM 
    (SELECT from_user_id AS friend 
	  FROM messages 
	  WHERE to_user_id = 1 
	UNION ALL 
	SELECT to_user_id AS friend 
	  FROM messages 
	  WHERE from_user_id = 1
	) a 
  GROUP BY friend 
  HAVING friend IN 
    (SELECT user_id AS myfriend 
	  FROM friendship 
	  WHERE friend_id = 1 
	    AND status != 0 
		AND confirmed_at IS NOT NULL 
	UNION 
	SELECT friend_id AS myfriend 
	  FROM friendship 
	  WHERE user_id = 1 
	    AND status != 0 
		AND confirmed_at IS NOT NULL
	) 
  ORDER BY total DESC 
  LIMIT 1
;



-- 2. Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

-- Здесь я посчитал кол-во лайков по медиафайлам пользователя дважды, чтобы показать, 
-- что второй раз (и в третий и т.д.) можно подставить в subject_type_id другое значение, поменять соответственно таблицу media 
-- на другую (например, posts) и тем самым, сложить лайки за медиафайлы с лайками за посты и другие сущности.

SELECT SUM(t) AS total 
  FROM 
    (SELECT COUNT(*) AS t 
	  FROM likes 
	  WHERE subject_type_id=1 
	    AND to_subject_id IN 
		  (SELECT id 
		    FROM media 
			WHERE user_id IN 
			  (SELECT user_id 
			    FROM 
				  (SELECT 
				    user_id, 
					TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age 
					FROM profiles 
					ORDER BY age 
					LIMIT 10
					) a
			  )
		  ) 
	UNION ALL 
	SELECT COUNT(*) AS t 
	  FROM likes 
	  WHERE subject_type_id=1 
	    AND to_subject_id IN 
		  (SELECT id 
		    FROM media 
			WHERE user_id IN 
			  (SELECT user_id 
			    FROM 
				  (SELECT 
				    user_id, 
					TIMESTAMPDIFF(YEAR, birthday, NOW()) AS age 
					FROM profiles 
					ORDER BY age 
					LIMIT 10
					) b
			  )
		  )
	) c
;


-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?


SELECT 
  IF(
	(SELECT COUNT(*) AS amount 
      FROM likes 
	  WHERE from_user_id IN 
		(SELECT user_id 
		  FROM profiles 
		  WHERE sex = 1
		)
	) 
	> 
	(SELECT COUNT(*) AS amount 
	  FROM likes 
      WHERE from_user_id IN 
		(SELECT user_id 
	      FROM profiles 
		  WHERE sex = 2
		)
	),
	'пол 1',
	'пол 2'
  ) 
  AS sex
;



-- 4. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

-- За активность я буду считать: кол-во лайков, кол-во медиафайлов и кол-во сообщений пользователя. 
-- Я посчитал сколько пользователей совсем не имеют никакую активность и сколько активности имеют все, кто хоть как-то активен. Из них выбрал наименее активных

SELECT 
  user, 
  total 
  FROM 
    (SELECT 
	  id AS user, 
	  0 AS total 
	  FROM users 
	  WHERE id NOT IN 
	    (SELECT user_id AS user 
		  FROM media 
		UNION ALL 
		SELECT from_user_id AS user 
		  FROM likes 
		UNION ALL 
		SELECT from_user_id AS user 
		FROM messages
		) 
	UNION 
	SELECT 
	  user, 
	  COUNT(*) AS total 
	  FROM 
	    (SELECT user_id AS user 
		  FROM media 
		UNION ALL 
		SELECT from_user_id AS user 
		  FROM likes 
		UNION ALL 
		SELECT from_user_id AS user 
		FROM messages
		) a 
	GROUP BY user
	) b 
  ORDER BY total 
  LIMIT 10
;

