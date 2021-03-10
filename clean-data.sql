-- create temporary table for random filling of parent_account_id
DROP TABLE IF EXISTS accounts_tmp;
CREATE TEMPORARY TABLE accounts_tmp
SELECT 
	*
FROM
	accounts;

-- set some "random" parent ids
UPDATE accounts a1
	SET parent_accounts_id = (SELECT MIN(id) FROM accounts_tmp a2 WHERE a1.users_id = a2.users_id AND a1.id != a2.id)
WHERE id % 10 = 0 AND id > 99;

-- make integer number for futures
UPDATE
	`stock`.`accounts_futures`
SET	
	amount = ROUND(amount);
    
-- insert some random values to bonds table - filldb couldn't handle it
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE 	`stock`.`bonds`;
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO
	`stock`.`bonds` 
    (`ticker`, `name`, `currencies_id`, `placement_date`, `maturity date`)
VALUES
    ('RU000A0Z', 'Company1', '1', '2020-01-01', '2023-01-01'),
	('RU001A0Z', 'Company2', '1', '2020-04-01', '2023-03-01'),
    ('RU000A8Z', 'Company3', '2', '2020-01-01', '2023-01-01'),
	('DE000A0Z', 'Company2', '1', '2020-03-02', '2023-12-01'),
    ('RU004A0Z', 'Company3', '4', '2020-01-01', '2023-01-02'),
	('RU000A6Z', 'Company1', '1', '2020-03-01', '2023-11-01'),
    ('EN000A1Z', 'Company4', '2', '2020-02-01', '2023-01-01'),
	('RU000A2Z', 'Company5', '1', '2020-01-01', '2023-11-06');
    
-- fill bonds_accounts with some random data from crossjoin of two tables
TRUNCATE stock.bonds_accounts;

INSERT INTO
	stock.bonds_accounts
SELECT
	a.id as accounts_id,
    b.id as bonds_id,
    FLOOR(RAND() * 100) as amount
FROM
	accounts a, bonds b
ORDER BY
	RAND()
LIMIT 200;

-- generate random coupons for bonds

TRUNCATE stock.coupons;

INSERT INTO
	stock.coupons
	(`amount`, `date`, `bonds_id`)
SELECT
	FLOOR(RAND() * 10000) as amount,
    DATE(NOW() + INTERVAL FLOOR(RAND() * 1000) DAY),
	b1.id as bonds_id
FROM
	bonds b1, bonds b2, bonds b3
ORDER BY
	RAND()
LIMIT 300;

-- for dividends and futures set time to random future
UPDATE
	stock.dividends
SET
	date = DATE(NOW() + INTERVAL FLOOR(RAND() * 1000) DAY);
    
UPDATE
	stock.futures
SET
	execution_date = DATE(NOW() + INTERVAL FLOOR(RAND() * 500) DAY);
    
-- ensure that bid is less than offer
UPDATE
	stock_prices
SET
	bid = LEAST(bid, offer),
    offer = bid + FLOOR(RAND() * 10);
    
-- fixed extra large amounts
UPDATE
	stocks_accounts
SET
	amount = FLOOR(RAND() * 1000);
    
-- acconts of users shouldn't be created too far ago
UPDATE
	stock.users
SET
	created_at = DATE(NOW() - INTERVAL FLOOR(RAND() * 2000) DAY);