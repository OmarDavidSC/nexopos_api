<?php

namespace App\Controllers;

use App\Dows\SaleDow;

class SaleController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new SaleDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }

    public function store($request)
    {
        return Response::json($this->dow->store($request));
    }

    public function show($request)
    {
        return Response::json($this->dow->show($request));
    }

    public function cancel($request)
    {
        return Response::json($this->dow->cancel($request));
    }
}
