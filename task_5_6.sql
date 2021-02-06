
/*
	Задание:
	Подсчитайте средний возраст пользователей в таблице users.
*/

SELECT
    AVG(TIMESTAMPDIFF(YEAR, DATE(birthday_at),  DATE(NOW())))
FROM
	`shop`.`users`;
    