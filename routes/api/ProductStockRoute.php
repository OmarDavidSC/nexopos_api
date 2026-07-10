<?php

$map->attach('stocks.', '/stock', function ($map) {

    $map->post('index', '/{branch_id}/index', [
        'Controller' => 'App\Controllers\ProductStockController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\ProductStockController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\ProductStockController',
        'Action' => 'update'
    ]);
});
