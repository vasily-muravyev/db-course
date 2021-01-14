### Практическое задание по теме “Управление БД”

--- 
*1. Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf, 
задав в нем логин и пароль, который указывался при установке.*
> Файл сделал, скриншот находится в файле: **1. screenshot.png**


![1. screenshot.png](1.%20screenshot.png)
---
*2. Создайте базу данных example, разместите в ней таблицу users,
состоящую из двух столбцов, числового id и строкового name.*

> Скрипт **2. create-db.sql**


```mysql
CREATE DATABASE IF NOT EXISTS example;

USE example;

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) COMMENT 'Имя пользователя'
) COMMENT = 'Пользователи';

INSERT INTO users VALUES(DEFAULT, 'Vasily Muravyev')
```
---
*3. Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.*
> Скриншот выполнения задания в файле **3. dump and load base screenshot.png**.
> 
> В левом окне терминала создание базы *example* и ее дамп.
> В правом окне создание новой базы *sample* и далее загрузка в нее данных из старой базы.

![3. dump and load base screenshot.png](3.%20dump%20and%20load%20base%20screenshot.png)

---
*4. (по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. Создайте дамп единственной таблицы help_keyword базы данных mysql. Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.*

Задачу можно решить при помощи следующей команды:

```
mysqldump mysql help_keyword --where="true limit 100" > help_keyword_dump.sql
```

Заглянув в файл **help_keyword_dump.sql** мы видим 100 значений в списке для команды в самом низу файла

```mysql
INSERT INTO help_keyword VALUES (108,'%'),(264,'&'),(416,'(JSON') ...
```