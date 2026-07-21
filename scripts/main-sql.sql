-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versión del servidor:         8.0.30 - MySQL Community Server - GPL
-- SO del servidor:              Win64
-- HeidiSQL Versión:             12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para db_nexopos_app
CREATE DATABASE IF NOT EXISTS `db_nexopos_app` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `db_nexopos_app`;

-- Volcando estructura para tabla db_nexopos_app.activity_logs
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `module` varchar(100) NOT NULL,
  `action` varchar(100) NOT NULL,
  `description` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_log_company` (`company_id`),
  KEY `idx_log_user` (`user_id`),
  CONSTRAINT `fk_log_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_log_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.activity_logs: ~0 rows (aproximadamente)
DELETE FROM `activity_logs`;

-- Volcando estructura para tabla db_nexopos_app.branches
CREATE TABLE IF NOT EXISTS `branches` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `code` varchar(20) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `address` varchar(250) DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `company_id` (`company_id`),
  CONSTRAINT `branches_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.branches: ~4 rows (aproximadamente)
DELETE FROM `branches`;
INSERT INTO `branches` (`id`, `company_id`, `name`, `code`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'TIENDA 1', 'C44-45', '98786789', 'tienda@gmail.com', 'Calle santa rosa', 1, '2026-07-09 13:28:07', '2026-07-09 13:28:07', NULL),
	(2, 4, 'TIENDA 2', 'C56-33', '98786789', 'tienda2@gmail.com', 'Calle pepito', 1, '2026-07-09 19:50:10', '2026-07-09 19:50:10', NULL),
	(3, 5, 'TIENDA (POSITIVA)', '883', '989787883', 'positiva@gmail.con', 'Pacora, calle san pablo', 1, '2026-07-09 19:50:28', '2026-07-09 19:52:10', NULL),
	(4, 4, 'LOCAL 2', '9733', '028282', 'loca@gmail.com', 'ddieen', 1, '2026-07-10 11:31:31', '2026-07-10 11:31:31', NULL);

-- Volcando estructura para tabla db_nexopos_app.brands
CREATE TABLE IF NOT EXISTS `brands` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_brands_company` (`company_id`),
  CONSTRAINT `fk_brands_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.brands: ~3 rows (aproximadamente)
DELETE FROM `brands`;
INSERT INTO `brands` (`id`, `company_id`, `name`, `description`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'Marca de prueba 1', NULL, 1, '2026-07-07 10:49:36', '2026-07-07 10:49:36', NULL),
	(2, 4, 'Marca de prueba 2', NULL, 1, '2026-07-07 10:49:48', '2026-07-07 10:49:48', NULL),
	(3, 4, 'Marca de prueba 3', NULL, 1, '2026-07-07 10:49:54', '2026-07-07 10:49:54', NULL);

-- Volcando estructura para tabla db_nexopos_app.cash_movements
CREATE TABLE IF NOT EXISTS `cash_movements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `cash_session_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `type` enum('OPENING','SALE','PURCHASE','INCOME','EXPENSE','CLOSING') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_cash_company` (`company_id`),
  KEY `idx_cash_user` (`user_id`),
  KEY `fk_cash_session` (`cash_session_id`),
  CONSTRAINT `fk_cash_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_cash_session` FOREIGN KEY (`cash_session_id`) REFERENCES `cash_sessions` (`id`),
  CONSTRAINT `fk_cash_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.cash_movements: ~0 rows (aproximadamente)
DELETE FROM `cash_movements`;

-- Volcando estructura para tabla db_nexopos_app.cash_registers
CREATE TABLE IF NOT EXISTS `cash_registers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `name` varchar(100) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_cash_register_company` (`company_id`),
  CONSTRAINT `fk_cash_register_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.cash_registers: ~0 rows (aproximadamente)
DELETE FROM `cash_registers`;

