/*
Пусть имеется любая таблица с календарным полем created_at. Создайте
запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих
записей.
*/

-- решение работает только с отключенным safe mode на update

USE shop;
SET @i = 0;

DROP FUNCTION IF EXISTS increment_i;

DELIMITER //
CREATE FUNCTION increment_i()
RETURNS INT NO SQL
BEGIN
	SET @i = @i + 1;
    RETURN @i;
END//
DELIMITER ;

DELETE FROM shop.products
WHERE id IN
(WITH freshness AS
	(SELECT
		increment_i() AS freshness_index,
		p.id
	FROM
		shop.products p
	ORDER BY
		created_at2 DESC)
SELECT
	id
FROM
	freshness
WHERE
	freshness.freshness_index > 2);
    
