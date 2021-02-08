/*

Задание:
Подсчитать общее количество лайков, которые получили 10 самых молодых пользователей.

*/

SELECT
    users_id,
    IFNULL(media_likes_sum, 0) +
    IFNULL(posts_likes_sum, 0) +
    IFNULL(messages_likes_sum, 0) AS sum_of_likes
FROM 
(SELECT 
    users_id,
      -- лайки к медиа пользователя
    (SELECT 
        SUM(media_likes.cnt)
     FROM
           (SELECT
            id,
            (SELECT COUNT(*) FROM `likes` WHERE `likes`.media_id = media.id) AS cnt
             FROM media
             WHERE
             users_id = `profiles`.users_id
            ) AS media_likes
    ) AS media_likes_sum,
      -- лайки к постам пользователя
    (SELECT 
        SUM(posts_likes.cnt)
     FROM
           (SELECT
            id,
            (SELECT COUNT(*) FROM `likes` WHERE `likes`.posts_id = posts.id) AS cnt
             FROM posts
             WHERE
             users_id = `profiles`.users_id
            ) AS posts_likes
    ) AS posts_likes_sum,
      -- лайки к сообщениям пользователя
    (SELECT 
        SUM(messages_likes.cnt)
     FROM
           (SELECT
            id,
            (SELECT COUNT(*) FROM `likes` WHERE `likes`.messages_id = messages.id) AS cnt
             FROM messages
             WHERE
             from_users_id = `profiles`.users_id
            ) AS messages_likes
    ) AS messages_likes_sum
FROM 
    `profiles`
ORDER BY
    TIMESTAMPDIFF(YEAR, birthday, NOW())
LIMIT 10) AS result;

