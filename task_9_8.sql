/*
Создайте двух пользователей которые имеют доступ к базе данных shop. Первому
пользователю shop_read должны быть доступны только запросы на чтение данных, второму
пользователю shop — любые операции в пределах базы данных shop.
*/

DROP USER IF EXISTS user1;
CREATE USER user1 IDENTIFIED WITH sha256_password BY 'user1_pass' ;

GRANT SELECT ON shop.* TO user1;

DROP USER IF EXISTS user2;
CREATE USER user2 IDENTIFIED WITH sha256_password BY 'user2_pass' ;

GRANT ALL ON shop.* TO user2;

