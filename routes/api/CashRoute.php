<?php

$map->attach('categories.', '/category', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'index'
    ]);
    $map->get('show', '/{id}/show', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'show'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'update'
    ]);
    $map->post('opensession', '/opensession', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'opensession'
    ]);
    $map->post('closesession', '/closesession', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'closesession'
    ]);
    $map->post('income', '/income', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'income'
    ]);
    $map->post('expense', '/expense', [
        'Controller' => 'App\Controllers\CategoryController',
        'Action' => 'expense'
    ]);
});
