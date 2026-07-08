<?php

$map->attach('purchases.', '/purchase', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\PurchaseController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\PurchaseController',
        'Action' => 'store'
    ]);
    $map->post('show', '/{id}/show', [
        'Controller' => 'App\Controllers\PurchaseController',
        'Action' => 'show'
    ]);
    $map->post('cancel', '/{id}/cancel', [
        'Controller' => 'App\Controllers\PurchaseController',
        'Action' => 'cancel'
    ]);
});
