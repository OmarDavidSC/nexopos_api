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

-- Volcando datos para la tabla db_nexopos_app.categories: ~7 rows (aproximadamente)
DELETE FROM `categories`;
INSERT INTO `categories` (`id`, `company_id`, `name`, `description`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(4, 4, 'Fierros', NULL, 1, '2026-07-19 03:12:08', '2026-07-19 03:12:08', NULL),
	(5, 4, 'Plasticos', NULL, 1, '2026-07-19 03:12:14', '2026-07-19 03:12:14', NULL),
	(6, 4, 'Cintas', NULL, 1, '2026-07-19 03:12:18', '2026-07-19 03:12:18', NULL),
	(7, 4, 'Movibles', NULL, 1, '2026-07-19 03:12:27', '2026-07-19 03:12:27', NULL),
	(8, 4, 'Cementos', NULL, 1, '2026-07-19 03:12:39', '2026-07-19 03:12:39', NULL),
	(9, 4, 'Tubos', NULL, 1, '2026-07-19 03:12:52', '2026-07-19 03:12:52', NULL),
	(10, 4, 'Herramientas', NULL, 1, '2026-07-19 03:13:03', '2026-07-19 03:13:03', NULL);

-- Volcando estructura para tabla db_nexopos_app.companies
CREATE TABLE IF NOT EXISTS `companies` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `ruc` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `business_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `phone` int DEFAULT NULL,
  `fiscal_address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sunat_persona_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `sunat_persona_token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
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
INSERT INTO `companies` (`id`, `name`, `ruc`, `business_name`, `phone`, `fiscal_address`, `sunat_persona_id`, `sunat_persona_token`, `country_code`, `currency_code`, `currency_symbol`, `currency_name`, `favicon_id`, `logo_id`, `terms_conditions`, `privacy_policies`, `host`, `host_client`, `status`, `mailer_name`, `mailer_password`, `mailer_username`, `mailer_host`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(4, 'Coronado Software Solutions', '10626765411', 'Omar David Serquen Coronado', 927350176, 'Pueblo Viejo - Pacora', '6a2c1d890d8ed4002950262c', 'DEV_iw0a1WcG5oczrCgcpgVthSNjEtjauCnJBTHClqChcEmrHRqFxa6opILGOjyixHdi', 'PE', 'PEN', 'S/', 'Sol peruano', NULL, NULL, '', '', NULL, NULL, 1, NULL, NULL, NULL, NULL, '2026-03-18 15:48:30', '2026-07-21 12:55:07', NULL),
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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.customers: ~8 rows (aproximadamente)
DELETE FROM `customers`;
INSERT INTO `customers` (`id`, `company_id`, `document_type`, `document_number`, `name`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 'DNI', '62676541', 'Omar David Serquen Coronado', '927350176', 'serquen@gmail.com', 'Calle san pablo - pueblo viejo', 1, '2026-07-08 14:30:48', '2026-07-08 14:30:48', NULL),
	(2, 4, 'DNI', '76756756', 'Julio Samame Lopez', '987867566', 'juliosamame@gmail.com', 'Calle Rela - Pacora', 1, '2026-07-08 14:31:28', '2026-07-08 14:31:28', NULL),
	(3, 4, 'RUC', '11626765411', 'David Coronado', '987867656', 'davidcoronadoomardavid@gmail.com', 'Pueblo Viejo, Pacora', 1, '2026-07-08 14:32:16', '2026-07-08 14:32:16', NULL),
	(4, 4, 'DNI', '87675635', 'Luis Coronado', '987867567', 'luiscoronado@gmail.com', 'Pueblo viejo', 1, '2026-07-08 16:16:19', '2026-07-17 17:22:33', NULL),
	(5, 4, 'DNI', '12364578', 'Samame Jorge David', '98675675', 'samamejorge@gmail.com', 'pacora', 1, '2026-07-08 16:17:25', '2026-07-17 17:22:26', NULL),
	(6, 4, 'DNI', '12345678', 'Nicolas Carlo Corones', '987867678', 'nicolas@gmail.com', 'Jayanca', 1, '2026-07-08 16:20:53', '2026-07-08 16:20:53', NULL),
	(7, 4, 'DNI', '87836373', 'Luciana', '927350176', 'luciana@gmail.com', 'av.lambayeque', 1, '2026-07-17 17:27:51', '2026-07-22 13:59:30', NULL),
	(8, 4, 'DNI', '75315654', 'Noe', '98367333', 'noe@gmail.com', 'Pacora', 1, '2026-07-22 20:24:10', '2026-08-04 11:03:13', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=80 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.inventory_movements: ~27 rows (aproximadamente)
DELETE FROM `inventory_movements`;
INSERT INTO `inventory_movements` (`id`, `company_id`, `product_id`, `user_id`, `branch_id`, `type`, `quantity`, `stock_before`, `stock_after`, `reference_type`, `reference_id`, `observation`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(50, 4, 15, 40, 2, 'SALE', 1.00, 50.00, 49.00, 'SALE', 50, 'Salida por venta', '2026-07-20 09:28:44', '2026-07-20 09:28:44', NULL),
	(51, 4, 15, 40, 2, 'SALE', 1.00, 49.00, 48.00, 'SALE', 51, 'Salida por venta', '2026-07-20 09:32:44', '2026-07-20 09:32:44', NULL),
	(52, 4, 16, 40, 2, 'SALE', 2.00, 50.00, 48.00, 'SALE', 52, 'Salida por venta', '2026-07-20 10:11:08', '2026-07-20 10:11:08', NULL),
	(53, 4, 15, 40, 2, 'SALE', 1.00, 48.00, 47.00, 'SALE', 53, 'Salida por venta', '2026-07-20 10:12:17', '2026-07-20 10:12:17', NULL),
	(54, 4, 15, 41, 4, 'SALE', 1.00, 50.00, 49.00, 'SALE', 54, 'Salida por venta', '2026-07-20 10:22:02', '2026-07-20 10:22:02', NULL),
	(55, 4, 16, 40, 2, 'ADJUSTMENT_IN', 2.00, 48.00, 50.00, 'SALE_CANCEL', 52, 'Ingreso por cancelación de venta', '2026-07-20 10:35:22', '2026-07-20 10:35:22', NULL),
	(56, 4, 13, 42, 4, 'PURCHASE', 100.00, 0.00, 100.00, 'PURCHASE', 14, 'Ingreso por compra', '2026-07-21 10:45:28', '2026-07-21 10:45:28', NULL),
	(57, 4, 13, 42, 4, 'SALE', 5.00, 100.00, 95.00, 'SALE', 55, 'Salida por venta', '2026-07-21 10:48:54', '2026-07-21 10:48:54', NULL),
	(58, 4, 15, 41, 4, 'SALE', 1.00, 49.00, 48.00, 'SALE', 56, 'Salida por venta', '2026-07-21 10:52:04', '2026-07-21 10:52:04', NULL),
	(59, 4, 15, 40, 2, 'SALE', 1.00, 4.00, 3.00, 'SALE', 57, 'Salida por venta', '2026-07-22 10:58:10', '2026-07-22 10:58:10', NULL),
	(60, 4, 16, 40, 2, 'SALE', 5.00, 10.00, 5.00, 'SALE', 60, 'Salida por venta', '2026-07-22 12:59:20', '2026-07-22 12:59:20', NULL),
	(61, 4, 13, 40, 2, 'SALE', 3.00, 50.00, 47.00, 'SALE', 60, 'Salida por venta', '2026-07-22 12:59:20', '2026-07-22 12:59:20', NULL),
	(62, 4, 13, 40, 2, 'SALE', 5.00, 47.00, 42.00, 'SALE', 61, 'Salida por venta', '2026-07-22 15:40:37', '2026-07-22 15:40:37', NULL),
	(63, 4, 17, 40, 2, 'PURCHASE', 10.00, 5.00, 15.00, 'PURCHASE', 15, 'Ingreso por compra', '2026-07-22 20:20:53', '2026-07-22 20:20:53', NULL),
	(64, 4, 17, 40, 2, 'SALE', 5.00, 15.00, 10.00, 'SALE', 62, 'Salida por venta', '2026-07-22 20:24:55', '2026-07-22 20:24:55', NULL),
	(65, 4, 17, 40, 2, 'ADJUSTMENT_IN', 5.00, 10.00, 15.00, 'SALE_CANCEL', 62, 'Ingreso por cancelación de venta', '2026-07-22 20:29:44', '2026-07-22 20:29:44', NULL),
	(66, 4, 13, 40, 2, 'SALE', 5.00, 42.00, 37.00, 'SALE', 63, 'Salida por venta', '2026-07-27 11:21:04', '2026-07-27 11:21:04', NULL),
	(67, 4, 14, 40, 2, 'SALE', 2.00, 50.00, 48.00, 'SALE', 63, 'Salida por venta', '2026-07-27 11:21:04', '2026-07-27 11:21:04', NULL),
	(68, 4, 16, 40, 2, 'PURCHASE', 10.00, 5.00, 15.00, 'PURCHASE', 16, 'Ingreso por compra', '2026-07-27 11:29:29', '2026-07-27 11:29:29', NULL),
	(69, 4, 16, 40, 2, 'SALE', 2.00, 15.00, 13.00, 'SALE', 64, 'Salida por venta', '2026-07-27 11:38:09', '2026-07-27 11:38:09', NULL),
	(70, 4, 13, 40, 2, 'SALE', 1.00, 37.00, 36.00, 'SALE', 65, 'Salida por venta', '2026-07-27 15:02:02', '2026-07-27 15:02:02', NULL),
	(71, 4, 17, 40, 2, 'SALE', 1.00, 15.00, 14.00, 'SALE', 66, 'Salida por venta', '2026-07-27 15:05:27', '2026-07-27 15:05:27', NULL),
	(72, 4, 16, 40, 2, 'SALE', 2.00, 13.00, 11.00, 'SALE', 67, 'Salida por venta', '2026-07-27 15:55:53', '2026-07-27 15:55:53', NULL),
	(73, 4, 16, 40, 2, 'SALE', 1.00, 11.00, 10.00, 'SALE', 68, 'Salida por venta', '2026-07-27 16:23:16', '2026-07-27 16:23:16', NULL),
	(74, 4, 16, 40, 2, 'PURCHASE', 1.00, 10.00, 11.00, 'PURCHASE', 17, 'Ingreso por compra', '2026-08-04 10:55:01', '2026-08-04 10:55:01', NULL),
	(75, 4, 13, 40, 2, 'PURCHASE', 4.00, 36.00, 40.00, 'PURCHASE', 17, 'Ingreso por compra', '2026-08-04 10:55:01', '2026-08-04 10:55:01', NULL),
	(76, 4, 15, 41, 4, 'SALE', 2.00, 48.00, 46.00, 'SALE', 69, 'Salida por venta', '2026-08-04 12:17:00', '2026-08-04 12:17:00', NULL),
	(77, 4, 16, 40, 2, 'SALE', 2.00, 11.00, 9.00, 'SALE', 70, 'Salida por venta', '2026-08-19 21:04:14', '2026-08-19 21:04:14', NULL),
	(78, 4, 15, 40, 2, 'SALE', 1.00, 3.00, 2.00, 'SALE', 71, 'Salida por venta', '2026-08-19 21:22:59', '2026-08-19 21:22:59', NULL),
	(79, 4, 15, 40, 2, 'ADJUSTMENT_IN', 1.00, 2.00, 3.00, 'SALE_CANCEL', 71, 'Ingreso por cancelación de venta', '2026-08-19 21:23:32', '2026-08-19 21:23:32', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.permissions: ~3 rows (aproximadamente)
DELETE FROM `permissions`;
INSERT INTO `permissions` (`id`, `name`, `permission`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(6, 'Admin.', 'administrator', 1, '2025-06-12 17:31:00', '2025-06-12 17:32:31', NULL),
	(7, 'Vend.', 'seller', 1, '2025-06-12 17:31:11', '2026-07-10 11:35:22', NULL),
	(8, 'Soporte', 'support', 1, '2026-07-21 10:04:36', '2026-07-21 10:04:36', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.products: ~5 rows (aproximadamente)
DELETE FROM `products`;
INSERT INTO `products` (`id`, `company_id`, `category_id`, `brand_id`, `unit_id`, `image_id`, `code`, `barcode`, `name`, `description`, `purchase_price`, `sale_price`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(13, 4, 4, 1, 1, NULL, 'FE-020', NULL, 'Varilla 1/2', NULL, 40.00, 60.00, 1, '2026-07-20 09:24:20', '2026-07-20 09:24:20', NULL),
	(14, 4, 4, 2, 1, NULL, 'VA-023', NULL, 'Varilla 5/8', NULL, 60.00, 70.00, 1, '2026-07-20 09:24:56', '2026-07-20 09:24:56', NULL),
	(15, 4, 7, 2, 1, NULL, 'CA-030', NULL, 'Carretilla', NULL, 50.00, 60.00, 1, '2026-07-20 09:25:22', '2026-07-20 09:25:22', NULL),
	(16, 4, 10, 3, 1, NULL, 'CA-004QQ', NULL, 'Clavos 1/2', NULL, 5.50, 7.50, 1, '2026-07-20 09:25:56', '2026-07-20 09:25:56', NULL),
	(17, 4, 4, 2, 1, NULL, 'POL.002', NULL, 'Polo de prueba', NULL, 30.00, 40.00, 1, '2026-07-22 20:18:36', '2026-07-22 20:18:36', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.product_stocks: ~13 rows (aproximadamente)
DELETE FROM `product_stocks`;
INSERT INTO `product_stocks` (`id`, `company_id`, `branch_id`, `product_id`, `current_stock`, `minimum_stock`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(46, 4, 2, 16, 9.00, 10.00, '2026-07-20 09:26:18', '2026-08-19 21:04:14', NULL),
	(47, 4, 2, 15, 3.00, 10.00, '2026-07-20 09:26:26', '2026-08-19 21:23:32', NULL),
	(48, 4, 2, 13, 40.00, 6.00, '2026-07-20 09:26:40', '2026-08-04 10:55:01', NULL),
	(49, 4, 2, 14, 48.00, 5.00, '2026-07-20 09:26:47', '2026-07-27 11:21:04', NULL),
	(50, 4, 4, 15, 46.00, 5.00, '2026-07-20 10:21:01', '2026-08-04 12:17:00', NULL),
	(51, 4, 4, 16, 0.00, 0.00, '2026-07-20 10:21:01', '2026-07-20 10:21:01', NULL),
	(52, 4, 4, 13, 95.00, 0.00, '2026-07-20 10:21:01', '2026-07-21 10:48:54', NULL),
	(53, 4, 4, 14, 0.00, 0.00, '2026-07-20 10:21:01', '2026-07-20 10:21:01', NULL),
	(54, 4, 1, 15, 0.00, 0.00, '2026-07-21 10:22:03', '2026-07-21 10:22:03', NULL),
	(55, 4, 1, 16, 50.00, 6.00, '2026-07-21 10:22:03', '2026-07-27 11:38:50', NULL),
	(56, 4, 1, 13, 0.00, 0.00, '2026-07-21 10:22:03', '2026-07-21 10:22:03', NULL),
	(57, 4, 1, 14, 0.00, 0.00, '2026-07-21 10:22:03', '2026-07-21 10:22:03', NULL),
	(58, 4, 2, 17, 14.00, 2.00, '2026-07-22 20:19:07', '2026-07-27 15:05:27', NULL),
	(59, 4, 4, 17, 0.00, 0.00, '2026-08-04 12:16:04', '2026-08-04 12:16:04', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.purchases: ~3 rows (aproximadamente)
DELETE FROM `purchases`;
INSERT INTO `purchases` (`id`, `company_id`, `supplier_id`, `user_id`, `branch_id`, `purchase_date`, `voucher_type`, `voucher_series`, `voucher_number`, `subtotal`, `tax`, `discount`, `total`, `observation`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(14, 4, 3, 42, 4, '2026-07-21 00:00:00', 'FACTURA', 'FA', '003', 4000.00, 0.00, 0.00, 4000.00, '', 'COMPLETED', '2026-07-21 10:45:28', '2026-07-21 10:45:28', NULL),
	(15, 4, 3, 40, 2, '2026-07-22 00:00:00', 'FACTURA', 'FA', '003', 300.00, 0.00, 0.00, 300.00, '', 'COMPLETED', '2026-07-22 20:20:53', '2026-07-22 20:20:53', NULL),
	(16, 4, 2, 40, 2, '2026-07-27 00:00:00', 'FACTURA', 'FA', '004', 55.00, 0.00, 0.00, 55.00, '', 'COMPLETED', '2026-07-27 11:29:29', '2026-07-27 11:29:29', NULL),
	(17, 4, 2, 40, 2, '2026-08-04 00:00:00', 'FACTURA', 'FA', '87', 165.50, 0.00, 0.00, 165.50, 'ghvj', 'COMPLETED', '2026-08-04 10:55:01', '2026-08-04 10:55:01', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.purchase_details: ~5 rows (aproximadamente)
DELETE FROM `purchase_details`;
INSERT INTO `purchase_details` (`id`, `purchase_id`, `product_id`, `quantity`, `purchase_price`, `subtotal`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(15, 14, 13, 100.00, 40.00, 4000.00, '2026-07-21 10:45:28', '2026-07-21 10:45:28', NULL),
	(16, 15, 17, 10.00, 30.00, 300.00, '2026-07-22 20:20:53', '2026-07-22 20:20:53', NULL),
	(17, 16, 16, 10.00, 5.50, 55.00, '2026-07-27 11:29:29', '2026-07-27 11:29:29', NULL),
	(18, 17, 16, 1.00, 5.50, 5.50, '2026-08-04 10:55:01', '2026-08-04 10:55:01', NULL),
	(19, 17, 13, 4.00, 40.00, 160.00, '2026-08-04 10:55:01', '2026-08-04 10:55:01', NULL);

-- Volcando estructura para tabla db_nexopos_app.quotations
CREATE TABLE IF NOT EXISTS `quotations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `customer_id` int unsigned DEFAULT NULL,
  `sale_id` bigint unsigned DEFAULT NULL,
  `created_by` int unsigned NOT NULL,
  `quotation_series` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'COT',
  `quotation_number` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `issue_date` datetime NOT NULL,
  `expiration_date` date DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` enum('DRAFT','SENT','ACCEPTED','REJECTED','EXPIRED','CONVERTED','CANCELLED') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'DRAFT',
  `observations` text COLLATE utf8mb4_unicode_ci,
  `terms` text COLLATE utf8mb4_unicode_ci,
  `converted_at` datetime DEFAULT NULL,
  `accepted_at` datetime DEFAULT NULL,
  `rejected_at` datetime DEFAULT NULL,
  `cancelled_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_quotation_company_series_number` (`company_id`,`quotation_series`,`quotation_number`),
  KEY `fk_quotations_created_by` (`created_by`),
  KEY `idx_quotations_company` (`company_id`),
  KEY `idx_quotations_branch` (`branch_id`),
  KEY `idx_quotations_customer` (`customer_id`),
  KEY `idx_quotations_sale` (`sale_id`),
  KEY `idx_quotations_status` (`status`),
  KEY `idx_quotations_issue_date` (`issue_date`),
  KEY `idx_quotations_expiration_date` (`expiration_date`),
  KEY `idx_quotations_deleted_at` (`deleted_at`),
  CONSTRAINT `fk_quotations_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_quotations_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_quotations_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_quotations_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_quotations_sale` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla db_nexopos_app.quotations: ~2 rows (aproximadamente)
DELETE FROM `quotations`;
INSERT INTO `quotations` (`id`, `company_id`, `branch_id`, `customer_id`, `sale_id`, `created_by`, `quotation_series`, `quotation_number`, `issue_date`, `expiration_date`, `subtotal`, `tax`, `discount`, `total`, `status`, `observations`, `terms`, `converted_at`, `accepted_at`, `rejected_at`, `cancelled_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 2, 3, NULL, 40, 'COT', '00000001', '2026-08-04 00:00:00', '2026-09-30', 60.00, 0.00, 0.00, 60.00, 'SENT', 'TJGJHJHGJ', 'HJHGJHGJGH', NULL, NULL, NULL, NULL, '2026-08-04 14:52:10', '2026-08-04 14:57:22', NULL),
	(2, 4, 4, 2, NULL, 41, 'COT', '00000002', '2026-08-04 00:00:00', '2026-09-19', 360.00, 0.00, 0.00, 360.00, 'ACCEPTED', 'frehrtjhrt', 'hrthrhrthrtyryrtyr', NULL, '2026-08-04 12:20:27', NULL, NULL, '2026-08-04 17:18:31', '2026-08-04 17:20:27', NULL);

