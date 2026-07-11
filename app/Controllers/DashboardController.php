<?php

namespace App\Controllers;

use App\Dows\DashboardDow;

class DashboardController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new DashboardDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }
}
