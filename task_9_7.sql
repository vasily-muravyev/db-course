/*
(по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
Числами Фибоначчи называется последовательность в которой число равно сумме двух
предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.
*/

DROP FUNCTION IF EXISTS FIBONACCI;

DELIMITER //

CREATE FUNCTION FIBONACCI(num INT)
RETURNS INT NO SQL
BEGIN

	DECLARE i, prev1, prev2, sum_of_prev INT;	

	IF num = 0 THEN
		RETURN 0;
	ELSEIF num = 1 THEN
		RETURN 1;
	END IF;
    
    SET i = 2, prev1 = 0, prev2 = 1;
    
    WHILE i <= num DO
		SET sum_of_prev = prev1 + prev2;
        SET prev1 = prev2;
        SET prev2 = sum_of_prev;
        SET i = i + 1;
	END WHILE;
    
    RETURN prev2;
END//

DELIMITER ;

SELECT 
	FIBONACCI(0),
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
