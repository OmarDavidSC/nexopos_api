<?php

$map->attach('purchases.', '/purchase', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'store'
    ]);
    $map->get('show', '/{id}/show', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'show'
    ]);
    $map->get('cancel', '/{id}/cancel', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'cancel'
    ]);
});
