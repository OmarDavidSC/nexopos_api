<?php

namespace App\Controllers;

use App\Dows\QuotationDow;

class QuotationController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new QuotationDow();
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

    public function accept($request)
    {
        return Response::json($this->dow->accept($request));
    }

    public function reject($request)
    {
        return Response::json($this->dow->reject($request));
    }

    public function sent($request)
    {
        return Response::json($this->dow->sent($request));
    }

    public function convert($request)
    {
        return Response::json($this->dow->convert($request));
    }

    public function cancel($request)
    {
        return Response::json($this->dow->cancel($request));
    }
}
