/*

Задание:

Проанализировать запросы, которые выполнялись на занятии, определить возможные
корректировки и/или улучшения (JOIN пока не применять).
*/

-- там где поставлю + ничего менять не вижу смысла
-- в остальных местах напишу комментарий по возможной корретировке

-- +
SELECT * FROM users LIMIT 1;
SELECT * FROM users WHERE id = 1;

-- неправильно выбрана таблица users, данные нужно брать из profiles
/*
SELECT id, firstname, lastname FROM users WHERE id = 1;
*/
-- правильный вариант
SELECT users_id, firstname, lastname FROM `profiles` WHERE users_id = 1;

/*
SELECT id, firstname, lastname
FROM users WHERE firstname LIKE '%a%';

SELECT id, firstname, lastname
FROM users WHERE firstname NOT LIKE '%a%';

SELECT id, firstname, lastname
FROM users WHERE firstname LIKE '%a%' AND lastname LIKE '%a%';
*/

-- аналогично в трех запросах ниже меняем таблицу и столбец для id
SELECT users_id, firstname, lastname
FROM `profiles` WHERE firstname LIKE '%a%';

SELECT users_id, firstname, lastname
FROM `profiles`  WHERE firstname NOT LIKE '%a%';

SELECT users_id, firstname, lastname
FROM `profiles`  WHERE firstname LIKE '%a%' AND lastname LIKE '%a%';

-- +
SELECT * FROM `profiles`
WHERE birthday > '2010-01-01' AND birthday <= '2019-12-31';

-- +
SELECT * FROM `profiles`
WHERE birthday BETWEEN '2010-01-01' AND '2019-12-31';

-- все правильно, но понятнее было бы написать значения enum вместо магических констант
/*
SELECT * FROM `profiles` WHERE gender IN (1, 2);
*/
SELECT * FROM `profiles` WHERE gender IN ('m', 'f');

-- опечатки в названии поля - должно быть users_id
/*
SELECT * FROM `profiles` WHERE user_id IN (2,12,35);
SELECT * FROM `profiles` WHERE user_id NOT IN (2,12,35);
*/
SELECT * FROM `profiles` WHERE users_id IN (2,12,35);
SELECT * FROM `profiles` WHERE users_id NOT IN (2,12,35);

-- +
SELECT DISTINCT gender FROM `profiles`;

-- используем таблицу profiles вместо users
/*
SELECT * FROM users ORDER BY firstname;
SELECT * FROM users ORDER BY firstname DESC;
SELECT * FROM users ORDER BY firstname DESC, lastname;
*/

SELECT * FROM `profiles` ORDER BY firstname;
SELECT * FROM `profiles` ORDER BY firstname DESC;
SELECT * FROM `profiles` ORDER BY firstname DESC, lastname;

-- +
SELECT * FROM users LIMIT 5;
SELECT * FROM users LIMIT 10, 5;
SELECT * FROM users LIMIT 5 OFFSET 10;

-- +
SELECT USER(); -- текущий пользователь MySQL
SELECT VERSION(); -- версия MySQL
SELECT UUID();

-- +
SELECT
  ROUND(11.2), -- математическое округление, если значение >= .5, то увеличит +1
  CEILING(11.5), -- в большую степень
  FLOOR(11.7); -- в меньшую степень

