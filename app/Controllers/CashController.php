<?php

namespace App\Controllers;

use App\Dows\CashDow;

class CashController extends BaseController
{

    private $dow;

    public function __construct()
    {
        $this->dow = new CashDow();
    }

    public function index($request)
    {
        return Response::json($this->dow->index($request));
    }

    public function show($request)
    {
        return Response::json($this->dow->show($request));
    }

    public function store($request)
    {
        return Response::json($this->dow->store($request));
    }

    public function update($request)
    {
        return Response::json($this->dow->update($request));
    }

    public function opensession($request)
    {
        return Response::json($this->dow->opensession($request));
    }

    public function closesession($request)
    {
        return Response::json($this->dow->closesession($request));
    }

    public function income($request)
    {
        return Response::json($this->dow->income($request));
    }

    public function expense($request)
    {
        return Response::json($this->dow->expense($request));
    }
}
