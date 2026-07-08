<?php

$map->attach('sales.', '/sale', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\SaleController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\SaleController',
        'Action' => 'store'
    ]);
    $map->post('show', '/{id}/show', [
        'Controller' => 'App\Controllers\SaleController',
        'Action' => 'show'
    ]);
    $map->post('cancel', '/{id}/cancel', [
        'Controller' => 'App\Controllers\SaleController',
        'Action' => 'cancel'
    ]);
});
