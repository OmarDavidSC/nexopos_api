<?php

namespace App\Controllers;

use App\Dows\ReportSaleDow;

class ReportSaleController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new ReportSaleDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }
}
