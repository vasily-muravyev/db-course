/*
1. Пусть имеется таблица accounts содержащая три столбца id, name, password,
содержащие первичный ключ, имя пользователя и его пароль.

2. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.

3. Создайте пользователя user_read, который бы не имел доступа к таблице accounts,
однако, мог бы извлекать записи из представления.
*/

-- 1. создадим требуемую таблицу и положим туда несколько значений

DROP TABLE IF EXISTS `shop`.`accounts`;

CREATE TABLE `shop`.`accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `password` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`));

INSERT INTO `shop`.`accounts` (`name`, `password`) 
VALUES
	('vasily', 'v'),
	('ivan', 'i'),
	('petr', 'p');

-- 2. создадим требуемый view

CREATE  OR REPLACE VIEW `shop`.`accounts_view` AS
SELECT
	`id`,
    `name`
FROM
	`shop`.`accounts`;

-- 3. создадим пользователя, который имеет доступ только к представлению accounts_view, но не имеет доступа к таблице accounts

DROP USER IF EXISTS user_read;
CREATE USER user_read IDENTIFIED WITH sha256_password BY 'user_read_pass' ;

GRANT SELECT ON `shop`.`accounts_view` TO user_read;