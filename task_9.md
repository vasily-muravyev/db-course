## Практическое задание по теме “Транзакции, переменные, представления”

### Задание 1

> В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

```mysql
START TRANSACTION;

INSERT INTO `sample`.`users`
SELECT *
FROM `shop`.`users`
WHERE id = 1;

DELETE
FROM `shop`.`users`
WHERE id = 1;

COMMIT;
```

### Задание 2

> Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.

```mysql
CREATE ALGORITHM = UNDEFINED DEFINER = `root`@`localhost` SQL SECURITY DEFINER VIEW `shop`.`product_view2` AS
SELECT `p`.`name` AS `product_name`,
       `c`.`name` AS `catalog_name`
FROM (`shop`.`products` `p`
         JOIN `shop`.`catalogs` `c` ON ((`p`.`catalog_id` = `c`.`id`)))
```

### Задание 3

> Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

```mysql
-- создадим временную таблицу в которой будут записи всех дней для августа
-- после этого сделаем LEFT JOIN этой таблицы с исходной таблицей и заполним значения в ней используя IFNULL
-- для эксперимента я добавил колонку created_at2 с типом DATE в таблице shop.products

USE shop;

DROP TABLE IF EXISTS `august_dates`;
CREATE TEMPORARY TABLE `august_dates`
(
    `date` DATE
);

DROP PROCEDURE IF EXISTS august_days;

DELIMITER //
CREATE PROCEDURE august_days(IN `year` CHAR(4), IN `days` INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    WHILE i <= `days`
        DO
            SET @day = CONCAT(`year`, '-08-', i);
            INSERT INTO `august_dates` (`date`) VALUE (@day);
            SET i = i + 1;
        END WHILE;
END//
DELIMITER ;

CALL august_days('2018', 31);

SELECT d.`date`               AS `date`,
       IF(p.id IS NULL, 0, 1) AS is_present
FROM `august_dates` d
         LEFT JOIN `products` p
                   ON d.`date` = p.`created_at2`;
```

### Задание 4

> Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

```mysql
-- решение работает только с отключенным safe mode на update

USE shop;
SET @i = 0;

DROP FUNCTION IF EXISTS increment_i;

DELIMITER //
CREATE FUNCTION increment_i()
    RETURNS INT
    NO SQL
BEGIN
    SET @i = @i + 1;
    RETURN @i;
END//
DELIMITER ;

DELETE
FROM shop.products
WHERE id IN
      (WITH freshness AS
                (SELECT increment_i() AS freshness_index,
                        p.id
                 FROM shop.products p
                 ORDER BY created_at2 DESC)
       SELECT id
       FROM freshness
       WHERE freshness.freshness_index > 2); 
```

## Практическое задание по теме “Хранимые процедуры и функции, триггеры"
### Задание 5

> Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

```mysql
DROP PROCEDURE IF EXISTS hello;

DELIMITER //
CREATE PROCEDURE hello()
BEGIN
    DECLARE cur_time TIME;
    DECLARE greetings VARCHAR(255);

    SET cur_time = TIME(NOW());

    CASE
        WHEN cur_time BETWEEN '06:00' AND '12:00' THEN SELECT "Доброе утро" INTO greetings;
        WHEN cur_time BETWEEN '12:00' AND '18:00' THEN SELECT "Добрый день" INTO greetings;
        WHEN cur_time BETWEEN '18:00' AND '23:59' THEN SELECT "Добрый вечер" INTO greetings;
        ELSE SELECT "Доброй ночи" INTO greetings;
        END CASE;

    SELECT greetings;
END//
DELIMITER ;

CALL hello();
```

### Задание 6

> В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.

