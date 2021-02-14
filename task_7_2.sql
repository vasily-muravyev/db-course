/*

Задание 2:
Выведите список товаров products и разделов catalogs, который соответствует товару.
*/

SELECT
    p.id,
    p.name AS product_name,
    p.price,
    c.name AS catalog_name
FROM
    products p
LEFT JOIN catalogs c ON p.catalog_id = c.id