-- Volcando estructura para tabla db_nexopos_app.quotation_details
CREATE TABLE IF NOT EXISTS `quotation_details` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `quotation_id` int NOT NULL,
  `product_id` int unsigned NOT NULL,
  `quantity` decimal(12,3) NOT NULL DEFAULT '1.000',
  `unit_price` decimal(12,2) NOT NULL DEFAULT '0.00',
  `discount_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `discount` decimal(12,2) NOT NULL DEFAULT '0.00',
  `subtotal` decimal(12,2) NOT NULL DEFAULT '0.00',
  `tax` decimal(12,2) NOT NULL DEFAULT '0.00',
  `total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `description` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_quotation_details_quotation` (`quotation_id`) USING BTREE,
  KEY `idx_quotation_details_product` (`product_id`) USING BTREE,
  KEY `idx_quotation_details_deleted_at` (`deleted_at`) USING BTREE,
  CONSTRAINT `fk_quotation_details_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `fk_quotation_details_quotation` FOREIGN KEY (`quotation_id`) REFERENCES `quotations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Volcando datos para la tabla db_nexopos_app.quotation_details: ~0 rows (aproximadamente)
DELETE FROM `quotation_details`;
INSERT INTO `quotation_details` (`id`, `quotation_id`, `product_id`, `quantity`, `unit_price`, `discount_percentage`, `discount`, `subtotal`, `tax`, `total`, `description`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 1, 16, 8.000, 7.50, 0.00, 0.00, 60.00, 0.00, 60.00, NULL, '2026-08-04 14:52:10', '2026-08-04 14:52:10', NULL),
	(2, 2, 15, 6.000, 60.00, 0.00, 0.00, 360.00, 0.00, 360.00, NULL, '2026-08-04 17:18:31', '2026-08-04 17:18:31', NULL);

-- Volcando estructura para tabla db_nexopos_app.roles
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.roles: ~3 rows (aproximadamente)
DELETE FROM `roles`;
INSERT INTO `roles` (`id`, `name`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(5, 'Administrador', 1, '2025-06-12 17:27:11', '2025-06-12 17:27:11', NULL),
	(6, 'Vendedor', 1, '2025-06-12 17:27:26', '2026-07-10 11:35:30', NULL),
	(7, 'Soporte', 1, '2026-07-21 10:08:24', '2026-07-21 10:08:24', NULL);

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

-- Volcando datos para la tabla db_nexopos_app.role_permission: ~6 rows (aproximadamente)
DELETE FROM `role_permission`;
INSERT INTO `role_permission` (`role_id`, `permission_id`, `permission`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(5, 6, 1, '2025-06-12 17:35:28', '2025-06-12 17:35:28', NULL),
	(5, 7, 1, '2025-06-12 17:35:40', '2025-06-12 17:35:40', NULL),
	(6, 7, 1, '2025-06-12 17:35:52', '2025-06-12 17:35:52', NULL),
	(7, 6, 1, '2026-07-21 10:11:52', '2026-07-21 10:11:52', NULL),
	(7, 7, 1, '2026-07-21 10:12:07', '2026-07-21 10:12:07', NULL),
	(7, 8, 1, '2026-07-21 10:11:38', '2026-07-21 10:11:38', NULL);

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
  `payment_condition` enum('CASH','CREDIT') NOT NULL DEFAULT 'CASH',
  `subtotal` decimal(10,2) DEFAULT '0.00',
  `tax` decimal(10,2) DEFAULT '0.00',
  `discount` decimal(10,2) DEFAULT '0.00',
  `total` decimal(10,2) DEFAULT '0.00',
  `amount_paid` decimal(10,2) NOT NULL DEFAULT '0.00',
  `balance_due` decimal(10,2) NOT NULL DEFAULT '0.00',
  `payment_status` enum('PENDING','PARTIAL','PAID') NOT NULL DEFAULT 'PAID',
  `due_date` date DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.sales: ~18 rows (aproximadamente)
DELETE FROM `sales`;
INSERT INTO `sales` (`id`, `company_id`, `customer_id`, `user_id`, `branch_id`, `sale_date`, `voucher_type`, `voucher_series`, `voucher_number`, `sunat_document_id`, `sunat_status`, `payment_method`, `payment_condition`, `subtotal`, `tax`, `discount`, `total`, `amount_paid`, `balance_due`, `payment_status`, `due_date`, `status`, `pdf_58mm`, `pdf_80mm`, `pdf_a5`, `pdf_a4`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(50, 4, 2, 40, 2, '2026-07-20 00:00:00', 'BOLETA', 'B001', '', NULL, 'ERROR', 'TRANSFER', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', NULL, NULL, NULL, NULL, '2026-07-20 09:28:44', '2026-07-20 09:28:44', NULL),
	(51, 4, 7, 40, 2, '2026-07-20 00:00:00', 'BOLETA', 'B001', '00000015', '6a5e318f8f98f50029bc2ae4', 'ACEPTADO', 'PLIN', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a5e318f8f98f50029bc2ae4/getPDF/ticket58mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5e318f8f98f50029bc2ae4/getPDF/ticket80mm/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5e318f8f98f50029bc2ae4/getPDF/A5/10626765411-03-B001-00000015.PDF', 'https://back.apisunat.com/documents/6a5e318f8f98f50029bc2ae4/getPDF/A4/10626765411-03-B001-00000015.PDF', '2026-07-20 09:32:44', '2026-07-20 09:33:26', NULL),
	(52, 4, 2, 40, 2, '2026-07-20 00:00:00', 'FACTURA', 'F001', '', NULL, 'ERROR', 'CASH', 'CASH', 15.00, 0.00, 0.00, 15.00, 0.00, 0.00, 'PAID', NULL, 'CANCELLED', NULL, NULL, NULL, NULL, '2026-07-20 10:11:08', '2026-07-20 10:35:22', NULL),
	(53, 4, 3, 40, 2, '2026-07-20 00:00:00', 'FACTURA', 'F001', '00000011', '6a5e3ad34a94ed0029aad805', 'ACEPTADO', 'YAPE', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a5e3ad34a94ed0029aad805/getPDF/ticket58mm/10626765411-01-F001-00000011.PDF', 'https://back.apisunat.com/documents/6a5e3ad34a94ed0029aad805/getPDF/ticket80mm/10626765411-01-F001-00000011.PDF', 'https://back.apisunat.com/documents/6a5e3ad34a94ed0029aad805/getPDF/A5/10626765411-01-F001-00000011.PDF', 'https://back.apisunat.com/documents/6a5e3ad34a94ed0029aad805/getPDF/A4/10626765411-01-F001-00000011.PDF', '2026-07-20 10:12:17', '2026-07-20 10:13:03', NULL),
	(54, 4, 7, 41, 4, '2026-07-20 00:00:00', 'BOLETA', 'B001', '00000016', '6a5e3d1c4a94ed0029aad85b', 'ACEPTADO', 'CARD', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a5e3d1c4a94ed0029aad85b/getPDF/ticket58mm/10626765411-03-B001-00000016.PDF', 'https://back.apisunat.com/documents/6a5e3d1c4a94ed0029aad85b/getPDF/ticket80mm/10626765411-03-B001-00000016.PDF', 'https://back.apisunat.com/documents/6a5e3d1c4a94ed0029aad85b/getPDF/A5/10626765411-03-B001-00000016.PDF', 'https://back.apisunat.com/documents/6a5e3d1c4a94ed0029aad85b/getPDF/A4/10626765411-03-B001-00000016.PDF', '2026-07-20 10:22:02', '2026-07-20 10:28:49', NULL),
	(55, 4, 4, 42, 4, '2026-07-21 00:00:00', 'BOLETA', 'B001', '00000017', '6a5f94e84a94ed0029aafb95', 'ACEPTADO', 'PLIN', 'CASH', 300.00, 0.00, 0.00, 300.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a5f94e84a94ed0029aafb95/getPDF/ticket58mm/10626765411-03-B001-00000017.PDF', 'https://back.apisunat.com/documents/6a5f94e84a94ed0029aafb95/getPDF/ticket80mm/10626765411-03-B001-00000017.PDF', 'https://back.apisunat.com/documents/6a5f94e84a94ed0029aafb95/getPDF/A5/10626765411-03-B001-00000017.PDF', 'https://back.apisunat.com/documents/6a5f94e84a94ed0029aafb95/getPDF/A4/10626765411-03-B001-00000017.PDF', '2026-07-21 10:48:54', '2026-07-21 10:49:30', NULL),
	(56, 4, 6, 41, 4, '2026-07-21 00:00:00', 'BOLETA', 'B001', '00000018', '6a5f95a58f98f50029bc59b2', 'ACEPTADO', 'CASH', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a5f95a58f98f50029bc59b2/getPDF/ticket58mm/10626765411-03-B001-00000018.PDF', 'https://back.apisunat.com/documents/6a5f95a58f98f50029bc59b2/getPDF/ticket80mm/10626765411-03-B001-00000018.PDF', 'https://back.apisunat.com/documents/6a5f95a58f98f50029bc59b2/getPDF/A5/10626765411-03-B001-00000018.PDF', 'https://back.apisunat.com/documents/6a5f95a58f98f50029bc59b2/getPDF/A4/10626765411-03-B001-00000018.PDF', '2026-07-21 10:52:04', '2026-07-21 10:52:37', NULL),
	(57, 4, 2, 40, 2, '2026-07-22 00:00:00', 'BOLETA', 'B001', '00000019', '6a60e8958f98f50029bc7d00', 'ACEPTADO', 'PLIN', 'CASH', 60.00, 0.00, 0.00, 60.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a60e8958f98f50029bc7d00/getPDF/ticket58mm/10626765411-03-B001-00000019.PDF', 'https://back.apisunat.com/documents/6a60e8958f98f50029bc7d00/getPDF/ticket80mm/10626765411-03-B001-00000019.PDF', 'https://back.apisunat.com/documents/6a60e8958f98f50029bc7d00/getPDF/A5/10626765411-03-B001-00000019.PDF', 'https://back.apisunat.com/documents/6a60e8958f98f50029bc7d00/getPDF/A4/10626765411-03-B001-00000019.PDF', '2026-07-22 10:58:10', '2026-07-22 10:58:21', NULL),
	(60, 4, 7, 40, 2, '2026-07-22 00:00:00', 'BOLETA', 'B001', '00000020', '6a610507e7ff1d0029b80399', 'ACEPTADO', 'CARD', 'CASH', 217.50, 0.00, 0.00, 217.50, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a610507e7ff1d0029b80399/getPDF/ticket58mm/10626765411-03-B001-00000020.PDF', 'https://back.apisunat.com/documents/6a610507e7ff1d0029b80399/getPDF/ticket80mm/10626765411-03-B001-00000020.PDF', 'https://back.apisunat.com/documents/6a610507e7ff1d0029b80399/getPDF/A5/10626765411-03-B001-00000020.PDF', 'https://back.apisunat.com/documents/6a610507e7ff1d0029b80399/getPDF/A4/10626765411-03-B001-00000020.PDF', '2026-07-22 12:59:20', '2026-07-22 13:58:45', NULL),
	(61, 4, 7, 40, 2, '2026-07-22 00:00:00', 'BOLETA', 'B001', '00000021', '6a612ac666f726002924cdbc', 'ACEPTADO', 'YAPE', 'CASH', 300.00, 0.00, 0.00, 300.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a612ac666f726002924cdbc/getPDF/ticket58mm/10626765411-03-B001-00000021.PDF', 'https://back.apisunat.com/documents/6a612ac666f726002924cdbc/getPDF/ticket80mm/10626765411-03-B001-00000021.PDF', 'https://back.apisunat.com/documents/6a612ac666f726002924cdbc/getPDF/A5/10626765411-03-B001-00000021.PDF', 'https://back.apisunat.com/documents/6a612ac666f726002924cdbc/getPDF/A4/10626765411-03-B001-00000021.PDF', '2026-07-22 15:40:37', '2026-07-22 15:41:07', NULL),
	(62, 4, 8, 40, 2, '2026-07-22 00:00:00', 'BOLETA', 'B001', '00000022', '6a616d6866f726002924e836', 'ACEPTADO', 'YAPE', 'CASH', 200.00, 0.00, 0.00, 200.00, 0.00, 0.00, 'PAID', NULL, 'CANCELLED', 'https://back.apisunat.com/documents/6a616d6866f726002924e836/getPDF/ticket58mm/10626765411-03-B001-00000022.PDF', 'https://back.apisunat.com/documents/6a616d6866f726002924e836/getPDF/ticket80mm/10626765411-03-B001-00000022.PDF', 'https://back.apisunat.com/documents/6a616d6866f726002924e836/getPDF/A5/10626765411-03-B001-00000022.PDF', 'https://back.apisunat.com/documents/6a616d6866f726002924e836/getPDF/A4/10626765411-03-B001-00000022.PDF', '2026-07-22 20:24:55', '2026-07-22 20:29:44', NULL),
	(63, 4, 1, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000024', '6a678571c643170021f3d73e', 'ACEPTADO', 'YAPE', 'CASH', 440.00, 0.00, 0.00, 440.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a678571c643170021f3d73e/getPDF/ticket58mm/10626765411-03-B001-00000024.PDF', 'https://back.apisunat.com/documents/6a678571c643170021f3d73e/getPDF/ticket80mm/10626765411-03-B001-00000024.PDF', 'https://back.apisunat.com/documents/6a678571c643170021f3d73e/getPDF/A5/10626765411-03-B001-00000024.PDF', 'https://back.apisunat.com/documents/6a678571c643170021f3d73e/getPDF/A4/10626765411-03-B001-00000024.PDF', '2026-07-27 11:21:04', '2026-07-27 11:22:05', NULL),
	(64, 4, 2, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000025', '6a67897e1a69570021a9cf4b', 'ACEPTADO', 'CARD', 'CASH', 15.00, 0.00, 0.00, 15.00, 0.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a67897e1a69570021a9cf4b/getPDF/ticket58mm/10626765411-03-B001-00000025.PDF', 'https://back.apisunat.com/documents/6a67897e1a69570021a9cf4b/getPDF/ticket80mm/10626765411-03-B001-00000025.PDF', 'https://back.apisunat.com/documents/6a67897e1a69570021a9cf4b/getPDF/A5/10626765411-03-B001-00000025.PDF', 'https://back.apisunat.com/documents/6a67897e1a69570021a9cf4b/getPDF/A4/10626765411-03-B001-00000025.PDF', '2026-07-27 11:38:09', '2026-07-27 15:06:37', NULL),
	(65, 4, 7, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000026', '6a67b9461a69570021a9d72c', 'ACEPTADO', 'CARD', 'CASH', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a67b9461a69570021a9d72c/getPDF/ticket58mm/10626765411-03-B001-00000026.PDF', 'https://back.apisunat.com/documents/6a67b9461a69570021a9d72c/getPDF/ticket80mm/10626765411-03-B001-00000026.PDF', 'https://back.apisunat.com/documents/6a67b9461a69570021a9d72c/getPDF/A5/10626765411-03-B001-00000026.PDF', 'https://back.apisunat.com/documents/6a67b9461a69570021a9d72c/getPDF/A4/10626765411-03-B001-00000026.PDF', '2026-07-27 15:02:02', '2026-07-27 15:06:41', NULL),
	(66, 4, 4, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000027', '6a67ba07c643170021f3df95', 'ACEPTADO', 'YAPE', 'CREDIT', 40.00, 0.00, 0.00, 40.00, 10.00, 30.00, 'PARTIAL', '2026-07-31', 'COMPLETED', 'https://back.apisunat.com/documents/6a67ba07c643170021f3df95/getPDF/ticket58mm/10626765411-03-B001-00000027.PDF', 'https://back.apisunat.com/documents/6a67ba07c643170021f3df95/getPDF/ticket80mm/10626765411-03-B001-00000027.PDF', 'https://back.apisunat.com/documents/6a67ba07c643170021f3df95/getPDF/A5/10626765411-03-B001-00000027.PDF', 'https://back.apisunat.com/documents/6a67ba07c643170021f3df95/getPDF/A4/10626765411-03-B001-00000027.PDF', '2026-07-27 15:05:27', '2026-07-27 15:06:46', NULL),
	(67, 4, 7, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000028', '6a67c5e51a69570021a9d9ed', 'ACEPTADO', 'CARD', 'CREDIT', 15.00, 0.00, 0.00, 15.00, 1.00, 14.00, 'PARTIAL', '2026-07-29', 'COMPLETED', 'https://back.apisunat.com/documents/6a67c5e51a69570021a9d9ed/getPDF/ticket58mm/10626765411-03-B001-00000028.PDF', 'https://back.apisunat.com/documents/6a67c5e51a69570021a9d9ed/getPDF/ticket80mm/10626765411-03-B001-00000028.PDF', 'https://back.apisunat.com/documents/6a67c5e51a69570021a9d9ed/getPDF/A5/10626765411-03-B001-00000028.PDF', 'https://back.apisunat.com/documents/6a67c5e51a69570021a9d9ed/getPDF/A4/10626765411-03-B001-00000028.PDF', '2026-07-27 15:55:53', '2026-07-28 11:15:50', NULL),
	(68, 4, 2, 40, 2, '2026-07-27 00:00:00', 'BOLETA', 'B001', '00000029', '6a67cc54c643170021f3e3c6', 'ACEPTADO', 'CASH', 'CREDIT', 7.50, 0.00, 0.00, 7.50, 4.00, 3.50, 'PARTIAL', '2026-08-15', 'COMPLETED', 'https://back.apisunat.com/documents/6a67cc54c643170021f3e3c6/getPDF/ticket58mm/10626765411-03-B001-00000029.PDF', 'https://back.apisunat.com/documents/6a67cc54c643170021f3e3c6/getPDF/ticket80mm/10626765411-03-B001-00000029.PDF', 'https://back.apisunat.com/documents/6a67cc54c643170021f3e3c6/getPDF/A5/10626765411-03-B001-00000029.PDF', 'https://back.apisunat.com/documents/6a67cc54c643170021f3e3c6/getPDF/A4/10626765411-03-B001-00000029.PDF', '2026-07-27 16:23:16', '2026-07-28 09:02:27', NULL),
	(69, 4, 4, 41, 4, '2026-08-04 00:00:00', 'BOLETA', 'B001', '00000040', '6a721e990eb857002143df3f', 'ACEPTADO', 'CARD', 'CREDIT', 120.00, 0.00, 0.00, 120.00, 50.00, 70.00, 'PARTIAL', '2026-09-30', 'COMPLETED', 'https://back.apisunat.com/documents/6a721e990eb857002143df3f/getPDF/ticket58mm/10626765411-03-B001-00000040.PDF', 'https://back.apisunat.com/documents/6a721e990eb857002143df3f/getPDF/ticket80mm/10626765411-03-B001-00000040.PDF', 'https://back.apisunat.com/documents/6a721e990eb857002143df3f/getPDF/A5/10626765411-03-B001-00000040.PDF', 'https://back.apisunat.com/documents/6a721e990eb857002143df3f/getPDF/A4/10626765411-03-B001-00000040.PDF', '2026-08-04 12:17:00', '2026-08-04 12:17:48', NULL),
	(70, 4, 3, 40, 2, '2026-08-19 00:00:00', 'BOLETA', 'B001', '00000043', '6a8660ac07c0740021d30866', 'PENDIENTE', 'CARD', 'CASH', 15.00, 0.00, 0.00, 15.00, 15.00, 0.00, 'PAID', NULL, 'COMPLETED', 'https://back.apisunat.com/documents/6a8660ac07c0740021d30866/getPDF/ticket58mm/10626765411-03-B001-00000043.PDF', 'https://back.apisunat.com/documents/6a8660ac07c0740021d30866/getPDF/ticket80mm/10626765411-03-B001-00000043.PDF', 'https://back.apisunat.com/documents/6a8660ac07c0740021d30866/getPDF/A5/10626765411-03-B001-00000043.PDF', 'https://back.apisunat.com/documents/6a8660ac07c0740021d30866/getPDF/A4/10626765411-03-B001-00000043.PDF', '2026-08-19 21:04:14', '2026-08-19 21:04:27', NULL),
	(71, 4, 2, 40, 2, '2026-08-19 00:00:00', 'FACTURA', 'F001', '', NULL, 'ERROR', 'CARD', 'CASH', 60.00, 0.00, 0.00, 60.00, 60.00, 0.00, 'PAID', NULL, 'CANCELLED', NULL, NULL, NULL, NULL, '2026-08-19 21:22:59', '2026-08-19 21:23:32', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.sale_details: ~20 rows (aproximadamente)
DELETE FROM `sale_details`;
INSERT INTO `sale_details` (`id`, `sale_id`, `product_id`, `quantity`, `sale_price`, `unit_cost`, `total_cost`, `discount`, `subtotal`, `profit`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(64, 50, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-20 09:28:44', '2026-07-20 09:28:44', NULL),
	(65, 51, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-20 09:32:44', '2026-07-20 09:32:44', NULL),
	(66, 52, 16, 2.00, 7.50, 5.50, 11.00, 0.00, 15.00, 4.00, '2026-07-20 10:11:08', '2026-07-20 10:11:08', NULL),
	(67, 53, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-20 10:12:17', '2026-07-20 10:12:17', NULL),
	(68, 54, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-20 10:22:02', '2026-07-20 10:22:02', NULL),
	(69, 55, 13, 5.00, 60.00, 40.00, 200.00, 0.00, 300.00, 100.00, '2026-07-21 10:48:54', '2026-07-21 10:48:54', NULL),
	(70, 56, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-21 10:52:04', '2026-07-21 10:52:04', NULL),
	(71, 57, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-07-22 10:58:10', '2026-07-22 10:58:10', NULL),
	(74, 60, 16, 5.00, 7.50, 5.50, 27.50, 0.00, 37.50, 10.00, '2026-07-22 12:59:20', '2026-07-22 12:59:20', NULL),
	(75, 60, 13, 3.00, 60.00, 40.00, 120.00, 0.00, 180.00, 60.00, '2026-07-22 12:59:20', '2026-07-22 12:59:20', NULL),
	(76, 61, 13, 5.00, 60.00, 40.00, 200.00, 0.00, 300.00, 100.00, '2026-07-22 15:40:37', '2026-07-22 15:40:37', NULL),
	(77, 62, 17, 5.00, 40.00, 30.00, 150.00, 0.00, 200.00, 50.00, '2026-07-22 20:24:55', '2026-07-22 20:24:55', NULL),
	(78, 63, 13, 5.00, 60.00, 40.00, 200.00, 0.00, 300.00, 100.00, '2026-07-27 11:21:04', '2026-07-27 11:21:04', NULL),
	(79, 63, 14, 2.00, 70.00, 60.00, 120.00, 0.00, 140.00, 20.00, '2026-07-27 11:21:04', '2026-07-27 11:21:04', NULL),
	(80, 64, 16, 2.00, 7.50, 5.50, 11.00, 0.00, 15.00, 4.00, '2026-07-27 11:38:09', '2026-07-27 11:38:09', NULL),
	(81, 65, 13, 1.00, 60.00, 40.00, 40.00, 0.00, 60.00, 20.00, '2026-07-27 15:02:02', '2026-07-27 15:02:02', NULL),
	(82, 66, 17, 1.00, 40.00, 30.00, 30.00, 0.00, 40.00, 10.00, '2026-07-27 15:05:27', '2026-07-27 15:05:27', NULL),
	(83, 67, 16, 2.00, 7.50, 5.50, 11.00, 0.00, 15.00, 4.00, '2026-07-27 15:55:53', '2026-07-27 15:55:53', NULL),
	(84, 68, 16, 1.00, 7.50, 5.50, 5.50, 0.00, 7.50, 2.00, '2026-07-27 16:23:16', '2026-07-27 16:23:16', NULL),
	(85, 69, 15, 2.00, 60.00, 50.00, 100.00, 0.00, 120.00, 20.00, '2026-08-04 12:17:00', '2026-08-04 12:17:00', NULL),
	(86, 70, 16, 2.00, 7.50, 5.50, 11.00, 0.00, 15.00, 4.00, '2026-08-19 21:04:14', '2026-08-19 21:04:14', NULL),
	(87, 71, 15, 1.00, 60.00, 50.00, 50.00, 0.00, 60.00, 10.00, '2026-08-19 21:22:59', '2026-08-19 21:22:59', NULL);

-- Volcando estructura para tabla db_nexopos_app.sale_payments
CREATE TABLE IF NOT EXISTS `sale_payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int unsigned NOT NULL,
  `branch_id` int unsigned NOT NULL,
  `sale_id` bigint unsigned NOT NULL,
  `user_id` int unsigned NOT NULL,
  `cash_session_id` int unsigned DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `payment_method` enum('CASH','CARD','TRANSFER','YAPE','PLIN','OTHER') NOT NULL DEFAULT 'CASH',
  `reference` varchar(100) DEFAULT NULL,
  `payment_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `payment_type` enum('INITIAL','INSTALLMENT','FINAL') NOT NULL DEFAULT 'INSTALLMENT',
  `status` enum('ACTIVE','CANCELLED') NOT NULL DEFAULT 'ACTIVE',
  `observation` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_sale_payment_company` (`company_id`),
  KEY `idx_sale_payment_branch` (`branch_id`),
  KEY `idx_sale_payment_sale` (`sale_id`),
  KEY `idx_sale_payment_user` (`user_id`),
  KEY `idx_sale_payment_session` (`cash_session_id`),
  KEY `idx_sale_payment_date` (`payment_date`),
  CONSTRAINT `fk_sale_payment_branch` FOREIGN KEY (`branch_id`) REFERENCES `branches` (`id`),
  CONSTRAINT `fk_sale_payment_company` FOREIGN KEY (`company_id`) REFERENCES `companies` (`id`),
  CONSTRAINT `fk_sale_payment_sale` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`),
  CONSTRAINT `fk_sale_payment_session` FOREIGN KEY (`cash_session_id`) REFERENCES `cash_sessions` (`id`),
  CONSTRAINT `fk_sale_payment_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Volcando datos para la tabla db_nexopos_app.sale_payments: ~8 rows (aproximadamente)
