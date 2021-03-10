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