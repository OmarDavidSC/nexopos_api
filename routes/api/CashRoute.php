<?php

$map->attach('cahses.', '/cash', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'index'
    ]);
    $map->get('show', '/{id}/show', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'show'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'update'
    ]);
    $map->post('opensession', '/opensession', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'opensession'
    ]);
    $map->post('closesession', '/closesession', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'closesession'
    ]);
    $map->post('income', '/income', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'income'
    ]);
    $map->post('expense', '/expense', [
        'Controller' => 'App\Controllers\CashController',
        'Action' => 'expense'
    ]);
});
