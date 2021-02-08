/*

Задание:
Определить кто больше поставил лайков (всего) - мужчины или женщины?

*/

-- если считать подзапросами, без использования JOIN

SELECT
    userlike_gender.gender,
    COUNT(userlike_gender.gender)
FROM
    (SELECT 
        users_id,
        (SELECT
            gender
         FROM
            `profiles`
         WHERE
            users_id = `likes`.users_id) AS gender
    FROM 
        likes) AS userlike_gender
GROUP BY
    gender;
    
-- если считать с использованием JOIN

SELECT
    `profiles`.gender,
    COUNT(`profiles`.gender) AS count
FROM
    `likes`
INNER JOIN
    `profiles`
ON
    `likes`.users_id = `profiles`.users_id
GROUP BY
    `profiles`.gender;
