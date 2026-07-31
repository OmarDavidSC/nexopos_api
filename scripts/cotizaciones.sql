CREATE TABLE quotations (
    id INT(10) AUTO_INCREMENT PRIMARY KEY,

    company_id INT(10) UNSIGNED NOT NULL,
    branch_id INT(10) UNSIGNED NOT NULL,
    customer_id INT(10) UNSIGNED NULL,
    sale_id BIGINT(20) UNSIGNED NULL,
    created_by INT(10) UNSIGNED NOT NULL,

    quotation_series VARCHAR(10) NOT NULL DEFAULT 'COT',
    quotation_number VARCHAR(20) NOT NULL,

    issue_date DATETIME NOT NULL,
    expiration_date DATE NULL,

    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    tax DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    discount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(12, 2) NOT NULL DEFAULT 0.00,

    status ENUM(
        'DRAFT',
        'SENT',
        'ACCEPTED',
        'REJECTED',
        'EXPIRED',
        'CONVERTED',
        'CANCELLED'
    ) NOT NULL DEFAULT 'DRAFT',

    observations TEXT NULL,
    terms TEXT NULL,

    converted_at DATETIME NULL,
    accepted_at DATETIME NULL,
    rejected_at DATETIME NULL,
    cancelled_at DATETIME NULL,

    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,

    CONSTRAINT fk_quotations_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id),

    CONSTRAINT fk_quotations_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(id),

    CONSTRAINT fk_quotations_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_quotations_sale
        FOREIGN KEY (sale_id)
        REFERENCES sales(id)
        ON DELETE SET NULL,

    CONSTRAINT fk_quotations_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id),

    UNIQUE KEY uk_quotation_company_series_number (
        company_id,
        quotation_series,
        quotation_number
    ),

    INDEX idx_quotations_company (company_id),
    INDEX idx_quotations_branch (branch_id),
    INDEX idx_quotations_customer (customer_id),
    INDEX idx_quotations_sale (sale_id),
    INDEX idx_quotations_status (status),
    INDEX idx_quotations_issue_date (issue_date),
    INDEX idx_quotations_expiration_date (expiration_date),
    INDEX idx_quotations_deleted_at (deleted_at)
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=UTF8MB4_UNICODE_CI;

CREATE TABLE `quotation_details` (
    `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,

    `quotation_id` INT(10) NOT NULL,
    `product_id` INT(10) UNSIGNED NOT NULL,

    `quantity` DECIMAL(12,3) NOT NULL DEFAULT '1.000',
    `unit_price` DECIMAL(12,2) NOT NULL DEFAULT '0.00',

    `discount_percentage` DECIMAL(5,2) NOT NULL DEFAULT '0.00',
    `discount` DECIMAL(12,2) NOT NULL DEFAULT '0.00',

    `subtotal` DECIMAL(12,2) NOT NULL DEFAULT '0.00',
    `tax` DECIMAL(12,2) NOT NULL DEFAULT '0.00',
    `total` DECIMAL(12,2) NOT NULL DEFAULT '0.00',

    `description` VARCHAR(500) NULL DEFAULT NULL COLLATE 'utf8mb4_unicode_ci',

    `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `deleted_at` TIMESTAMP NULL DEFAULT NULL,

    PRIMARY KEY (`id`) USING BTREE,

    INDEX `idx_quotation_details_quotation` (`quotation_id`) USING BTREE,
    INDEX `idx_quotation_details_product` (`product_id`) USING BTREE,
    INDEX `idx_quotation_details_deleted_at` (`deleted_at`) USING BTREE,

    CONSTRAINT `fk_quotation_details_quotation`
        FOREIGN KEY (`quotation_id`)
        REFERENCES `quotations` (`id`)
        ON UPDATE NO ACTION
        ON DELETE CASCADE,

    CONSTRAINT `fk_quotation_details_product`
        FOREIGN KEY (`product_id`)
        REFERENCES `products` (`id`)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION

)
COLLATE='utf8mb4_unicode_ci'
ENGINE=InnoDB;