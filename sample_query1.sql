-- посчитать общий баланс пользователей и отсортировать по убыванию

SELECT
	u.id as users_id,
    CONCAT(u.first_name, ' ', u.last_name),
    SUM(a.balance) as total_balance
FROM stock.users u
LEFT JOIN accounts a ON u.id = a.users_id
GROUP BY users_id
ORDER BY total_balance DESC;