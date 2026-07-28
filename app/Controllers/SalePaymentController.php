<?php

namespace App\Controllers;

use App\Dows\SalePaymentDow;

class SalePaymentController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new SalePaymentDow();
    }

    public function payments($request)
    {
        return Response::json($this->dow->payments($request));
    }

    public function store($request)
    {
        return Response::json($this->dow->store($request));
    }
}
