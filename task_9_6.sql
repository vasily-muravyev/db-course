/*
В таблице products есть два текстовых поля: name с названием товара и description с его описанием. 
Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля
принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь
того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям
NULL-значение необходимо отменить операцию.
*/

-- добавим триггеры BEFORE_INSERT, BEFORE_UPDATE для таблицы products
-- я использую IFNULL с заменой на пустую строку чтобы обрабатывать не только NLL значения, но и пустые строки
-- для проверки только на NULL можно было бы записать условие как
-- NEW.`description` IS NULL AND NEW.`name` IS NULL

-- trigger for inserts
DROP TRIGGER IF EXISTS `shop`.`products_BEFORE_INSERT`;

DELIMITER $$
USE `shop`$$

CREATE DEFINER=`root`@`localhost` TRIGGER `products_BEFORE_INSERT` BEFORE INSERT ON `products` FOR EACH ROW BEGIN
    IF LENGTH(IFNULL(NEW.`description`,'')) + LENGTH(IFNULL(NEW.`name`,'')) = 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Хотя бы одно из полей [description, name] должно быть заполнено';
    END IF;
END$$
DELIMITER ;

-- trigger for updates
DROP TRIGGER IF EXISTS `shop`.`products_BEFORE_UPDATE`;

DELIMITER $$
USE `shop`$$
CREATE DEFINER=`root`@`localhost` TRIGGER `products_BEFORE_UPDATE` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
    IF LENGTH(IFNULL(NEW.`description`,'')) + LENGTH(IFNULL(NEW.`name`,'')) = 0 THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Хотя бы одно из полей [description, name] должно быть заполнено';
    END IF;
END$$
DELIMITER ;

