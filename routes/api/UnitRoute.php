<?php

$map->attach('units.', '/unit', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\UnitController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\UnitController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\UnitController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\UnitController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\UnitController',
        'Action' => 'remove'
    ]);
});