-- + (если считаем что нет пола 'x' - иначе используем CASE
SELECT
  gender,
  IF(gender = 1, 'Мужской', 'Женский')
FROM profiles;

-- в моей версии базы нет location, а так все правильно - на примере updated_at
/*
SELECT
  IFNULL(location, '-'),
  IF(location IS NULL, '-', location)
FROM profiles;
*/

SELECT
  IFNULL(updated_at, '-'),
  IF(updated_at IS NULL, '-', updated_at)
FROM profiles;

-- лучше заменить константы на значения enum
/*
SELECT
  CASE gender
    WHEN 1 THEN 'Мужской'
    WHEN 2 THEN 'Женский'
    WHEN 3 THEN 'Неопр'
    ELSE 'Иное'
  END AS gender_rus
FROM profiles;
*/

SELECT
  CASE gender
    WHEN 'm' THEN 'Мужской'
    WHEN 'f' THEN 'Женский'
    WHEN 'x' THEN 'Неопр'
    ELSE 'Иное'
  END AS gender_rus
FROM profiles;

-- +
SELECT
    gender
FROM
    profiles
GROUP BY 
    gender;

-- запрос не будет работать с включенной опцией сервера MySQL ONLY_FULL_GROUP_BY
-- если нужны случаные значения для первых двух полей - надо использовать ANY_VALUE
/*
SELECT
    gender,
    users_id,
    GROUP_CONCAT(users_id)
FROM 
    profiles
GROUP BY
    gender;
*/
SELECT
    ANY_VALUE(gender),
    ANY_VALUE(users_id),
    GROUP_CONCAT(users_id)
FROM 
    profiles
GROUP BY
    gender;

-- +
SELECT
    gender,
    COUNT(users_id)
FROM
    profiles
GROUP BY 
    gender;

-- +
SELECT
  gender,
  COUNT(*)
FROM 
    profiles
GROUP BY 
    gender
WITH ROLLUP;


-- +
SELECT
    gender,
    COUNT(*) AS cnt
FROM
    profiles
GROUP BY
    gender
HAVING
    cnt > 10;


-- Данные пользователя
/*
SELECT
  id,
  firstname,
  lastname,
  (SELECT location FROM profiles WHERE profiles.user_id = users.id) AS location,
  (SELECT `blob` FROM media WHERE media.id = users.photo_id) AS `blob`
FROM users;
*/

-- запрос адаптированный под схему vk что у меня
-- запрос требует подзапрос на каждую строку - это неэффективно, лучше использовать join
SELECT
  users_id,
  firstname,
  lastname,
  address,
  (SELECT `blob` FROM media WHERE media.id = profiles.photo_id) AS `blob`
FROM profiles;


-- Фотографии пользователя
-- + но была опечатка в media_types_id
SELECT
    *
FROM 
    media
WHERE
    users_id = 21 AND
    media_types_id = (SELECT id FROM media_types WHERE name = 'img');

-- Кол-во фотографий пользователя
-- +, но была опечатка в users_id и media_types_id
SELECT
    COUNT(*)
FROM
    media
WHERE
    users_id = 21 AND
    media_types_id = (SELECT id FROM media_types WHERE name = 'img');


-- Кол-во медиа всех типов
-- + но поменял названия колонок на свои
SELECT
    media_types_id,
    (SELECT name FROM media_types WHERE media_types.id = media.media_types_id) AS media_type_name,
    COUNT(*)
FROM 
    media
GROUP BY
    media_types_id;

-- Кол-во медиа в каждом месяце (сезонность)
-- этот запрос не будет работать со включенным режимом ONLY_FULL_GROUP_BY

/*
SELECT
    MONTHNAME(created_at) AS created_month,
    COUNT(*)
FROM
    media
GROUP BY
    created_month
ORDER BY MONTH(created_at);
*/

-- переписал для режима ONLY_FULL_GROUP_BY
-- получилось не очень красиво, пришлось делать искуственную дату для преобразования 
-- зато потренировался в подзапросе :)
SELECT
    MONTHNAME(CONCAT('1970-', month_count.created_month, '-01')) as `month`,
    month_count.cnt as `count`
FROM
    (SELECT
        MONTH(created_at) AS created_month,
        COUNT(*) as cnt
    FROM
        media
    GROUP BY
        created_month
    ORDER BY
        created_month) AS month_count;


-- Кол-во медиа у каждого пользователя
-- +
SELECT
    users_id,
    COUNT(*)
FROM 
    media
GROUP BY
    users_id
ORDER BY
    COUNT(*) DESC;

-- Пользователи, которым меньше 14 лет
-- +
SELECT
    *,
    TIMESTAMPDIFF(YEAR, birthday, NOW())
FROM 
    profiles
WHERE 
    TIMESTAMPDIFF(YEAR, birthday, NOW()) < 14;

-- Друзья пользователя (id = 9)
-- +
SELECT
    *
FROM 
    friend_requests
WHERE
  `status` = 1 AND (from_users_id = 9 OR to_users_id = 9);

-- Медиа друзей пользователя (id = 9)
-- +
SELECT
    *
FROM
    media
WHERE
  users_id IN (SELECT to_users_id FROM friend_requests WHERE `status` = 1 AND from_users_id = 9) OR
  users_id IN (SELECT from_users_id FROM friend_requests WHERE `status` = 1 AND to_users_id = 9);


-- Лайки к медиа пользователя
-- + 
SELECT
  id,
  (SELECT COUNT(*) FROM `likes` WHERE `likes`.media_id = media.id) AS cnt
FROM 
    media
WHERE
    users_id = 36;

-- Кол-во сообщений пользователя
-- + (только была опечатка в from_users и from_user_ids) и добавил COUNT
SELECT
  COUNT(*) as cnt
FROM messages
WHERE
  from_users_id = 4 OR to_users_id = 4;