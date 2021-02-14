/*
Задание 3:

Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
Поля from, to и label содержат английские названия городов, поле name — русское.
Выведите список рейсов flights с русскими названиями городов.
*/

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