### Задание 1

>Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.

```mysql
SELECT 
    u.id AS user_id,
    COUNT(o.id)
FROM users u
INNER JOIN orders o ON u.id = o.user_id
GROUP BY u.id
```

### Задание 2
> Выведите список товаров products и разделов catalogs, который соответствует товару.

```mysql
SELECT
    p.id,
    p.name AS product_name,
    p.price,
    c.name AS catalog_name
FROM
    products p
LEFT JOIN catalogs c ON p.catalog_id = c.id
```

### Задание 3

> Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
Поля from, to и label содержат английские названия городов, поле name — русское.
Выведите список рейсов flights с русскими названиями городов.

```mysql
SELECT
    f.id,
    f.`from`,
    f.`to`,
    c_from.`name`,
    c_to.`name`
FROM
    flights f
LEFT JOIN cities c_from ON f.from = c_from.label
LEFT JOIN cities c_to ON f.to = c_to.label
```