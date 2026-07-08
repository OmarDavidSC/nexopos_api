<?php

$map->attach('customers.', '/customer', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\CustomerController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\CustomerController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\CustomerController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\CustomerController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\CustomerController',
        'Action' => 'remove'
    ]);
});
