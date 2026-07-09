<?php

namespace App\Services;

use App\Models\InventoryMovements;

class InventoryService
{
    public static function createMovement(
        int $company_id,
        int $product_id,
        int $user_id,
        int $branch_id,
        string $type,
        int $quantity,
        float $stock_before,
        float $stock_after,
        string $reference_type,
        int $reference_id,
        ?string $observation = null
    ) {

        $movement = new InventoryMovements();
        $movement->company_id = $company_id;
        $movement->product_id = $product_id;
        $movement->user_id = $user_id;
        $movement->branch_id = $branch_id;
        $movement->type = $type;
        $movement->quantity = $quantity;
        $movement->stock_before = $stock_before;
        $movement->stock_after = $stock_after;
        $movement->reference_type = $reference_type;
        $movement->reference_id = $reference_id;
        $movement->observation = $observation;
        $movement->save();
        return $movement;
    }
}