DELETE FROM `sale_payments`;
INSERT INTO `sale_payments` (`id`, `company_id`, `branch_id`, `sale_id`, `user_id`, `cash_session_id`, `amount`, `payment_method`, `reference`, `payment_date`, `payment_type`, `status`, `observation`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, 2, 65, 40, NULL, 60.00, 'CARD', NULL, '2026-07-27 00:00:00', 'FINAL', 'ACTIVE', NULL, '2026-07-27 15:02:02', '2026-07-27 15:02:02', NULL),
	(2, 4, 2, 66, 40, NULL, 10.00, 'YAPE', NULL, '2026-07-27 00:00:00', 'INITIAL', 'ACTIVE', NULL, '2026-07-27 15:05:27', '2026-07-27 15:05:27', NULL),
	(3, 4, 2, 67, 40, NULL, 1.00, 'CARD', NULL, '2026-07-27 00:00:00', 'INITIAL', 'ACTIVE', NULL, '2026-07-27 15:55:53', '2026-07-27 15:55:53', NULL),
	(4, 4, 2, 68, 40, NULL, 4.00, 'CASH', NULL, '2026-07-27 00:00:00', 'INITIAL', 'ACTIVE', NULL, '2026-07-27 16:23:16', '2026-07-27 16:23:16', NULL),
	(5, 4, 4, 69, 41, NULL, 20.00, 'CARD', NULL, '2026-08-04 00:00:00', 'INITIAL', 'ACTIVE', NULL, '2026-08-04 12:17:00', '2026-08-04 12:17:00', NULL),
	(6, 4, 4, 69, 41, NULL, 30.00, 'PLIN', '3I944', '2026-08-04 00:00:00', 'INSTALLMENT', 'ACTIVE', 'SEGUNDO PAGO', '2026-08-04 12:17:48', '2026-08-04 12:17:48', NULL),
	(7, 4, 2, 70, 40, NULL, 15.00, 'CARD', NULL, '2026-08-19 00:00:00', 'FINAL', 'ACTIVE', NULL, '2026-08-19 21:04:14', '2026-08-19 21:04:14', NULL),
	(8, 4, 2, 71, 40, NULL, 60.00, 'CARD', NULL, '2026-08-19 00:00:00', 'FINAL', 'ACTIVE', NULL, '2026-08-19 21:22:59', '2026-08-19 21:22:59', NULL);

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

