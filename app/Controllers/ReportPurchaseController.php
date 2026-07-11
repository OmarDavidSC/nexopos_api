<?php

namespace App\Controllers;

use App\Dows\ReportPurchaseDow;

class ReportPurchaseController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new ReportPurchaseDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }
}
