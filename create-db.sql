-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema stock
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema stock
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `stock` DEFAULT CHARACTER SET utf8 ;
USE `stock` ;

-- -----------------------------------------------------
-- Table `stock`.`rates`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`rates` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `phone` BIGINT NOT NULL,
  `login` VARCHAR(20) NOT NULL,
  `password_hash` VARCHAR(45) NOT NULL,
  `created_at` DATE NOT NULL,
  `status` ENUM('not-qualified', 'qualified') NOT NULL,
  `rates_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_rates1_idx` (`rates_id` ASC) VISIBLE,
  CONSTRAINT `fk_users_rates1`
    FOREIGN KEY (`rates_id`)
    REFERENCES `stock`.`rates` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`accounts` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `balance` DECIMAL(20,2) NOT NULL DEFAULT 0,
  `users_id` INT NOT NULL,
  `parent_accounts_id` INT NULL,
  `account_type` ENUM('stock', 'futures') NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_accounts_users_idx` (`users_id` ASC) VISIBLE,
  INDEX `fk_accounts_accounts1_idx` (`parent_accounts_id` ASC) VISIBLE,
  CONSTRAINT `fk_accounts_users`
    FOREIGN KEY (`users_id`)
    REFERENCES `stock`.`users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_accounts_accounts1`
    FOREIGN KEY (`parent_accounts_id`)
    REFERENCES `stock`.`accounts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`currencies`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`currencies` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`stocks`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`stocks` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ticker` VARCHAR(45) NOT NULL COMMENT 'Рассматриваем в рамках одной биржы\nДля хранения информации с нескольких бирж нужно было бы завести еще одно поле с кодом биржи и сделать их составным ключом вместе с тикером',
  `name` VARCHAR(45) NOT NULL,
  `currencies_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_stock_currencies1_idx` (`currencies_id` ASC) VISIBLE,
  CONSTRAINT `fk_stock_currencies1`
    FOREIGN KEY (`currencies_id`)
    REFERENCES `stock`.`currencies` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`dividends`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`dividends` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `date` DATE NOT NULL,
  `amount` DECIMAL(10,2) NOT NULL,
  `stocks_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_dividends_stocks1_idx` (`stocks_id` ASC) VISIBLE,
  CONSTRAINT `fk_dividends_stocks1`
    FOREIGN KEY (`stocks_id`)
    REFERENCES `stock`.`stocks` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`stocks_accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`stocks_accounts` (
  `accounts_id` INT NOT NULL,
  `stocks_id` INT NOT NULL,
  `amount` INT NOT NULL,
  INDEX `fk_stocks_accounts_accounts1_idx` (`accounts_id` ASC) VISIBLE,
  PRIMARY KEY (`accounts_id`, `stocks_id`),
  INDEX `fk_stocks_accounts_stocks1_idx` (`stocks_id` ASC) VISIBLE,
  CONSTRAINT `fk_stocks_accounts_accounts1`
    FOREIGN KEY (`accounts_id`)
    REFERENCES `stock`.`accounts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_stocks_accounts_stocks1`
    FOREIGN KEY (`stocks_id`)
    REFERENCES `stock`.`stocks` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`stock_prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`stock_prices` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `bid` DECIMAL(10,2) NOT NULL,
  `offer` DECIMAL(10,2) NOT NULL,
  `datetime` DATETIME NOT NULL,
  `stocks_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_stock_prices_stocks1_idx` (`stocks_id` ASC) VISIBLE,
  CONSTRAINT `fk_stock_prices_stocks1`
    FOREIGN KEY (`stocks_id`)
    REFERENCES `stock`.`stocks` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`bonds`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`bonds` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ticker` VARCHAR(45) NOT NULL,
  `name` VARCHAR(45) NULL,
  `currencies_id` INT NOT NULL,
  `placement_date` DATE NOT NULL,
  `maturity date` DATE NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_bonds_currencies1_idx` (`currencies_id` ASC) VISIBLE,
  CONSTRAINT `fk_bonds_currencies1`
    FOREIGN KEY (`currencies_id`)
    REFERENCES `stock`.`currencies` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`coupons`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`coupons` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `amount` DECIMAL(10,2) NOT NULL,
  `date` DATE NOT NULL,
  `bonds_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_coupons_bonds1_idx` (`bonds_id` ASC) VISIBLE,
  CONSTRAINT `fk_coupons_bonds1`
    FOREIGN KEY (`bonds_id`)
    REFERENCES `stock`.`bonds` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`bond_prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`bond_prices` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `bid` DECIMAL(10,2) NOT NULL,
  `offer` DECIMAL(10,2) NOT NULL,
  `datetime` DATETIME NOT NULL,
  `bonds_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_bond_prices_bonds1_idx` (`bonds_id` ASC) VISIBLE,
  CONSTRAINT `fk_bond_prices_bonds1`
    FOREIGN KEY (`bonds_id`)
    REFERENCES `stock`.`bonds` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`futures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`futures` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ticker` VARCHAR(45) NOT NULL,
  `execution_date` DATE NOT NULL,
  `bid_customer_margin` DECIMAL(10,2) NOT NULL,
  `offer_customer_margin` DECIMAL(10,2) NOT NULL,
  `settlement_type` ENUM('physical', 'cash') NOT NULL,
  `currencies_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_futures_currencies1_idx` (`currencies_id` ASC) VISIBLE,
  CONSTRAINT `fk_futures_currencies1`
    FOREIGN KEY (`currencies_id`)
    REFERENCES `stock`.`currencies` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`bonds_accounts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`bonds_accounts` (
  `accounts_id` INT NOT NULL,
  `bonds_id` INT NOT NULL,
  `amount` INT NOT NULL,
  PRIMARY KEY (`accounts_id`, `bonds_id`),
  INDEX `fk_bonds_accounts_accounts1_idx` (`accounts_id` ASC) VISIBLE,
  INDEX `fk_bonds_accounts_bonds1_idx` (`bonds_id` ASC) VISIBLE,
  CONSTRAINT `fk_bonds_accounts_accounts1`
    FOREIGN KEY (`accounts_id`)
    REFERENCES `stock`.`accounts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_bonds_accounts_bonds1`
    FOREIGN KEY (`bonds_id`)
    REFERENCES `stock`.`bonds` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`future_prices`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`future_prices` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `bid` DECIMAL(10,2) NOT NULL,
  `offer` DECIMAL(10,2) NOT NULL,
  `datetime` DATETIME NOT NULL,
  `futures_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_future_prices_futures1_idx` (`futures_id` ASC) VISIBLE,
  CONSTRAINT `fk_future_prices_futures1`
    FOREIGN KEY (`futures_id`)
    REFERENCES `stock`.`futures` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `stock`.`accounts_futures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `stock`.`accounts_futures` (
  `accounts_id` INT NOT NULL,
  `futures_id` INT NOT NULL,
  `amount` VARCHAR(45) NOT NULL,
  INDEX `fk_accounts_futures_accounts1_idx` (`accounts_id` ASC) VISIBLE,
  INDEX `fk_accounts_futures_futures1_idx` (`futures_id` ASC) VISIBLE,
  PRIMARY KEY (`accounts_id`, `futures_id`),
  CONSTRAINT `fk_accounts_futures_accounts1`
    FOREIGN KEY (`accounts_id`)
    REFERENCES `stock`.`accounts` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_accounts_futures_futures1`
    FOREIGN KEY (`futures_id`)
    REFERENCES `stock`.`futures` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