-- Volcando datos para la tabla db_nexopos_app.storage_files: ~0 rows (aproximadamente)
DELETE FROM `storage_files`;

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.suppliers: ~3 rows (aproximadamente)
DELETE FROM `suppliers`;
INSERT INTO `suppliers` (`id`, `company_id`, `document_number`, `business_name`, `contact`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(1, 4, '67672672811', 'SODEXO', 'Omar Coronado', '927350176', 'serquencoronadomar@gmail.com', 'Peru, Pacora', 1, '2026-07-07 17:49:17', '2026-07-07 17:53:28', NULL),
	(2, 4, '7373423423', 'Ropa Petitos', 'Luis Lopez Aliafa', '988787867', 'luis@gmail.com', 'calle san jose 568 - pacora lambayeque', 1, '2026-07-07 17:57:17', '2026-07-07 17:57:17', NULL),
	(3, 4, '76782727', 'La Positiva', 'Julio Acosta Bances', '987867567', 'julioacosta@gmail.com', 'Lambayeque Grau #167 - Perú', 1, '2026-07-07 21:36:57', '2026-07-07 21:36:57', NULL),
	(4, 4, '423775', 'RANGERS TEAM', 'Serquen Coronado Omar David', '927383722', 'SERQUEN@GMAIL.COM', 'PUEBLO VIEJO, PACORA, LAMBAYEQUE', 1, '2026-08-04 10:37:56', '2026-08-04 10:37:56', NULL);

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
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Volcando datos para la tabla db_nexopos_app.users: ~5 rows (aproximadamente)
DELETE FROM `users`;
INSERT INTO `users` (`id`, `foto_id`, `name`, `paternal_surname`, `maternal_surname`, `username`, `email`, `password`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(38, NULL, 'Richar Nixon', 'Coronado', 'Inoñan', 'richar', 'richarnixoncoronadoinonan@gmail.com', '$2y$10$xgmK7Nlc34AR1WmqwVn8teNNBPvw6.9byqeStOT7Ay8PJj.07B1JC', 1, '2025-06-12 17:34:03', '2026-07-19 21:27:32', NULL),
	(39, NULL, 'Nicolas', 'Cotrina', 'Llontop', 'nico', 'stafano@gmail.com', '$2y$10$xgmK7Nlc34AR1WmqwVn8teNNBPvw6.9byqeStOT7Ay8PJj.07B1JC', 1, '2025-06-18 18:08:03', '2026-07-19 21:27:21', NULL),
	(40, NULL, 'Omar', 'Serquen', 'Coronado', 'omar', 'serquencoronadoomardavid@gmail.com', '$2y$10$mV.tFedxFk9g1Lh8gkA4NOx0uhGsfI4HBQBkKxFkSdB4qGZtl0BhG', 1, '2026-07-09 19:34:14', '2026-07-09 19:34:14', NULL),
	(41, NULL, 'Maria', 'Samame', 'Lopez', 'maria', 'mariasamame@gmail.com', '$2y$10$x3qyUgoETJII3l88sZquQ.yvSPbXi.ST.h8lqk5dZlrLIV/rdffry', 1, '2026-07-10 11:33:14', '2026-07-21 10:10:55', NULL),
	(42, NULL, 'Jhampier', 'Serquen', 'Coronado', 'jhampier', 'jhampier@gmail.com', '$2y$10$dMO/Y8De9grRq/X7sw71Begvfl.QtNuTHYo7nxb2RMHomKsPXibDe', 1, '2026-07-21 10:41:21', '2026-07-21 10:41:21', NULL);

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

-- Volcando datos para la tabla db_nexopos_app.user_company_role: ~5 rows (aproximadamente)
DELETE FROM `user_company_role`;
INSERT INTO `user_company_role` (`user_id`, `company_id`, `role_id`, `branch_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
	(38, 4, 5, 1, '2025-06-14 08:57:52', '2026-07-09 13:28:19', NULL),
	(39, 5, 5, 3, '2025-06-18 18:08:51', '2026-07-09 19:52:41', NULL),
	(40, 4, 7, 2, '2026-07-09 19:34:14', '2026-07-21 10:11:14', NULL),
	(41, 4, 6, 4, '2026-07-10 11:33:14', '2026-07-10 11:33:14', NULL),
	(42, 4, 5, 4, '2026-07-21 10:41:21', '2026-07-21 10:41:21', NULL);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
