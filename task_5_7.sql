/*
	Задание:
	
    Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели.
	Следует учесть, что необходимы дни недели текущего года, а не года рождения.
*/

SELECT
	DAYNAME(CONCAT(YEAR(NOW()), RIGHT(birthday_at, 6))) AS day_name,
	COUNT(*) as count
FROM
	`shop`.`users`
GROUP BY
	day_name