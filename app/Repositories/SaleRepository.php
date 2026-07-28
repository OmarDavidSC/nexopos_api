<?php

namespace App\Repositories;

use App\Models\SalePayment;
use App\Utilities\FG;


class SaleRepository
{

    public function createPayment(array $data)
    {
        $payment = new SalePayment();
        $payment->company_id = $data['company_id'];
        $payment->branch_id = $data['branch_id'];
        $payment->sale_id = $data['sale_id'];
        $payment->user_id = $data['user_id'];
        $payment->amount = $data['amount'];
        $payment->payment_method = $data['payment_method'];
        $payment->payment_type = $data['payment_type'];
        $payment->payment_date = $data['payment_date'];
        $payment->status = 'ACTIVE';
        $payment->save();
        return $payment;
    }
}
