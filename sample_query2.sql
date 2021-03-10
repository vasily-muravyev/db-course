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
WHERE s.name IS NOT NULL AND
	  sa.amount IS NOT NULL AND
      d.amount IS NOT NULL AND 
      c.name IS NOT NULL
GROUP BY
	user_name, stock_name;