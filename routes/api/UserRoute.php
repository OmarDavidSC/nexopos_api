<?php

$map->attach('users.', '/user', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\UserController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\UserController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\UserController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\UserController',
        'Action' => 'remove'
    ]);
    $map->get('role', '/role', [
        'Controller' => 'App\Controllers\UserController',
        'Action' => 'role'
    ]);
});
