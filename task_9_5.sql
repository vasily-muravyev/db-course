/*
Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от
текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с
12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый
вечер", с 00:00 до 6:00 — "Доброй ночи".
*/

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