<?php

$map->attach('brands.', '/brand', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\BrandController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\BrandController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\BrandController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\BrandController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\BrandController',
        'Action' => 'remove'
    ]);
});
