/*
Задание 1:
Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

*/

SELECT 
    u.id AS user_id,
    COUNT(o.id)
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id