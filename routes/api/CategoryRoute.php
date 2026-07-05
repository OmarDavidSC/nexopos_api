<?php

$map->attach('categories.', '/category', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'remove'
    ]);
});
