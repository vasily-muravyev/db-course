## Задание 1

> Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

```mysql
-- Сначала создадим таблицу для логов с нужными полями и движком ARCHIVE

DROP TABLE IF EXISTS `shop`.`logs`;

CREATE TABLE `shop`.`logs`
(
    `id`                 INT         NOT NULL AUTO_INCREMENT,
    `write_at`           DATETIME    NOT NULL,
    `table_name`         VARCHAR(45) NOT NULL,
    `update_primary_key` VARCHAR(45) NULL,
    `update_name`        VARCHAR(45) NULL,
    PRIMARY KEY (`id`)
)
    ENGINE = ARCHIVE;

-- для таблиц users, catalogs, products добавим триггер AFTER_INSERT

DROP PROCEDURE IF EXISTS WRITE_LOG;
DELIMITER //
CREATE PROCEDURE WRITE_LOG(IN `updated_table` VARCHAR(20), IN id INT, IN `name` VARCHAR(255))
BEGIN
    INSERT INTO `shop`.`logs`
        (`write_at`, `table_name`, `update_primary_key`, `update_name`)
        VALUE (NOW(), `updated_table`, `id`, `name`);
END//
DELIMITER ;

DROP TRIGGER IF EXISTS `shop`.`users_AFTER_INSERT`;

DELIMITER $$
USE `shop`$$
CREATE DEFINER = CURRENT_USER TRIGGER `shop`.`users_AFTER_INSERT`
    AFTER INSERT
    ON `users`
    FOR EACH ROW
BEGIN
    CALL WRITE_LOG('users', NEW.`id`, NEW.`name`);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `shop`.`catalogs_AFTER_INSERT`;

DELIMITER $$
USE `shop`$$
CREATE DEFINER = CURRENT_USER TRIGGER `shop`.`catalogs_AFTER_INSERT`
    AFTER INSERT
    ON `catalogs`
    FOR EACH ROW
BEGIN
    CALL WRITE_LOG('catalogs', NEW.`id`, NEW.`name`);
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS `shop`.`products_AFTER_INSERT`;

DELIMITER $$
USE `shop`$$
CREATE DEFINER =`root`@`localhost` TRIGGER `products_AFTER_INSERT`
    AFTER INSERT
    ON `products`
    FOR EACH ROW
BEGIN
    CALL WRITE_LOG('products', NEW.`id`, NEW.`name`);
END$$
DELIMITER ;
```

## Задание 2

> Создайте SQL-запрос, который помещает в таблицу users миллион записей.

```mysql
-- т.к. операции INSERT-а по одному работают крайне долго сделаем следующую идею
-- сначала запишем в таблицу users 100 записей при помощи хранимой процедуры
-- далее сделам два раза CROSS JOIN этой таблицы (получает 100 * 100 * 100 = 1 млн записей)
-- результат CROSS JOIN-а вставим в таблицу users

-- удалим все записи чтобы точно было 100 записей
TRUNCATE `shop`.`users`;

-- процедура для записи 100 значений в таблицу users
DROP PROCEDURE IF EXISTS WRITE_HUNDRED_USERS;
DELIMITER //
CREATE PROCEDURE WRITE_HUNDRED_USERS()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 100
        DO
            INSERT INTO `shop`.`users` (`name`, `birthday_at`, `created_at`, `updated_at`)
            VALUES ('Not random name of user', '2021-02-27', NOW(), NOW());
            SET i = i + 1;
        END WHILE;
END //
DELIMITER ;

CALL WRITE_HUNDRED_USERS();

-- запрос вставки 1 млн записей через CROSS JOIN (достигается перечислением через запятую в FROM)
INSERT INTO shop.users (name, birthday_at, created_at, updated_at)
    (SELECT u.name,
            u.birthday_at,
            u.created_at,
            u.updated_at
     FROM (SELECT u1.*
           FROM shop.users u1,
                shop.users u2,
                shop.users u3) u);
```

## Задание 3

> В базе данных Redis подберите коллекцию для подсчета посещений с определенных
IP-адресов.

```
Для этой задачи удобно использовать Hash в Redis
В хэше visits мы можем увеличивать значения числа  посещений 

hincrby visits 192.168.1.1 11
hincrby visits 222.1.33.4 1045

hgetall visits вернет нам ключи и значения хэша
hkeys visits все ключи
hexists visits 222.1.33.4 - проверка существует ли ключ 
```


## Задание 4

> При помощи базы данных Redis решите задачу поиска имени пользователя по электронному
адресу и наоборот, поиск электронного адреса пользователя по его имени.

В этой задаче также удобно использовать хэши - один для поиска имени по почте и второй для поиска почты по имени.

Пример использования:

```
HSET user:username1 email mail1@gmail.com
HSET mail:mail1@gmail.com name username1

HSET user:username2 email mail2@gmail.com
HSET mail:mail2@gmail.com name username2


HGET user:username1 email
HGET user:username2 email
HGET mail:mail1@gmail.com name
HGET mail:mail2@gmail.com name
```

## Задание 5
> Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

Структура могла бы выглядеть следующим образом.

```
db={
  "catalogs": [
    {
      "id": 1,
      "name": "Процессоры"
    },
    {
      "id": 2,
      "name": "Материнские платы"
    },
    {
      "id": 3,
      "name": "Видеокарты"
    },
    
  ],
  "products": [
    {
      "id": 6,
      "name": "Gigabyte H310M S2H",
      "description": "Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX",
      "price": "4790.00",
      "catalog_id": 2,
      "created_at": "2021-02-23 14:43:30",
      "updated_at": "2021-02-23 15:56:51"
    }
  ]
}

db.catalogs.find()

[
  {
    "_id": ObjectId("5a934e000102030405000000"),
    "id": 1,
    "name": "Процессоры"
  },
  {
    "_id": ObjectId("5a934e000102030405000001"),
    "id": 2,
    "name": "Материнские платы"
  },
  {
    "_id": ObjectId("5a934e000102030405000002"),
    "id": 3,
    "name": "Видеокарты"
  }
]
```