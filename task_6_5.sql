/*

Задание:
Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети.

*/

-- под активностью пользователя будем считатать сумму его действий
-- число загружженных медиа + число отправленных сообщений + число поставленных лайков

-- решение с использованием подзапросов, без использования JOIN-ов

SELECT
    *,
    u.media_count + u.messages_count + u.likes_count AS user_activity
FROM
(SELECT
    users_id,
    firstname,
    lastname,
    -- число загруженных медиа
    (SELECT
        COUNT(*)
     FROM
        media
     WHERE
        users_id = `profiles`.users_id) AS media_count,
    -- число отправленных сообщений
    (SELECT
        COUNT(*)
     FROM
        messages
     WHERE
        from_users_id = `profiles`.users_id) AS messages_count,
     -- число поставленных лайков
    (SELECT
        COUNT(*)
     FROM
        likes
     WHERE
        users_id = `profiles`.users_id) AS likes_count
FROM
    `profiles`) AS u
ORDER BY
    user_activity
LIMIT 10;