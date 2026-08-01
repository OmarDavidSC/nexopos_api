<?php

namespace App\Repositories;

use App\Models\Quotation;
use App\Models\QuotationDetail;
use App\Services\BranchService;
use App\Utilities\FG;
use Illuminate\Database\Capsule\Manager as DB;

class QuotationDetailRepository
{
    public function createDetails(int $quotation_id, array $details): void
    {
        $rows = [];
        foreach ($details as $detail) {
            $rows[] = [
                'quotation_id' => $quotation_id,
                'product_id' => $detail['product_id'],
                'quantity' => $detail['quantity'],
                'unit_price' => $detail['unit_price'],
                'discount_percentage' => $detail['discount_percentage'] ?? 0,
                'discount' => $detail['discount'] ?? 0,
                'subtotal' => $detail['subtotal'],
                'tax' => $detail['tax'],
                'total' => $detail['total'],
                'description' => $detail['description'] ?? null,
            ];
        }
        QuotationDetail::query()->insert($rows);
    }
}
