<?php

namespace App\Services;

use App\Models\ProductStocks;

class ProductStockService
{
    /**
     * Obtiene el stock de un producto en una sucursal.
     */
    public static function getStock(int $company_id, int $branch_id, int $product_id): ProductStocks
    {
        return ProductStocks::firstOrCreate(
            ['company_id' => $company_id, 'branch_id'  => $branch_id, 'product_id' => $product_id],
            ['current_stock' => 0, 'minimum_stock' => 0]
        );
    }

    /**
     * Incrementar stock.
     */
    public static function increase(int $company_id, int $branch_id, int $product_id, float $quantity): array
    {
        $stock = self::getStock($company_id, $branch_id, $product_id);

        $before = $stock->current_stock;
        $stock->current_stock += $quantity;
        $stock->save();

        return [
            'before' => $before,
            'after' => $stock->current_stock,
            'quantity' => $quantity,
            'stock' => $stock
        ];
    }

    /**
     * Disminuir stock.
     */
    public static function decrease(int $company_id, int $branch_id, int $product_id, float $quantity): array
    {

        $stock = self::getStock($company_id, $branch_id, $product_id);
        if ($stock->current_stock < $quantity) {
            throw new \Exception("No existe stock suficiente.");
        }

        $before = $stock->current_stock;
        $stock->current_stock -= $quantity;
        $stock->save();

        return [
            'before' => $before,
            'after' => $stock->current_stock,
            'quantity' => $quantity,
            'stock' => $stock
        ];
    }

    /**
     * Consultar stock actual.
     */
    public static function current(int $company_id, int $branch_id, int $product_id): float
    {
        return self::getStock($company_id, $branch_id, $product_id)->current_stock;
    }
}
