/*

Задание:

Пусть задан некоторый пользователь.
Из всех друзей этого пользователя найдите человека, который больше всех общался с нашим пользователем.
*/

SET @user_id = 8;

-- выбираем из всех сообщений всех пользователей которые писали нашему пользователю или которым писал он
-- оформляем это в подзапрос и делаем grouby + count - этим мы находим всех писавших пользователю и число сообщений
-- при помощи HAVING отфильтровываем только тех пользователей что друзья нашего (выбор друзей тоже оформлен в подзапрос)
-- упорядочиваем по числу сообщений и выбираем верхнего при помощи LIMIT

SELECT
    m.user_id,
    COUNT(*) as count
FROM 
    (SELECT
        IF(from_users_id = @user_id, to_users_id, from_users_id) AS user_id
    FROM
        messages
    WHERE
        from_users_id = @user_id OR to_users_id = @user_id) AS m
GROUP BY
    m.user_id
HAVING
    m.user_id IN (SELECT
                        IF(from_users_id = @user_id, to_users_id, from_users_id) as friend_id
                  FROM
                        friend_requests
                  WHERE
                        (from_users_id = @user_id OR to_users_id = @user_id) AND `status` = 1)
ORDER BY
    count DESC
LIMIT 1;

