<?php

namespace App\Controllers;

use App\Dows\ReportInventoryDow;

class ReportInventoryController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new ReportInventoryDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }
}
