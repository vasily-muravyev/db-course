/*
Создайте представление, которое выводит название name товарной позиции из таблицы products 
и соответствующее название каталога name из таблицы catalogs.
*/

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `shop`.`product_view2` AS
    SELECT 
        `p`.`name` AS `product_name`, `c`.`name` AS `catalog_name`
    FROM
        (`shop`.`products` `p`
        JOIN `shop`.`catalogs` `c` ON ((`p`.`catalog_id` = `c`.`id`)))