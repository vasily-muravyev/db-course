/*
	Задание:
	(по желанию) Из таблицы users необходимо извлечь пользователей,
    родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)
*/

SELECT 
	*
FROM
	shop.users
WHERE
	MONTHNAME(birthday_at) IN ('May', 'August');
	