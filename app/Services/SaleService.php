<?php

namespace App\Services;

use App\Models\Sale;
use App\Repositories\SaleRepository;
use App\Utilities\FG;

class SaleService
{


    public static function createInitialPayment(Sale $sale, array $input)
    {
        if ($sale->amount_paid <= 0) {
            return;
        }

        $repository = new SaleRepository();

        $repository->createPayment([
            'company_id'     => $sale->company_id,
            'branch_id'      => $sale->branch_id,
            'sale_id'        => $sale->id,
            'user_id'        => $sale->user_id,
            'amount'         => $sale->amount_paid,
            'payment_method' => $input['payment_method'],
            'payment_type'   => $sale->payment_condition == 'CREDIT' ? 'INITIAL' : 'FINAL',
            'payment_date'   => $sale->sale_date,
        ]);
    }
}
