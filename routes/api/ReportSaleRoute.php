<?php

$map->attach('rsales.', '/rsale', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\ReportSaleController',
        'Action' => 'index'
    ]);
});
