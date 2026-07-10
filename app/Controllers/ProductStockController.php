<?php

namespace App\Controllers;

use App\Dows\ProductStockDow;

class ProductStockController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new ProductStockDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }


    public function store($request)
    {
        return Response::json($this->dow->store($request));
    }

    public function update($request)
    {
        return Response::json($this->dow->update($request));
    }
}
