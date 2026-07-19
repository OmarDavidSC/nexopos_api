<?php

namespace App\Controllers;

use App\Dows\ReportProfitDow;

class ReportProfitController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new ReportProfitDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }
}