```mysql
-- добавим триггеры BEFORE_INSERT, BEFORE_UPDATE для таблицы products
-- я использую IFNULL с заменой на пустую строку чтобы обрабатывать не только NLL значения, но и пустые строки
-- для проверки только на NULL можно было бы записать условие как
-- NEW.`description` IS NULL AND NEW.`name` IS NULL

-- trigger for inserts
DROP TRIGGER IF EXISTS `shop`.`products_BEFORE_INSERT`;

DELIMITER $$
USE `shop`$$

CREATE DEFINER =`root`@`localhost` TRIGGER `products_BEFORE_INSERT`
    BEFORE INSERT
    ON `products`
    FOR EACH ROW
BEGIN
    IF LENGTH(IFNULL(NEW.`description`, '')) + LENGTH(IFNULL(NEW.`name`, '')) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Хотя бы одно из полей [description, name] должно быть заполнено';
    END IF;
END$$
DELIMITER ;

-- trigger for updates
DROP TRIGGER IF EXISTS `shop`.`products_BEFORE_UPDATE`;

DELIMITER $$
USE `shop`$$
CREATE DEFINER =`root`@`localhost` TRIGGER `products_BEFORE_UPDATE`
    BEFORE UPDATE
    ON `products`
    FOR EACH ROW
BEGIN
    IF LENGTH(IFNULL(NEW.`description`, '')) + LENGTH(IFNULL(NEW.`name`, '')) = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Хотя бы одно из полей [description, name] должно быть заполнено';
    END IF;
END$$
DELIMITER ;
```

### Задание 7

> (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.

```mysql
DROP FUNCTION IF EXISTS FIBONACCI;

DELIMITER //

CREATE FUNCTION FIBONACCI(num INT)
    RETURNS INT
    NO SQL
BEGIN

    DECLARE i, prev1, prev2, sum_of_prev INT;

    IF num = 0 THEN
        RETURN 0;
    ELSEIF num = 1 THEN
        RETURN 1;
    END IF;

    SET i = 2, prev1 = 0, prev2 = 1;

    WHILE i <= num
        DO
            SET sum_of_prev = prev1 + prev2;
            SET prev1 = prev2;
            SET prev2 = sum_of_prev;
            SET i = i + 1;
        END WHILE;

    RETURN prev2;
END//

DELIMITER ;

SELECT FIBONACCI(0),
       FIBONACCI(1),
       FIBONACCI(2),
       FIBONACCI(3),
       FIBONACCI(4),
       FIBONACCI(5),
       FIBONACCI(6),
       FIBONACCI(7),
       FIBONACCI(8),
       FIBONACCI(9),
       FIBONACCI(10);
```

## Практическое задание по теме “Администрирование MySQL” 
### Задание 8

> Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.

```mysql
DROP USER IF EXISTS user1;
CREATE USER user1 IDENTIFIED WITH sha256_password BY 'user1_pass';

GRANT SELECT ON shop.* TO user1;

DROP USER IF EXISTS user2;
CREATE USER user2 IDENTIFIED WITH sha256_password BY 'user2_pass';

GRANT ALL ON shop.* TO user2;
```

### Задание 9

> 1. Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль.
>2. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
> 3. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления.

```mysql
-- 1. создадим требуемую таблицу и положим туда несколько значений

DROP TABLE IF EXISTS `shop`.`accounts`;

CREATE TABLE `shop`.`accounts`
(
    `id`       INT         NOT NULL AUTO_INCREMENT,
    `name`     VARCHAR(45) NOT NULL,
    `password` VARCHAR(45) NOT NULL,
    PRIMARY KEY (`id`)
);

INSERT INTO `shop`.`accounts` (`name`, `password`)
VALUES ('vasily', 'v'),
       ('ivan', 'i'),
       ('petr', 'p');

-- 2. создадим требуемый view

CREATE OR REPLACE VIEW `shop`.`accounts_view` AS
SELECT `id`,
       `name`
FROM `shop`.`accounts`;

-- 3. создадим пользователя, который имеет доступ только к представлению accounts_view, но не имеет доступа к таблице accounts

DROP USER IF EXISTS user_read;
CREATE USER user_read IDENTIFIED WITH sha256_password BY 'user_read_pass';

GRANT SELECT ON `shop`.`accounts_view` TO user_read;
```