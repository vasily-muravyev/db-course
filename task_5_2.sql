/*
	Задание:
	Таблица users была неудачно спроектирована.
    Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате 20.10.2017 8:10. 
    Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
*/

-- Первым делом приведем данные к неправильному формату (то есть создадим искуственно неправильные данные) - для того чтобы мы могли проверить обратную операцию
-- Используем для этого функцию DATE_FORMAT приводящую данные из правильного формата в тот что по условию задания

SET @conv_date_format = "%d.%m.%Y %l:%i";

UPDATE users
SET
	created_at = DATE_FORMAT(created_at, @conv_date_format),
    updated_at = DATE_FORMAT(updated_at, @conv_date_format);
    
-- Далее выполним задание используя обратную функцию STR_TO_DATE

UPDATE users
SET
	created_at = STR_TO_DATE(created_at, @conv_date_format),
    updated_at = STR_TO_DATE(updated_at, @conv_date_format);
    
-- поменяем тип колонки при помощи меню alter table в MySQL Workbench (ниже автосгенерированный код)
ALTER TABLE `vk`.`users` 
CHANGE COLUMN `created_at` `created_at` DATETIME NULL DEFAULT NULL ,
CHANGE COLUMN `updated_at` `updated_at` DATETIME NULL DEFAULT NULL ;


SELECT * FROM `users`;