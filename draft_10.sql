DROP DATABASE IF EXISTS `tp`;
CREATE DATABASE `tp`;
ALTER DATABASE `tp` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `tp`;

/* tables */
CREATE TABLE `article` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `price` DECIMAL(8, 2) NOT NULL COMMENT "Better to store as int x100 to avoid rounding errors",
    CONSTRAINT `pk_article` PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `client` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `last_name` VARCHAR(50) NOT NULL,
    CONSTRAINT `pk_client` PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `order` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `client_id` INT UNSIGNED NOT NULL,
    `tax_rate` DECIMAL(4, 4) NOT NULL DEFAULT 0.2,
    `created_at` DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT `pk_order` PRIMARY KEY (`id`)
) ENGINE=InnoDB;

CREATE TABLE `order_item` (
    `order_id` INT UNSIGNED NOT NULL,
    `article_id` INT UNSIGNED NOT NULL,
    `quantity` INT UNSIGNED NOT NULL,
    CONSTRAINT `pk_order_item` PRIMARY KEY (`order_id`, `article_id`)
) ENGINE=InnoDB;

/* foreign keys */
ALTER TABLE `order` ADD CONSTRAINT `fk_order_client` FOREIGN KEY (`client_id`)
    REFERENCES `client`(`id`)
    ON DELETE CASCADE
;

ALTER TABLE `order_item` ADD CONSTRAINT `fk_order_item_order` FOREIGN KEY (`order_id`)
    REFERENCES `order`(`id`)
    ON DELETE CASCADE
;

ALTER TABLE `order_item` ADD CONSTRAINT `fk_order_item_article` FOREIGN KEY (`article_id`)
    REFERENCES `article`(`id`)
    ON DELETE CASCADE
;

/* insertion */
INSERT INTO `article` (`name`, `price`) VALUES 
    ('PlayStation 5', 400.00),
    ('X box', 350.00),
    ('Machine à café', 300.00),
    ('PlayStation 3', 100.00)
;

INSERT INTO `client` (`first_name`, `last_name`) VALUES
    ('Brad', 'PITT'),
    ('George', 'CLOONEY'),
    ('Jean', 'DUJARDIN')
;

INSERT INTO `order` (`client_id`) VALUES (1);

INSERT INTO `order_item` (`quantity`, `order_id`, `article_id`) VALUES 
    (2, 1, 4),
    (1, 1, 3),
    (1, 1, 2)
;

/* select */
SELECT 
    `article`.`name` AS `article`,
    `order_item`.`quantity` AS `nombre`,
    FORMAT(`article`.`price`, 2) AS `prix`,
    FORMAT(`order_item`.`quantity` * `article`.`price`, 2) AS `total HT`
FROM `order_item`
    JOIN `article` ON `order_item`.`article_id` = `article`.`id`
    JOIN `order` ON `order_item`.`order_id` = `order`.`id`
    JOIN `client` ON `order`.`client_id` = `client`.`id`
WHERE `order`.`id` = 1

UNION ALL

SELECT
    NULL AS `article`,
    NULL AS `nombre`,
    'TOTAL HT' AS `prix`,
    FORMAT(SUM(`order_item`.`quantity` * `article`.`price`), 2) AS `total HT`
FROM `order_item`
    JOIN `article` ON `order_item`.`article_id` = `article`.`id`
WHERE `order_item`.`order_id` = 1

UNION ALL

SELECT
    NULL AS `article`,
    NULL AS `nombre`,
    'TVA' AS `prix`,
    FORMAT(SUM(`order_item`.`quantity` * `article`.`price`) * `order`.`tax_rate`, 2) AS `total HT`
FROM `order_item`
    JOIN `article` ON `order_item`.`article_id` = `article`.`id`
    JOIN `order` ON `order_item`.`order_id` = `order`.`id`
WHERE `order_item`.`order_id` = 1

UNION ALL

SELECT 
    NULL AS `article`,
    NULL AS `nombre`,
    'TTC' AS `prix`,
    FORMAT(SUM(`order_item`.`quantity` * `article`.`price`) * (1.0 + `order`.`tax_rate`), 2) AS `total HT`
FROM `order_item`
    JOIN `article` ON `order_item`.`article_id` = `article`.`id`
    JOIN `order` ON `order_item`.`order_id` = `order`.`id`
WHERE `order_item`.`order_id` = 1;
