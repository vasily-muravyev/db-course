/*
Создайте SQL-запрос, который помещает в таблицу users миллион записей.
*/

-- т.к. операции INSERT-а по одному работают крайне долго сделаем следующую идею
-- сначала запишем в таблицу users 100 записей при помощи хранимой процедуры
-- далее сделам два раза CROSS JOIN этой таблицы (получает 100 * 100 * 100 = 1 млн записей)
-- результат CROSS JOIN-а вставим в таблицу users

-- удалим все записи чтобы точно было 100 записей
TRUNCATE `shop`.`users`;

-- процедура для записи 100 значений в таблицу users
DROP PROCEDURE IF EXISTS WRITE_HUNDRED_USERS;
DELIMITER //
CREATE PROCEDURE WRITE_HUNDRED_USERS()
BEGIN
	DECLARE i INT DEFAULT 0;
    WHILE i < 100 DO
		INSERT INTO `shop`.`users` (`name`, `birthday_at`, `created_at`, `updated_at`)
							VALUES ('Not random name of user', '2021-02-27', NOW(), NOW());
		SET i = i + 1;
    END WHILE;
END //
DELIMITER ;

CALL WRITE_HUNDRED_USERS();

-- запрос вставки 1 млн записей через CROSS JOIN (достигается перечислением через запятую в FROM)
INSERT INTO shop.users (name, birthday_at, created_at, updated_at)
(SELECT
	u.name,
    u.birthday_at,
    u.created_at,
    u.updated_at
FROM
	(SELECT
		u1.*
	 FROM shop.users u1, shop.users u2, shop.users u3) u);