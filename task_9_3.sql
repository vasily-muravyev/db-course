/*
 Пусть имеется таблица с календарным полем created_at.
 В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. 
 Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1,
 если дата присутствует в исходном таблице и 0, если она отсутствует.
 */

-- создадим временную таблицу в которой будут записи всех дней для августа
-- после этого сделаем LEFT JOIN этой таблицы с исходной таблицей и заполним значения в ней используя IFNULL
-- для эксперимента я добавил колонку created_at2 с типом DATE в таблице shop.products

USE shop;

DROP TABLE IF EXISTS `august_dates`;
CREATE TEMPORARY TABLE `august_dates` (`date` DATE);

DROP PROCEDURE IF EXISTS august_days;

DELIMITER //
CREATE PROCEDURE august_days(IN `year` CHAR(4), IN `days` INT)
BEGIN
	DECLARE i INT DEFAULT 1;
    WHILE i <= `days` DO
		SET @day =  CONCAT(`year`, '-08-', i);
		INSERT INTO `august_dates` (`date`) VALUE (@day);
        SET i = i + 1;
	END WHILE;
END//
DELIMITER ;

CALL august_days('2018', 31);

SELECT 
	d.`date` AS `date`,
    IF(p.id IS NULL, 0, 1) AS is_present
FROM 
	`august_dates` d
LEFT JOIN `products` p
ON d.`date` = p.`created_at2`;