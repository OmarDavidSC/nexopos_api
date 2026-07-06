<?php

$map->attach('products.', '/product', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\ProductController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\ProductController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\ProductController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\ProductController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\ProductController',
        'Action' => 'remove'
    ]);
});
