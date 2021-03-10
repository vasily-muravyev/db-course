### Финальный проект по курсу Основы реляционных баз данных. MySQL

#### 1. Общее текстовое описание БД и решаемых ею задач

  База для хранения статистики (истории) по некоторым финансовым инструментам Московской Биржи
 (акциям, облигациям и фьючерсам срочного рынка). Возможность хранения в базе пользователей и их финансовых портфелей.
 

#### 2. Минимальное количество таблиц - 10

Таблицы используемые в базе данных

1. rates - пользовательские тарифы
2. users - пользователи
3. accounts - счета пользователей
4. stocks - акции
5. stock_prices - цены акций в разные моменты времени
6. dividends - дивиденды выплачиваемые по акциям
7. stocks_accounts - акции - счета (для связи N:M)
8. currencies - валюты
9. bonds - облигации
10. bond_prices - цены облигаций в разные моменты времени
11. bonds_accounts - облигации - счета (для связи N:M)
12. coupons - купоны выплачиваемые по облигациям
13. futures - фьючерсы
14. accounts_futures - фьючерсы - счета (для связи N:M)
15. future_prices - цены фьючерсов в разные моменты времени

#### 3. Скрипты создания структуры БД (с первичными ключами, индексами, внешними ключами);

Скрипт, созданные при помощи MySQLWorkbench Forward Engineering из ER диаграммы
Находится в файле **create-db.sql**

#### 4. Создать ERDiagram для БД;

ER диаграмма находится в файле **er-diagram.pdf**

#### 5. Скрипты наполнения БД данными;

Правильное наполнение базы настоящими данными требует написание некоторого
числа скриптов на языке Lua и запуск их в системе QUIK,
возможно есть и другие варианты получения данных от биржи через другие интерфейсы.

Для первой итерации этой работы это было бы излишним усложнением - поэтому создадим
искуственные данные при помощи сервиса filldb.info

Я сделал следующее
1. Cинхронировал ER-диаграммы с MySQL базой данных (функция Forward Engineering).
2. Экспортировал только структуру базы и почистил некоторые комментарии (скрипт **create-db.sql**)
3. Загрузил базу в filldb.info и последовательно создали все таблицы в порядке существования зависимости по ключам
4. Созданную базу импортировал в MySQL Workbench и далее немного заполнил и почистил данные (скрипт **clean-data.sql**)
5. Результат работы - DDL И DML для создания базы импортировал в скрипт **stock-dump-cleaned.sql**

#### 6. скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);

```mysql

-- посчитать общий баланс пользователей и отсортировать по убыванию

SELECT
    u.id as users_id,
    CONCAT(u.first_name, ' ', u.last_name),
    SUM(a.balance) as total_balance
FROM stock.users u
LEFT JOIN accounts a ON u.id = a.users_id
GROUP BY users_id
ORDER BY total_balance DESC;

```

```mysql
-- для каждого пользователя вывести имена всех акций которыми он владеет,
-- их количество, валюту, сумму предстоящих дивидендов по акциям

SELECT
       CONCAT(u.first_name, ' ', u.last_name) as user_name,
       s.name as stock_name,
       SUM(sa.amount) as stocks_count,
       SUM(d.amount) as dividends_amount,
       c.name as currency_name
FROM users u
LEFT JOIN accounts a ON u.id = a.users_id
LEFT JOIN stocks_accounts sa ON sa.accounts_id = a.id
LEFT JOIN stocks s ON sa.stocks_id = s.id
LEFT JOIN currencies c ON s.currencies_id = c.id
LEFT JOIN dividends d ON d.stocks_id = s.id
WHERE 
      s.name IS NOT NULL AND
      sa.amount IS NOT NULL AND
      d.amount IS NOT NULL AND 
      c.name IS NOT NULL
GROUP BY
      user_name, stock_name;

```

#### 7. представления (минимум 2);

```mysq
-- view для получения дивидендов для акций и их дат

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `stock_dividends` AS
    SELECT 
        `s`.`name` AS `stock_name`,
        `d`.`date` AS `dividends_date`,
        `d`.`amount` AS `dividends_amount`
    FROM
        (`stocks` `s`
        LEFT JOIN `dividends` `d` ON ((`s`.`id` = `d`.`stocks_id`)))
```

```mysql
-- view для получения средних цен на акций за все время
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `avg_stock_price` AS
    SELECT 
        `s`.`name` AS `stock_name`,
        AVG(`sp`.`bid`) AS `average_price`
    FROM
        (`stock_prices` `sp`
        JOIN `stocks` `s` ON ((`sp`.`stocks_id` = `s`.`id`)))
    GROUP BY `s`.`name`

```

#### 8. хранимые процедуры / триггеры;

```sql
-- тригер не позволяющий вставить запись с bid > offer
DROP TRIGGER IF EXISTS `stock`.`stock_prices_BEFORE_INSERT`;

DELIMITER $$
USE `stock`$$
CREATE DEFINER = CURRENT_USER TRIGGER `stock`.`stock_prices_BEFORE_INSERT` BEFORE INSERT ON `stock_prices` FOR EACH ROW
BEGIN
    IF NEW.`bid` > NEW.`offer` THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Bid cant be greater than offer';
    END IF;
END$$
DELIMITER ;

CREATE DEFINER = CURRENT_USER TRIGGER `stock`.`dividends_BEFORE_INSERT` BEFORE INSERT ON `dividends` FOR EACH ROW
BEGIN
    IF NEW.`date` < DATE(NOW()) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = "Can't add dividends in past time";
    END IF;
END
```