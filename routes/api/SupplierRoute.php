<?php

$map->attach('suppliers.', '/supplier', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\SupplierController',
        'Action' => 'remove'
    ]);
});