-- Volcando estructura para tabla db_nexopos_app.cash_sessions
CREATE TABLE IF NOT EXISTS `cash_sessions` (
  `id` int unsigned NOT NULL DEFAULT '0',
  `company_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `cash_register_id` int unsigned NOT NULL,
  `user_open_id` int unsigned NOT NULL,
  `user_close_id` int unsigned DEFAULT NULL,
  `opening_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `expected_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `closing_amount` decimal(10,2) DEFAULT NULL,
  `difference` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` enum('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  `opened_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `closed_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_company` (`company_id`),
  KEY `idx_branch` (`branch_id`),
  KEY `idx_cash_register` (`cash_register_id`),
  KEY `idx_user_open` (`user_open_id`),
  KEY `idx_user_close` (`user_close_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_cash_session_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_cash_session_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_cash_session_register` FOREIGN KEY (`cash_register_id`) REFERENCES `cash_registers` (`id`),
  CONSTRAINT `fk_cash_session_user_close` FOREIGN KEY (`user_close_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cash_session_user_open` FOREIGN KEY (`user_open_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.cash_sessions: ~0 rows (aproximadamente)
DELETE FROM `cash_sessions`;

-- Volcando estructura para tabla db_nexopos_app.categories
CREATE TABLE IF NOT EXISTS `categories` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_categories_company` (`company_id`),
  CONSTRAINT `fk_categories_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.categories: ~3 rows (aproximadamente)
DELETE FROM `categories`;
INSERT INTO `categories` (`id`, `company_id`, `name`, `description`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'Categoria de prueba', NULL, 1, '2026-07-07 09:28:19', '2026-07-07 09:28:19', NULL),
	(2, 4, 'Categoria de prueba 2', NULL, 1, '2026-07-07 10:50:06', '2026-07-07 10:50:20', NULL),
	(3, 4, 'Categoria de prueba 3', NULL, 1, '2026-07-07 10:50:26', '2026-07-07 10:50:26', NULL),
	(4, 4, 'Fierros', NULL, 1, '2026-07-19 03:12:08', '2026-07-19 03:12:08', NULL),
	(5, 4, 'Plasticos', NULL, 1, '2026-07-19 03:12:14', '2026-07-19 03:12:14', NULL),
	(6, 4, 'Cintas', NULL, 1, '2026-07-19 03:12:18', '2026-07-19 03:12:18', NULL),
	(7, 4, 'Movibles', NULL, 1, '2026-07-19 03:12:27', '2026-07-19 03:12:27', NULL),
	(8, 4, 'Cementos', NULL, 1, '2026-07-19 03:12:39', '2026-07-19 03:12:39', NULL),
	(9, 4, 'Tubos', NULL, 1, '2026-07-19 03:12:52', '2026-07-19 03:12:52', NULL),
	(10, 4, 'Herramientas', NULL, 1, '2026-07-19 03:13:03', '2026-07-19 03:13:03', NULL),
	(11, 4, 'Prueba 11', NULL, 1, '2026-07-19 03:13:57', '2026-07-19 03:13:57', NULL);

-- Volcando estructura para tabla db_nexopos_app.companies
CREATE TABLE IF NOT EXISTS `companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ruc` varchar(11) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `business_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `trade_name` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `fiscal_address` varchar(255) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sunat_persona_id` varchar(100) COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sunat_persona_token` text COLLATE utf8mb4_general_ci,
  `country_code` varchar(5) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `currency_code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `currency_symbol` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `currency_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `favicon_id` int DEFAULT NULL,
  `logo_id` int DEFAULT NULL,
  `terms_conditions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `privacy_policies` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `host_client` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `mailer_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `mailer_password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `mailer_username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `mailer_host` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `FK1_favicon_sf` (`favicon_id`),
  KEY `FK2_logo-sf` (`logo_id`),
  CONSTRAINT `FK1_favicon_sf` FOREIGN KEY (`favicon_id`) REFERENCES `storage_files` (`id`),
  CONSTRAINT `FK2_logo-sf` FOREIGN KEY (`logo_id`) REFERENCES `storage_files` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.companies: ~2 rows (aproximadamente)
DELETE FROM `companies`;
INSERT INTO `companies` (`id`, `name`, `ruc`, `business_name`, `trade_name`, `fiscal_address`, `sunat_persona_id`, `sunat_persona_token`, `country_code`, `currency_code`, `currency_symbol`, `currency_name`, `favicon_id`, `logo_id`, `terms_conditions`, `privacy_policies`, `host`, `host_client`, `status`, `mailer_name`, `mailer_password`, `mailer_username`, `mailer_host`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(4, 'C. Software Solutions', '10626765411', 'Omar David Serquen Coronado', NULL, 'Pueblo Viejo Pacora', '6a2c1d890d8ed4002950262c', 'DEV_iw0a1WcG5oczrCgcpgVthSNjEtjauCnJBTHClqChcEmrHRqFxa6opILGOjyixHdi', 'PE', 'PEN', 'S/', 'Sol peruano', 1387, 1388, '', '', NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-18 15:48:30', '2026-07-19 03:15:23', NULL),
	(5, 'La Positiva', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'omar davis sequen coonad', NULL, NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-18 15:48:57', '2026-03-20 13:28:52', NULL);

-- Volcando estructura para tabla db_nexopos_app.company_settings
CREATE TABLE IF NOT EXISTS `company_settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `business_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `commercial_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ruc` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `currency` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'PEN',
  `tax_percentage` decimal(5,2) DEFAULT '18.00',
  `ticket_footer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `status` tinyint DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_company_settings` (`company_id`),
  CONSTRAINT `fk_company_settings_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.company_settings: ~0 rows (aproximadamente)
DELETE FROM `company_settings`;

-- Volcando estructura para tabla db_nexopos_app.customers
CREATE TABLE IF NOT EXISTS `customers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `document_type` enum('DNI','RUC','CE','PASSPORT') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT 'DNI',
  `document_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_customer_company` (`company_id`),
  CONSTRAINT `fk_customer_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.customers: ~7 rows (aproximadamente)
DELETE FROM `customers`;
INSERT INTO `customers` (`id`, `company_id`, `document_type`, `document_number`, `name`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'DNI', '62676541', 'Omar David Serquen Coronado', '927350176', 'serquen@gmail.com', 'Calle san pablo - pueblo viejo', 1, '2026-07-08 14:30:48', '2026-07-08 14:30:48', NULL),
	(2, 4, 'DNI', '76756756', 'Julio Samame Lopez', '987867566', 'juliosamame@gmail.com', 'Calle Rela - Pacora', 1, '2026-07-08 14:31:28', '2026-07-08 14:31:28', NULL),
	(3, 4, 'RUC', '11626765411', 'David Coronado', '987867656', 'davidcoronadoomardavid@gmail.com', 'Pueblo Viejo, Pacora', 1, '2026-07-08 14:32:16', '2026-07-08 14:32:16', NULL),
	(4, 4, 'DNI', '87675635', 'Luis Coronado', '987867567', 'luiscoronado@gmail.com', 'Pueblo viejo', 1, '2026-07-08 16:16:19', '2026-07-17 17:22:33', NULL),
	(5, 4, 'DNI', '12364578', 'Samame Jorge David', '98675675', 'samamejorge@gmail.com', 'pacora', 1, '2026-07-08 16:17:25', '2026-07-17 17:22:26', NULL),
	(6, 4, 'DNI', '12345678', 'Nicolas Carlo Corones', '987867678', 'nicolas@gmail.com', 'Jayanca', 1, '2026-07-08 16:20:53', '2026-07-08 16:20:53', NULL),
	(7, 4, 'DNI', '87836373', 'Luciana', 'Cotrina', 'luciana@gmail.com', 'av.lambayeque', 1, '2026-07-17 17:27:51', '2026-07-17 17:27:51', NULL);

-- Volcando estructura para tabla db_nexopos_app.inventory_movements
CREATE TABLE IF NOT EXISTS `inventory_movements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `type` enum('ENTRY','EXIT','SALE','PURCHASE','ADJUSTMENT_IN','ADJUSTMENT_OUT','RETURN','TRANSFER') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `stock_before` decimal(10,2) NOT NULL,
  `stock_after` decimal(10,2) NOT NULL,
  `reference_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `reference_id` bigint DEFAULT NULL,
  `observation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_inventory_company` (`company_id`),
  KEY `idx_inventory_product` (`product_id`),
  KEY `idx_inventory_user` (`user_id`),
  CONSTRAINT `fk_inventory_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_inventory_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_inventory_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.inventory_movements: ~42 rows (aproximadamente)
DELETE FROM `inventory_movements`;
INSERT INTO `inventory_movements` (`id`, `company_id`, `product_id`, `user_id`, `branch_id`, `type`, `quantity`, `stock_before`, `stock_after`, `reference_type`, `reference_id`, `observation`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 4, 38, 1, 'ADJUSTMENT_OUT', 1.00, 50.00, 49.00, 'PURCHASE_CANCEL', 10, 'Salida por cancelación de compra', '2026-07-10 11:50:40', '2026-07-10 11:50:40', NULL),
	(2, 4, 1, 38, 1, 'ADJUSTMENT_OUT', 1.00, 50.00, 49.00, 'PURCHASE_CANCEL', 10, 'Salida por cancelación de compra', '2026-07-10 11:50:40', '2026-07-10 11:50:40', NULL),
	(3, 4, 4, 38, 1, 'ADJUSTMENT_OUT', 20.00, 49.00, 29.00, 'PURCHASE_CANCEL', 8, 'Salida por cancelación de compra', '2026-07-10 11:50:44', '2026-07-10 11:50:44', NULL),
	(4, 4, 6, 41, 4, 'SALE', 1.00, 20.00, 19.00, 'SALE', 19, 'Salida por venta', '2026-07-10 17:53:58', '2026-07-10 17:53:58', NULL),
	(5, 4, 5, 41, 4, 'SALE', 1.00, 10.00, 9.00, 'SALE', 20, 'Salida por venta', '2026-07-10 17:55:07', '2026-07-10 17:55:07', NULL),
	(6, 4, 4, 38, 1, 'PURCHASE', 10.00, 30.00, 40.00, 'PURCHASE', 11, 'Ingreso por compra', '2026-07-10 23:38:58', '2026-07-10 23:38:58', NULL),
	(7, 4, 3, 38, 1, 'PURCHASE', 10.00, 0.00, 10.00, 'PURCHASE', 12, 'Ingreso por compra', '2026-07-11 00:19:11', '2026-07-11 00:19:11', NULL),
	(8, 4, 5, 38, 1, 'PURCHASE', 100.00, 0.00, 100.00, 'PURCHASE', 13, 'Ingreso por compra', '2026-07-11 02:01:00', '2026-07-11 02:01:00', NULL),
	(9, 4, 5, 38, 1, 'SALE', 2.00, 100.00, 98.00, 'SALE', 21, 'Salida por venta', '2026-07-11 02:01:33', '2026-07-11 02:01:33', NULL),
	(10, 4, 3, 38, 1, 'SALE', 2.00, 10.00, 8.00, 'SALE', 21, 'Salida por venta', '2026-07-11 02:01:33', '2026-07-11 02:01:33', NULL),
	(12, 4, 5, 38, 1, 'SALE', 2.00, 98.00, 96.00, 'SALE', 23, 'Salida por venta', '2026-07-17 16:33:29', '2026-07-17 16:33:29', NULL),
	(13, 4, 3, 38, 1, 'SALE', 6.00, 8.00, 2.00, 'SALE', 23, 'Salida por venta', '2026-07-17 16:33:29', '2026-07-17 16:33:29', NULL),
	(14, 4, 5, 38, 1, 'ADJUSTMENT_IN', 2.00, 96.00, 98.00, 'SALE_CANCEL', 23, 'Ingreso por cancelación de venta', '2026-07-17 16:40:17', '2026-07-17 16:40:17', NULL),
	(15, 4, 3, 38, 1, 'ADJUSTMENT_IN', 6.00, 2.00, 8.00, 'SALE_CANCEL', 23, 'Ingreso por cancelación de venta', '2026-07-17 16:40:17', '2026-07-17 16:40:17', NULL),
	(16, 4, 3, 38, 1, 'SALE', 1.00, 8.00, 7.00, 'SALE', 24, 'Salida por venta', '2026-07-17 16:40:53', '2026-07-17 16:40:53', NULL),
	(17, 4, 3, 38, 1, 'SALE', 1.00, 7.00, 6.00, 'SALE', 25, 'Salida por venta', '2026-07-17 16:48:26', '2026-07-17 16:48:26', NULL),
	(18, 4, 3, 38, 1, 'SALE', 1.00, 6.00, 5.00, 'SALE', 26, 'Salida por venta', '2026-07-17 16:52:08', '2026-07-17 16:52:08', NULL),
	(19, 4, 3, 38, 1, 'SALE', 1.00, 5.00, 4.00, 'SALE', 27, 'Salida por venta', '2026-07-17 16:56:42', '2026-07-17 16:56:42', NULL),
	(20, 4, 3, 38, 1, 'SALE', 1.00, 4.00, 3.00, 'SALE', 28, 'Salida por venta', '2026-07-17 16:57:04', '2026-07-17 16:57:04', NULL),
	(21, 4, 3, 38, 1, 'SALE', 1.00, 3.00, 2.00, 'SALE', 29, 'Salida por venta', '2026-07-17 17:00:57', '2026-07-17 17:00:57', NULL),
	(22, 4, 3, 38, 1, 'SALE', 1.00, 2.00, 1.00, 'SALE', 30, 'Salida por venta', '2026-07-17 17:05:16', '2026-07-17 17:05:16', NULL),
	(23, 4, 4, 38, 1, 'SALE', 3.00, 40.00, 37.00, 'SALE', 31, 'Salida por venta', '2026-07-17 17:13:06', '2026-07-17 17:13:06', NULL),
	(24, 4, 5, 38, 1, 'SALE', 10.00, 98.00, 88.00, 'SALE', 32, 'Salida por venta', '2026-07-17 17:20:10', '2026-07-17 17:20:10', NULL),
	(25, 4, 5, 38, 1, 'SALE', 3.00, 88.00, 85.00, 'SALE', 33, 'Salida por venta', '2026-07-17 17:28:19', '2026-07-17 17:28:19', NULL),
	(26, 4, 5, 38, 1, 'SALE', 5.00, 85.00, 80.00, 'SALE', 34, 'Salida por venta', '2026-07-17 17:53:48', '2026-07-17 17:53:48', NULL),
	(27, 4, 5, 38, 1, 'SALE', 5.00, 80.00, 75.00, 'SALE', 35, 'Salida por venta', '2026-07-17 17:54:01', '2026-07-17 17:54:01', NULL),
	(28, 4, 5, 38, 1, 'SALE', 5.00, 75.00, 70.00, 'SALE', 36, 'Salida por venta', '2026-07-17 17:55:44', '2026-07-17 17:55:44', NULL),
	(29, 4, 5, 38, 1, 'ADJUSTMENT_IN', 5.00, 70.00, 75.00, 'SALE_CANCEL', 34, 'Ingreso por cancelación de venta', '2026-07-17 17:55:54', '2026-07-17 17:55:54', NULL),
	(30, 4, 5, 38, 1, 'ADJUSTMENT_IN', 5.00, 75.00, 80.00, 'SALE_CANCEL', 35, 'Ingreso por cancelación de venta', '2026-07-17 17:55:57', '2026-07-17 17:55:57', NULL),
	(31, 4, 5, 38, 1, 'SALE', 5.00, 80.00, 75.00, 'SALE', 37, 'Salida por venta', '2026-07-17 18:22:29', '2026-07-17 18:22:29', NULL),
	(32, 4, 3, 38, 1, 'SALE', 1.00, 1.00, 0.00, 'SALE', 37, 'Salida por venta', '2026-07-17 18:22:29', '2026-07-17 18:22:29', NULL),
	(33, 4, 4, 38, 1, 'SALE', 7.00, 37.00, 30.00, 'SALE', 38, 'Salida por venta', '2026-07-17 18:44:55', '2026-07-17 18:44:55', NULL),
	(34, 4, 5, 38, 1, 'SALE', 1.00, 75.00, 74.00, 'SALE', 39, 'Salida por venta', '2026-07-17 18:56:00', '2026-07-17 18:56:00', NULL),
	(35, 4, 4, 38, 1, 'SALE', 1.00, 30.00, 29.00, 'SALE', 39, 'Salida por venta', '2026-07-17 18:56:00', '2026-07-17 18:56:00', NULL),
	(36, 4, 4, 38, 1, 'SALE', 1.00, 29.00, 28.00, 'SALE', 40, 'Salida por venta', '2026-07-17 18:59:03', '2026-07-17 18:59:03', NULL),
	(37, 4, 5, 38, 1, 'SALE', 1.00, 74.00, 73.00, 'SALE', 40, 'Salida por venta', '2026-07-17 18:59:03', '2026-07-17 18:59:03', NULL),
	(38, 4, 5, 38, 1, 'SALE', 1.00, 73.00, 72.00, 'SALE', 41, 'Salida por venta', '2026-07-17 19:03:00', '2026-07-17 19:03:00', NULL),
	(39, 4, 4, 38, 1, 'SALE', 1.00, 28.00, 27.00, 'SALE', 41, 'Salida por venta', '2026-07-17 19:03:00', '2026-07-17 19:03:00', NULL),
	(40, 4, 5, 38, 1, 'SALE', 1.00, 72.00, 71.00, 'SALE', 43, 'Salida por venta', '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(41, 4, 4, 38, 1, 'SALE', 1.00, 27.00, 26.00, 'SALE', 43, 'Salida por venta', '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(42, 4, 5, 38, 1, 'SALE', 1.00, 71.00, 70.00, 'SALE', 43, 'Salida por venta', '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(43, 4, 4, 38, 1, 'SALE', 1.00, 26.00, 25.00, 'SALE', 44, 'Salida por venta', '2026-07-18 09:55:41', '2026-07-18 09:55:41', NULL),
	(44, 4, 5, 38, 1, 'SALE', 1.00, 70.00, 69.00, 'SALE', 45, 'Salida por venta', '2026-07-18 11:30:11', '2026-07-18 11:30:11', NULL),
	(45, 4, 5, 38, 1, 'SALE', 1.00, 69.00, 68.00, 'SALE', 45, 'Salida por venta', '2026-07-18 11:30:11', '2026-07-18 11:30:11', NULL),
	(46, 4, 4, 38, 1, 'SALE', 1.00, 25.00, 24.00, 'SALE', 46, 'Salida por venta', '2026-07-19 01:11:48', '2026-07-19 01:11:48', NULL),
	(47, 4, 5, 38, 1, 'SALE', 1.00, 68.00, 67.00, 'SALE', 47, 'Salida por venta', '2026-07-19 01:12:53', '2026-07-19 01:12:53', NULL),
	(48, 4, 1, 41, 4, 'SALE', 1.00, 20.00, 19.00, 'SALE', 48, 'Salida por venta', '2026-07-19 01:46:42', '2026-07-19 01:46:42', NULL),
	(49, 4, 5, 38, 1, 'SALE', 1.00, 67.00, 66.00, 'SALE', 49, 'Salida por venta', '2026-07-19 03:01:48', '2026-07-19 03:01:48', NULL);

-- Volcando estructura para tabla db_nexopos_app.notifications
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `user_id` int unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('INFO','WARNING','SUCCESS','ERROR') DEFAULT 'INFO',
  `is_read` tinyint DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notification_company` (`company_id`),
  KEY `fk_notification_user` (`user_id`),
  CONSTRAINT `fk_notification_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_notification_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.notifications: ~0 rows (aproximadamente)
DELETE FROM `notifications`;

-- Volcando estructura para tabla db_nexopos_app.permissions
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `permission` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.permissions: ~2 rows (aproximadamente)
DELETE FROM `permissions`;
INSERT INTO `permissions` (`id`, `name`, `permission`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(6, 'Admin.', 'administrator', 1, '2025-06-12 17:31:00', '2025-06-12 17:32:31', NULL),
	(7, 'Vend.', 'seller', 1, '2025-06-12 17:31:11', '2026-07-10 11:35:22', NULL);

-- Volcando estructura para tabla db_nexopos_app.products
CREATE TABLE IF NOT EXISTS `products` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `category_id` int unsigned DEFAULT NULL,
  `brand_id` int unsigned DEFAULT NULL,
  `unit_id` int unsigned DEFAULT NULL,
  `image_id` int DEFAULT NULL,
  `code` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `barcode` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `purchase_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `sale_price` decimal(10,2) NOT NULL DEFAULT '0.00',
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_products_company_code` (`company_id`,`code`),
  KEY `idx_products_company` (`company_id`),
  KEY `idx_products_category` (`category_id`),
  KEY `idx_products_brand` (`brand_id`),
  KEY `idx_products_unit` (`unit_id`),
  KEY `idx_products_image` (`image_id`),
  CONSTRAINT `fk_products_brand` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`),
  CONSTRAINT `fk_products_category` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
  CONSTRAINT `fk_products_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_products_image` FOREIGN KEY (`image_id`) REFERENCES `storage_files` (`id`),
  CONSTRAINT `fk_products_unit` FOREIGN KEY (`unit_id`) REFERENCES `units` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.products: ~5 rows (aproximadamente)
DELETE FROM `products`;
INSERT INTO `products` (`id`, `company_id`, `category_id`, `brand_id`, `unit_id`, `image_id`, `code`, `barcode`, `name`, `description`, `purchase_price`, `sale_price`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 1, 1, 1, NULL, 'JNDR3', NULL, 'POLOO', NULL, 30.00, 60.00, 1, '2026-07-07 11:03:32', '2026-07-19 01:46:17', NULL),
	(3, 4, 1, 3, 1, NULL, 'JNDR3tr', NULL, 'POLOO 1', NULL, 30.00, 30.00, 1, '2026-07-07 11:03:32', '2026-07-10 11:47:54', NULL),
	(4, 4, 2, 2, 2, NULL, 'N8274B', NULL, 'POLO BAGE DE PRUEBA', NULL, 30.00, 50.00, 1, '2026-07-07 13:27:26', '2026-07-10 11:47:47', NULL),
	(5, 4, 1, 2, 3, NULL, '00283', NULL, 'Casaca Bage', NULL, 30.00, 90.00, 1, '2026-07-09 22:15:41', '2026-07-10 11:47:40', NULL),
	(6, 4, 3, 2, 1, NULL, '0909', NULL, 'POLO BLANCO', NULL, 30.00, 40.00, 1, '2026-07-10 17:16:00', '2026-07-10 17:16:00', NULL),
	(7, 4, 2, 2, 1, NULL, '42323', NULL, 'Carretilla Blanco', NULL, 40.00, 50.00, 1, '2026-07-19 03:08:10', '2026-07-19 03:08:10', NULL),
	(8, 4, 2, 2, 1, NULL, 'r3534', NULL, 'Varilla de 1/2', NULL, 50.00, 70.00, 1, '2026-07-19 03:08:41', '2026-07-19 03:08:41', NULL),
	(9, 4, 2, 2, 1, NULL, '423423', NULL, 'Varilla 3/4', NULL, 30.00, 60.00, 1, '2026-07-19 03:08:58', '2026-07-19 03:08:58', NULL),
	(10, 4, 1, 2, 1, NULL, '2424', NULL, 'Varilla 5/8', NULL, 60.00, 100.00, 1, '2026-07-19 03:09:25', '2026-07-19 03:09:25', NULL),
	(11, 4, 2, 2, 1, NULL, '2343', NULL, 'Clavo de media', NULL, 5.00, 10.00, 1, '2026-07-19 03:09:53', '2026-07-19 03:09:53', NULL),
	(12, 4, 2, 2, 1, NULL, '4234', NULL, 'Tubo de Media', NULL, 30.00, 50.00, 1, '2026-07-19 03:10:11', '2026-07-19 03:10:11', NULL);

-- Volcando estructura para tabla db_nexopos_app.product_stocks
CREATE TABLE IF NOT EXISTS `product_stocks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `current_stock` decimal(10,2) DEFAULT '0.00',
  `minimum_stock` decimal(10,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `branch_id` (`branch_id`,`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.product_stocks: ~11 rows (aproximadamente)
DELETE FROM `product_stocks`;
INSERT INTO `product_stocks` (`id`, `company_id`, `branch_id`, `product_id`, `current_stock`, `minimum_stock`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(25, 4, 4, 5, 9.00, 5.00, '2026-07-10 17:52:31', '2026-07-10 17:55:07', NULL),
	(26, 4, 4, 6, 19.00, 5.00, '2026-07-10 17:52:43', '2026-07-10 17:53:58', NULL),
	(27, 4, 1, 4, 24.00, 10.00, '2026-07-10 17:52:54', '2026-07-19 01:11:48', NULL),
	(28, 4, 2, 1, 50.00, 10.00, '2026-07-10 17:53:03', '2026-07-10 17:53:03', NULL),
	(29, 4, 4, 4, 0.00, 0.00, '2026-07-10 17:53:24', '2026-07-10 17:53:24', NULL),
	(30, 4, 4, 1, 19.00, 3.00, '2026-07-10 17:53:24', '2026-07-19 01:46:42', NULL),
	(31, 4, 4, 3, 0.00, 0.00, '2026-07-10 17:53:24', '2026-07-10 17:53:24', NULL),
	(32, 4, 1, 5, 66.00, 0.00, '2026-07-10 23:38:29', '2026-07-19 03:01:48', NULL),
	(33, 4, 1, 6, 0.00, 0.00, '2026-07-10 23:38:29', '2026-07-10 23:38:29', NULL),
	(34, 4, 1, 1, 0.00, 0.00, '2026-07-10 23:38:29', '2026-07-10 23:38:29', NULL),
	(35, 4, 1, 3, 0.00, 0.00, '2026-07-10 23:38:29', '2026-07-17 18:22:29', NULL),
	(36, 4, 2, 7, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(37, 4, 2, 5, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(38, 4, 2, 11, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(39, 4, 2, 4, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(40, 4, 2, 6, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(41, 4, 2, 3, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(42, 4, 2, 12, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(43, 4, 2, 9, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(44, 4, 2, 10, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL),
	(45, 4, 2, 8, 0.00, 0.00, '2026-07-19 03:20:20', '2026-07-19 03:20:20', NULL);

-- Volcando estructura para tabla db_nexopos_app.purchases
CREATE TABLE IF NOT EXISTS `purchases` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `supplier_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `purchase_date` datetime NOT NULL,
  `voucher_type` enum('FACTURA','BOLETA','NOTA','TICKET') DEFAULT 'FACTURA',
  `voucher_series` varchar(10) DEFAULT NULL,
  `voucher_number` varchar(30) DEFAULT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `observation` text,
  `status` enum('PENDING','COMPLETED','CANCELLED') DEFAULT 'COMPLETED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_purchase_company` (`company_id`),
  KEY `idx_purchase_supplier` (`supplier_id`),
  KEY `idx_purchase_user` (`user_id`),
  CONSTRAINT `fk_purchase_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_purchase_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`),
  CONSTRAINT `fk_purchase_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.purchases: ~3 rows (aproximadamente)
DELETE FROM `purchases`;
INSERT INTO `purchases` (`id`, `company_id`, `supplier_id`, `user_id`, `branch_id`, `purchase_date`, `voucher_type`, `voucher_series`, `voucher_number`, `subtotal`, `tax`, `discount`, `total`, `observation`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(11, 4, 2, 38, 1, '2026-07-10 00:00:00', 'FACTURA', 'FA', '001', 300.00, 0.00, 0.00, 300.00, 'se compra el producto tal para la sucursal tal', 'COMPLETED', '2026-07-10 23:38:58', '2026-07-10 23:38:58', NULL),
	(12, 4, 1, 38, 1, '2026-07-11 00:00:00', 'FACTURA', 'FA', '002', 300.00, 0.00, 0.00, 300.00, 'se compro polo 1', 'COMPLETED', '2026-07-11 00:19:11', '2026-07-11 00:19:11', NULL),
	(13, 4, 1, 38, 1, '2026-07-11 00:00:00', 'FACTURA', 'FA', '003', 3000.00, 0.00, 0.00, 3000.00, 'se compra 100 polos bages', 'COMPLETED', '2026-07-11 02:01:00', '2026-07-11 02:01:00', NULL);

-- Volcando estructura para tabla db_nexopos_app.purchase_details
CREATE TABLE IF NOT EXISTS `purchase_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `purchase_id` bigint unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `purchase_price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_purchase_detail_purchase` (`purchase_id`),
  KEY `idx_purchase_detail_product` (`product_id`),
  CONSTRAINT `fk_purchase_detail_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_purchase_detail_purchase` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.purchase_details: ~3 rows (aproximadamente)
DELETE FROM `purchase_details`;
INSERT INTO `purchase_details` (`id`, `purchase_id`, `product_id`, `quantity`, `purchase_price`, `subtotal`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(12, 11, 4, 10.00, 30.00, 300.00, '2026-07-10 23:38:58', '2026-07-10 23:38:58', NULL),
	(13, 12, 3, 10.00, 30.00, 300.00, '2026-07-11 00:19:11', '2026-07-11 00:19:11', NULL),
	(14, 13, 5, 100.00, 30.00, 3000.00, '2026-07-11 02:01:00', '2026-07-11 02:01:00', NULL);

-- Volcando estructura para tabla db_nexopos_app.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.roles: ~2 rows (aproximadamente)
DELETE FROM `roles`;
INSERT INTO `roles` (`id`, `name`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(5, 'Administrador', 1, '2025-06-12 17:27:11', '2025-06-12 17:27:11', NULL),
	(6, 'Vendedor', 1, '2025-06-12 17:27:26', '2026-07-10 11:35:30', NULL);

-- Volcando estructura para tabla db_nexopos_app.role_permission
CREATE TABLE IF NOT EXISTS `role_permission` (
  `role_id` int unsigned NOT NULL,
  `permission_id` int unsigned NOT NULL,
  `permission` int DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`role_id`,`permission_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.role_permission: ~3 rows (aproximadamente)
DELETE FROM `role_permission`;
INSERT INTO `role_permission` (`role_id`, `permission_id`, `permission`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(5, 6, 1, '2025-06-12 17:35:28', '2025-06-12 17:35:28', NULL),
	(5, 7, 1, '2025-06-12 17:35:40', '2025-06-12 17:35:40', NULL),
	(6, 7, 1, '2025-06-12 17:35:52', '2025-06-12 17:35:52', NULL);

-- Volcando estructura para tabla db_nexopos_app.sales
CREATE TABLE IF NOT EXISTS `sales` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `customer_id` int unsigned DEFAULT NULL,
  `user_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `sale_date` datetime NOT NULL,
  `voucher_type` enum('BOLETA','FACTURA','TICKET','NOTA') DEFAULT 'BOLETA',
  `voucher_series` varchar(10) DEFAULT NULL,
  `voucher_number` varchar(30) DEFAULT NULL,
  `sunat_document_id` varchar(100) DEFAULT NULL,
  `sunat_status` enum('NO_ENVIADO','PENDIENTE','ACEPTADO','RECHAZADO','ERROR') NOT NULL DEFAULT 'NO_ENVIADO',
  `payment_method` enum('CASH','CARD','TRANSFER','YAPE','PLIN','OTHER') DEFAULT 'CASH',
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `tax` decimal(10,2) DEFAULT '0.00',
  `discount` decimal(10,2) DEFAULT '0.00',
  `total` decimal(10,2) DEFAULT '0.00',
  `status` enum('PENDING','COMPLETED','CANCELLED') DEFAULT 'COMPLETED',
  `pdf_58mm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pdf_80mm` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pdf_a5` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `pdf_a4` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sale_company` (`company_id`),
  KEY `idx_sale_customer` (`customer_id`),
  KEY `idx_sale_user` (`user_id`),
  CONSTRAINT `fk_sale_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_sale_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_sale_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.sales: ~25 rows (aproximadamente)
DELETE FROM `sales`;
INSERT INTO `sales` (`id`, `company_id`, `customer_id`, `user_id`, `branch_id`, `sale_date`, `voucher_type`, `voucher_series`, `voucher_number`, `sunat_document_id`, `sunat_status`, `payment_method`, `subtotal`, `tax`, `discount`, `total`, `status`, `pdf_58mm`, `pdf_80mm`, `pdf_a5`, `pdf_a4`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(19, 4, 3, 41, 4, '2026-07-10 00:00:00', 'FACTURA', 'FA', '001', NULL, 'NO_ENVIADO', 'CASH', 40.00, 0.00, 0.00, 40.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-10 17:53:58', '2026-07-10 17:53:58', NULL),
	(20, 4, 2, 41, 4, '2026-07-10 00:00:00', 'BOLETA', 'BO', '002', NULL, 'NO_ENVIADO', 'CASH', 90.00, 0.00, 0.00, 90.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-10 17:55:07', '2026-07-10 17:55:07', NULL),
	(21, 4, 4, 38, 1, '2026-07-11 00:00:00', 'FACTURA', 'FA', '001', NULL, 'NO_ENVIADO', 'TRANSFER', 240.00, 0.00, 0.00, 240.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-11 02:01:33', '2026-07-11 02:01:33', NULL),
	(23, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '', NULL, 'NO_ENVIADO', 'CASH', 360.00, 0.00, 0.00, 360.00, 'CANCELLED', NULL, NULL, NULL, NULL, '2026-07-17 16:33:29', '2026-07-17 16:40:17', NULL),
	(24, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 16:40:53', '2026-07-17 16:40:53', NULL),
	(25, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 16:48:26', '2026-07-17 16:48:26', NULL),
	(26, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 16:52:08', '2026-07-17 16:52:08', NULL),
	(27, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 16:56:42', '2026-07-17 16:56:42', NULL),
	(28, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 16:57:04', '2026-07-17 16:57:04', NULL),
	(29, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 17:00:57', '2026-07-17 17:00:57', NULL),
	(30, 4, 2, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'FA', '004', NULL, 'NO_ENVIADO', 'CASH', 30.00, 0.00, 0.00, 30.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 17:05:16', '2026-07-17 17:05:16', NULL),
	(31, 4, 6, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'F001', '00000007', '6a5aa8f50d299b002941899a', 'PENDIENTE', 'CASH', 150.00, 0.00, 0.00, 150.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 17:13:06', '2026-07-17 17:13:08', NULL),
	(32, 4, 4, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000006', '6a5aaa9c31029f002962b54f', 'PENDIENTE', 'YAPE', 900.00, 0.00, 0.00, 900.00, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-17 17:20:10', '2026-07-17 17:20:12', NULL),
	(33, 4, 7, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000007', '6a5aac850d299b0029418a21', 'ACEPTADO', 'TRANSFER', 270.00, 0.00, 0.00, 270.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5aac850d299b0029418a21/getPDF/ticket58mm/10626765411-03-B001-00000007.PDF', 'https://back.apisunat.com/documents/6a5aac850d299b0029418a21/getPDF/ticket80mm/10626765411-03-B001-00000007.PDF', 'https://back.apisunat.com/documents/6a5aac850d299b0029418a21/getPDF/A5/10626765411-03-B001-00000007.PDF', 'https://back.apisunat.com/documents/6a5aac850d299b0029418a21/getPDF/A4/10626765411-03-B001-00000007.PDF', '2026-07-17 17:28:19', '2026-07-18 09:53:49', NULL),
	(34, 4, 3, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '', NULL, 'NO_ENVIADO', 'YAPE', 450.00, 0.00, 0.00, 450.00, 'CANCELLED', NULL, NULL, NULL, NULL, '2026-07-17 17:53:48', '2026-07-17 17:55:54', NULL),
	(35, 4, 3, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '', NULL, 'NO_ENVIADO', 'YAPE', 450.00, 0.00, 0.00, 450.00, 'CANCELLED', NULL, NULL, NULL, NULL, '2026-07-17 17:54:01', '2026-07-17 17:55:57', NULL),
	(36, 4, 3, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000010', '6a5ab2f131029f002962b6a6', 'ACEPTADO', 'YAPE', 450.00, 0.00, 0.00, 450.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5ab2f131029f002962b6a6/getPDF/ticket58mm/10626765411-03-B001-00000010.PDF', 'https://back.apisunat.com/documents/6a5ab2f131029f002962b6a6/getPDF/ticket80mm/10626765411-03-B001-00000010.PDF', 'https://back.apisunat.com/documents/6a5ab2f131029f002962b6a6/getPDF/A5/10626765411-03-B001-00000010.PDF', 'https://back.apisunat.com/documents/6a5ab2f131029f002962b6a6/getPDF/A4/10626765411-03-B001-00000010.PDF', '2026-07-17 17:55:44', '2026-07-18 10:40:55', NULL),
	(37, 4, 2, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000011', '6a5ab9360d299b0029418c92', 'ACEPTADO', 'CASH', 480.00, 0.00, 0.00, 480.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5ab9360d299b0029418c92/getPDF/ticket58mm/10626765411-03-B001-00000011.PDF', 'https://back.apisunat.com/documents/6a5ab9360d299b0029418c92/getPDF/ticket80mm/10626765411-03-B001-00000011.PDF', 'https://back.apisunat.com/documents/6a5ab9360d299b0029418c92/getPDF/A5/10626765411-03-B001-00000011.PDF', 'https://back.apisunat.com/documents/6a5ab9360d299b0029418c92/getPDF/A4/10626765411-03-B001-00000011.PDF', '2026-07-17 18:22:29', '2026-07-18 10:53:19', NULL),
	(38, 4, 3, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'F001', '00000007', '6a5abe7831029f002962b8a5', 'ACEPTADO', 'CASH', 350.00, 0.00, 0.00, 350.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5abe7831029f002962b8a5/getPDF/ticket58mm/10626765411-01-F001-00000007.PDF', 'https://back.apisunat.com/documents/6a5abe7831029f002962b8a5/getPDF/ticket80mm/10626765411-01-F001-00000007.PDF', 'https://back.apisunat.com/documents/6a5abe7831029f002962b8a5/getPDF/A5/10626765411-01-F001-00000007.PDF', 'https://back.apisunat.com/documents/6a5abe7831029f002962b8a5/getPDF/A4/10626765411-01-F001-00000007.PDF', '2026-07-17 18:44:55', '2026-07-18 09:51:54', NULL),
	(39, 4, 3, 38, 1, '2026-07-17 00:00:00', 'FACTURA', 'F001', '00000008', '6a5ac1120d299b0029418de1', 'ACEPTADO', 'TRANSFER', 140.00, 0.00, 0.00, 140.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5ac1120d299b0029418de1/getPDF/ticket58mm/10626765411-01-F001-00000008.PDF', 'https://back.apisunat.com/documents/6a5ac1120d299b0029418de1/getPDF/ticket80mm/10626765411-01-F001-00000008.PDF', 'https://back.apisunat.com/documents/6a5ac1120d299b0029418de1/getPDF/A5/10626765411-01-F001-00000008.PDF', 'https://back.apisunat.com/documents/6a5ac1120d299b0029418de1/getPDF/A4/10626765411-01-F001-00000008.PDF', '2026-07-17 18:55:59', '2026-07-18 09:43:21', NULL),
	(40, 4, 2, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000012', '6a5ac1c80d299b0029418e05', 'ACEPTADO', 'TRANSFER', 140.00, 0.00, 0.00, 140.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5ac1c80d299b0029418e05/getPDF/ticket58mm/10626765411-03-B001-00000012.PDF', 'https://back.apisunat.com/documents/6a5ac1c80d299b0029418e05/getPDF/ticket80mm/10626765411-03-B001-00000012.PDF', 'https://back.apisunat.com/documents/6a5ac1c80d299b0029418e05/getPDF/A5/10626765411-03-B001-00000012.PDF', 'https://back.apisunat.com/documents/6a5ac1c80d299b0029418e05/getPDF/A4/10626765411-03-B001-00000012.PDF', '2026-07-17 18:59:03', '2026-07-18 09:41:55', NULL),
	(41, 4, 3, 38, 1, '2026-07-17 00:00:00', 'BOLETA', 'B001', '00000013', '6a5ac2b60d299b0029418e28', 'ACEPTADO', 'CARD', 140.00, 0.00, 0.00, 140.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5ac2b60d299b0029418e28/getPDF/ticket58mm/10626765411-03-B001-00000013.PDF', 'https://back.apisunat.com/documents/6a5ac2b60d299b0029418e28/getPDF/ticket80mm/10626765411-03-B001-00000013.PDF', 'https://back.apisunat.com/documents/6a5ac2b60d299b0029418e28/getPDF/A5/10626765411-03-B001-00000013.PDF', 'https://back.apisunat.com/documents/6a5ac2b60d299b0029418e28/getPDF/A4/10626765411-03-B001-00000013.PDF', '2026-07-17 19:03:00', '2026-07-18 09:41:07', NULL),
	(43, 4, 5, 38, 1, '2026-07-18 00:00:00', 'BOLETA', 'B001', '00000014', '6a5b93b10d299b0029419968', 'ACEPTADO', 'CASH', 230.00, 0.00, 0.00, 230.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5b93b10d299b0029419968/getPDF/ticket58mm/10626765411-03-B001-00000014.PDF', 'https://back.apisunat.com/documents/6a5b93b10d299b0029419968/getPDF/ticket80mm/10626765411-03-B001-00000014.PDF', 'https://back.apisunat.com/documents/6a5b93b10d299b0029419968/getPDF/A5/10626765411-03-B001-00000014.PDF', 'https://back.apisunat.com/documents/6a5b93b10d299b0029419968/getPDF/A4/10626765411-03-B001-00000014.PDF', '2026-07-18 09:54:38', '2026-07-18 10:00:11', NULL),
	(44, 4, 3, 38, 1, '2026-07-18 00:00:00', 'FACTURA', 'F001', '00000009', '6a5b93ef0d299b002941996e', 'ACEPTADO', 'CARD', 50.00, 0.00, 0.00, 50.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5b93ef0d299b002941996e/getPDF/ticket58mm/10626765411-01-F001-00000009.PDF', 'https://back.apisunat.com/documents/6a5b93ef0d299b002941996e/getPDF/ticket80mm/10626765411-01-F001-00000009.PDF', 'https://back.apisunat.com/documents/6a5b93ef0d299b002941996e/getPDF/A5/10626765411-01-F001-00000009.PDF', 'https://back.apisunat.com/documents/6a5b93ef0d299b002941996e/getPDF/A4/10626765411-01-F001-00000009.PDF', '2026-07-18 09:55:41', '2026-07-18 09:59:34', NULL),
	(45, 4, 3, 38, 1, '2026-07-18 00:00:00', 'FACTURA', 'F001', '00000010', '6a5baa130d299b0029419cbb', 'PENDIENTE', 'TRANSFER', 190.00, 0.00, 0.00, 190.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5baa130d299b0029419cbb/getPDF/ticket58mm/10626765411-01-F001-00000010.PDF', 'https://back.apisunat.com/documents/6a5baa130d299b0029419cbb/getPDF/ticket80mm/10626765411-01-F001-00000010.PDF', 'https://back.apisunat.com/documents/6a5baa130d299b0029419cbb/getPDF/A5/10626765411-01-F001-00000010.PDF', 'https://back.apisunat.com/documents/6a5baa130d299b0029419cbb/getPDF/A4/10626765411-01-F001-00000010.PDF', '2026-07-18 11:30:11', '2026-07-18 11:30:12', NULL),
	(46, 4, 2, 38, 1, '2026-07-19 00:00:00', 'BOLETA', 'B001', '00000015', '6a5c6aa48f98f50029bc0453', 'PENDIENTE', 'CARD', 50.00, 0.00, 0.00, 50.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5c6aa48f98f50029bc0453/getPDF/ticket58mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6aa48f98f50029bc0453/getPDF/ticket80mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6aa48f98f50029bc0453/getPDF/A5/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6aa48f98f50029bc0453/getPDF/A4/10626765411-03-B001-00000015.PDF', '2026-07-19 01:11:48', '2026-07-19 01:11:48', NULL),
	(47, 4, 7, 38, 1, '2026-07-19 00:00:00', 'BOLETA', 'B001', '00000015', '6a5c6ae68f98f50029bc0455', 'PENDIENTE', 'CARD', 90.00, 0.00, 0.00, 90.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5c6ae68f98f50029bc0455/getPDF/ticket58mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6ae68f98f50029bc0455/getPDF/ticket80mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6ae68f98f50029bc0455/getPDF/A5/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c6ae68f98f50029bc0455/getPDF/A4/10626765411-03-B001-00000015.PDF', '2026-07-19 01:12:53', '2026-07-19 01:12:54', NULL),
	(48, 4, 2, 41, 4, '2026-07-19 00:00:00', 'BOLETA', 'B001', '00000015', '6a5c72d44a94ed0029aab0a1', 'PENDIENTE', 'CASH', 60.00, 0.00, 0.00, 60.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5c72d44a94ed0029aab0a1/getPDF/ticket58mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c72d44a94ed0029aab0a1/getPDF/ticket80mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c72d44a94ed0029aab0a1/getPDF/A5/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c72d44a94ed0029aab0a1/getPDF/A4/10626765411-03-B001-00000015.PDF', '2026-07-19 01:46:42', '2026-07-19 01:46:44', NULL),
	(49, 4, 2, 38, 1, '2026-07-19 00:00:00', 'BOLETA', 'B001', '00000015', '6a5c846d8f98f50029bc049f', 'PENDIENTE', 'CASH', 90.00, 0.00, 0.00, 90.00, 'COMPLETED', 'https://back.apisunat.com/documents/6a5c846d8f98f50029bc049f/getPDF/ticket58mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c846d8f98f50029bc049f/getPDF/ticket80mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c846d8f98f50029bc049f/getPDF/A5/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5c846d8f98f50029bc049f/getPDF/A4/10626765411-03-B001-00000015.PDF', '2026-07-19 03:01:48', '2026-07-19 03:01:49', NULL);

-- Volcando estructura para tabla db_nexopos_app.sale_details
CREATE TABLE IF NOT EXISTS `sale_details` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `sale_id` bigint unsigned NOT NULL,
  `product_id` int unsigned NOT NULL,
  `quantity` decimal(10,2) NOT NULL,
  `sale_price` decimal(10,2) NOT NULL,
  `unit_cost` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total_cost` decimal(10,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(10,2) DEFAULT '0.00',
  `subtotal` decimal(10,2) NOT NULL,
  `profit` decimal(10,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sale_detail_sale` (`sale_id`),
  KEY `idx_sale_detail_product` (`product_id`),
  CONSTRAINT `fk_sale_detail_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_sale_detail_sale` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.sale_details: ~34 rows (aproximadamente)
DELETE FROM `sale_details`;
INSERT INTO `sale_details` (`id`, `sale_id`, `product_id`, `quantity`, `sale_price`, `unit_cost`, `total_cost`, `discount`, `subtotal`, `profit`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(23, 19, 6, 1.00, 40.00, 0.00, 0.00, 0.00, 40.00, 0.00, '2026-07-10 17:53:58', '2026-07-10 17:53:58', NULL),
	(24, 20, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-10 17:55:07', '2026-07-10 17:55:07', NULL),
	(25, 21, 5, 2.00, 90.00, 0.00, 0.00, 0.00, 180.00, 0.00, '2026-07-11 02:01:33', '2026-07-11 02:01:33', NULL),
	(26, 21, 3, 2.00, 30.00, 0.00, 0.00, 0.00, 60.00, 0.00, '2026-07-11 02:01:33', '2026-07-11 02:01:33', NULL),
	(29, 23, 5, 2.00, 90.00, 0.00, 0.00, 0.00, 180.00, 0.00, '2026-07-17 16:33:29', '2026-07-17 16:33:29', NULL),
	(30, 23, 3, 6.00, 30.00, 0.00, 0.00, 0.00, 180.00, 0.00, '2026-07-17 16:33:29', '2026-07-17 16:33:29', NULL),
	(31, 24, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 16:40:53', '2026-07-17 16:40:53', NULL),
	(32, 25, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 16:48:26', '2026-07-17 16:48:26', NULL),
	(33, 26, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 16:52:08', '2026-07-17 16:52:08', NULL),
	(34, 27, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 16:56:42', '2026-07-17 16:56:42', NULL),
	(35, 28, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 16:57:04', '2026-07-17 16:57:04', NULL),
	(36, 29, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 17:00:57', '2026-07-17 17:00:57', NULL),
	(37, 30, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 17:05:16', '2026-07-17 17:05:16', NULL),
	(38, 31, 4, 3.00, 50.00, 0.00, 0.00, 0.00, 150.00, 0.00, '2026-07-17 17:13:06', '2026-07-17 17:13:06', NULL),
	(39, 32, 5, 10.00, 90.00, 0.00, 0.00, 0.00, 900.00, 0.00, '2026-07-17 17:20:10', '2026-07-17 17:20:10', NULL),
	(40, 33, 5, 3.00, 90.00, 0.00, 0.00, 0.00, 270.00, 0.00, '2026-07-17 17:28:19', '2026-07-17 17:28:19', NULL),
	(41, 34, 5, 5.00, 90.00, 0.00, 0.00, 0.00, 450.00, 0.00, '2026-07-17 17:53:48', '2026-07-17 17:53:48', NULL),
	(42, 35, 5, 5.00, 90.00, 0.00, 0.00, 0.00, 450.00, 0.00, '2026-07-17 17:54:01', '2026-07-17 17:54:01', NULL),
	(43, 36, 5, 5.00, 90.00, 0.00, 0.00, 0.00, 450.00, 0.00, '2026-07-17 17:55:44', '2026-07-17 17:55:44', NULL),
	(44, 37, 5, 5.00, 90.00, 0.00, 0.00, 0.00, 450.00, 0.00, '2026-07-17 18:22:29', '2026-07-17 18:22:29', NULL),
	(45, 37, 3, 1.00, 30.00, 0.00, 0.00, 0.00, 30.00, 0.00, '2026-07-17 18:22:29', '2026-07-17 18:22:29', NULL),
	(46, 38, 4, 7.00, 50.00, 0.00, 0.00, 0.00, 350.00, 0.00, '2026-07-17 18:44:55', '2026-07-17 18:44:55', NULL),
	(47, 39, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-17 18:56:00', '2026-07-17 18:56:00', NULL),
	(48, 39, 4, 1.00, 50.00, 0.00, 0.00, 0.00, 50.00, 0.00, '2026-07-17 18:56:00', '2026-07-17 18:56:00', NULL),
	(49, 40, 4, 1.00, 50.00, 0.00, 0.00, 0.00, 50.00, 0.00, '2026-07-17 18:59:03', '2026-07-17 18:59:03', NULL),
	(50, 40, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-17 18:59:03', '2026-07-17 18:59:03', NULL),
	(51, 41, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-17 19:03:00', '2026-07-17 19:03:00', NULL),
	(52, 41, 4, 1.00, 50.00, 0.00, 0.00, 0.00, 50.00, 0.00, '2026-07-17 19:03:00', '2026-07-17 19:03:00', NULL),
	(54, 43, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(55, 43, 4, 1.00, 50.00, 0.00, 0.00, 0.00, 50.00, 0.00, '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(56, 43, 5, 1.00, 90.00, 0.00, 0.00, 0.00, 90.00, 0.00, '2026-07-18 09:54:38', '2026-07-18 09:54:38', NULL),
	(57, 44, 4, 1.00, 50.00, 0.00, 0.00, 0.00, 50.00, 0.00, '2026-07-18 09:55:41', '2026-07-18 09:55:41', NULL),
	(58, 45, 5, 1.00, 0.00, 30.00, 30.00, 0.00, 90.00, 60.00, '2026-07-18 11:30:11', '2026-07-18 11:30:11', NULL),
	(59, 45, 5, 1.00, 0.00, 30.00, 30.00, 0.00, 100.00, 70.00, '2026-07-18 11:30:11', '2026-07-18 11:30:11', NULL),
	(60, 46, 4, 1.00, 0.00, 30.00, 30.00, 0.00, 50.00, 20.00, '2026-07-19 01:11:48', '2026-07-19 01:11:48', NULL),
	(61, 47, 5, 1.00, 0.00, 30.00, 30.00, 0.00, 90.00, 60.00, '2026-07-19 01:12:53', '2026-07-19 01:12:53', NULL),
	(62, 48, 1, 1.00, 0.00, 30.00, 30.00, 0.00, 60.00, 30.00, '2026-07-19 01:46:42', '2026-07-19 01:46:42', NULL),
	(63, 49, 5, 1.00, 0.00, 30.00, 30.00, 0.00, 90.00, 60.00, '2026-07-19 03:01:48', '2026-07-19 03:01:48', NULL);

-- Volcando estructura para tabla db_nexopos_app.storage_files
CREATE TABLE IF NOT EXISTS `storage_files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `company_id` int DEFAULT NULL,
  `path` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `type` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `size_b` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `size` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `format` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `embedded` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `folder` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `uri` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `bucket` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `upload_file_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `uploaded_file` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=1389 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.storage_files: ~2 rows (aproximadamente)
DELETE FROM `storage_files`;
INSERT INTO `storage_files` (`id`, `name`, `company_id`, `path`, `type`, `size_b`, `size`, `format`, `embedded`, `folder`, `uri`, `bucket`, `upload_file_json`, `uploaded_file`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1384, 'omar1.jpg', 4, '/uploads/profile/17831390566a488af00c6df-omar1.jpg', 'image/jpeg', '3180766', '3.03 MB', 'jpg', NULL, NULL, NULL, 'localhost', NULL, NULL, '2026-07-03 23:24:16', '2026-07-03 23:24:16', NULL),
	(1385, 'WhatsApp Image 2026-07-09 at 9.19.35 AM.jpeg', 4, '/uploads/profile/17837484736a51d779cc15e-whatsapp image 2026-07-09 at 9.19.35 am.jpeg', 'image/jpeg', '271421', '265.06 KB', 'jpeg', NULL, NULL, NULL, 'localhost', NULL, NULL, '2026-07-11 00:41:13', '2026-07-11 00:41:13', NULL),
	(1386, 'WhatsApp Image 2026-07-09 at 9.19.38 AM.jpeg', 4, '/uploads/profile/17844469836a5c80071ac07-whatsapp image 2026-07-09 at 9.19.38 am.jpeg', 'image/jpeg', '271421', '265.06 KB', 'jpeg', NULL, NULL, NULL, 'localhost', NULL, NULL, '2026-07-19 02:43:03', '2026-07-19 02:43:03', NULL),
	(1387, 'logo-principal.jpeg', 4, '/uploads/profile/17844489236a5c879ba2e8a-logo-principal.jpeg', 'image/jpeg', '132510', '129.4 KB', 'jpeg', NULL, NULL, NULL, 'localhost', NULL, NULL, '2026-07-19 03:15:23', '2026-07-19 03:15:23', NULL),
	(1388, 'logo-principal.jpeg', 4, '/uploads/profile/17844489236a5c879ba7f81-logo-principal.jpeg', 'image/jpeg', '132510', '129.4 KB', 'jpeg', NULL, NULL, NULL, 'localhost', NULL, NULL, '2026-07-19 03:15:23', '2026-07-19 03:15:23', NULL);

-- Volcando estructura para tabla db_nexopos_app.suppliers
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `document_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `business_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `contact` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` tinyint DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_supplier_company` (`company_id`),
  CONSTRAINT `fk_supplier_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.suppliers: ~3 rows (aproximadamente)
DELETE FROM `suppliers`;
INSERT INTO `suppliers` (`id`, `company_id`, `document_number`, `business_name`, `contact`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, '67672672811', 'SODEXO', 'Omar Coronado', '927350176', 'serquencoronadomar@gmail.com', 'Peru, Pacora', 1, '2026-07-07 17:49:17', '2026-07-07 17:53:28', NULL),
	(2, 4, '7373423423', 'Ropa Petitos', 'Luis Lopez Aliafa', '988787867', 'luis@gmail.com', 'calle san jose 568 - pacora lambayeque', 1, '2026-07-07 17:57:17', '2026-07-07 17:57:17', NULL),
	(3, 4, '76782727', 'La Positiva', 'Julio Acosta Bances', '987867567', 'julioacosta@gmail.com', 'Lambayeque Grau #167 - Perú', 1, '2026-07-07 21:36:57', '2026-07-07 21:36:57', NULL);

-- Volcando estructura para tabla db_nexopos_app.units
CREATE TABLE IF NOT EXISTS `units` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `abbreviation` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_units_company` (`company_id`),
  CONSTRAINT `fk_units_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.units: ~3 rows (aproximadamente)
DELETE FROM `units`;
INSERT INTO `units` (`id`, `company_id`, `name`, `abbreviation`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'Unidad', 'Uni.', 1, '2026-07-07 11:00:47', '2026-07-07 11:00:47', NULL),
	(2, 4, 'Caja', 'CJ', 1, '2026-07-07 13:19:48', '2026-07-07 13:19:48', NULL),
	(3, 4, 'Paquetes', 'Paquete', 1, '2026-07-09 22:15:03', '2026-07-09 22:15:03', NULL);

-- Volcando estructura para tabla db_nexopos_app.users
CREATE TABLE IF NOT EXISTS `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `foto_id` int DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `paternal_surname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `maternal_surname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `password` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `status` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `users_FK1` (`foto_id`) USING BTREE,
  CONSTRAINT `users_FK1` FOREIGN KEY (`foto_id`) REFERENCES `storage_files` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.users: ~4 rows (aproximadamente)
DELETE FROM `users`;
INSERT INTO `users` (`id`, `foto_id`, `name`, `paternal_surname`, `maternal_surname`, `username`, `email`, `password`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(38, 1386, 'Richar Nixon', 'Coronado', 'Inoñan', 'richar', 'richarnixoncoronadoinonan@gmail.com', '$2y$10$xgmK7Nlc34AR1WmqwVn8teNNBPvw6.9byqeStOT7Ay8PJj.07B1JC', 1, '2025-06-12 17:34:03', '2026-07-19 02:43:03', NULL),
	(39, 1382, 'Nicolas', 'Cotrina', 'Llontop', 'nico', 'stafano@gmail.com', '$2y$10$xgmK7Nlc34AR1WmqwVn8teNNBPvw6.9byqeStOT7Ay8PJj.07B1JC', 1, '2025-06-18 18:08:03', '2025-07-10 17:20:24', NULL),
	(40, NULL, 'Omar', 'Serquen', 'Coronado', 'omar', 'serquencoronadoomardavid@gmail.com', '$2y$10$mV.tFedxFk9g1Lh8gkA4NOx0uhGsfI4HBQBkKxFkSdB4qGZtl0BhG', 1, '2026-07-09 19:34:14', '2026-07-09 19:34:14', NULL),
	(41, NULL, 'Usuario prueba', 'shbdd', 'hfbwefbwe', 'maria', 'ejnwe@gmail.co', '$2y$10$x3qyUgoETJII3l88sZquQ.yvSPbXi.ST.h8lqk5dZlrLIV/rdffry', 1, '2026-07-10 11:33:14', '2026-07-10 11:33:14', NULL);

-- Volcando estructura para tabla db_nexopos_app.user_company_role
CREATE TABLE IF NOT EXISTS `user_company_role` (
  `user_id` int unsigned NOT NULL,
  `company_id` int unsigned NOT NULL,
  `role_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`user_id`,`role_id`,`company_id`,`branch_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.user_company_role: ~4 rows (aproximadamente)
DELETE FROM `user_company_role`;
INSERT INTO `user_company_role` (`user_id`, `company_id`, `role_id`, `branch_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(38, 4, 5, 1, '2025-06-14 08:57:52', '2026-07-09 13:28:19', NULL),
	(39, 5, 5, 3, '2025-06-18 18:08:51', '2026-07-09 19:52:41', NULL),
	(40, 4, 5, 2, '2026-07-09 19:34:14', '2026-07-10 00:42:54', NULL),
	(41, 4, 6, 4, '2026-07-10 11:33:14', '2026-07-10 11:33:14', NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
