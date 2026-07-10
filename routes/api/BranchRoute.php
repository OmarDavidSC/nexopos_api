<?php

$map->attach('branches.', '/branch', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\BranchController',
        'Action' => 'index'
    ]);
    $map->get('adm', '/adm', [
        'Controller' => 'App\Controllers\BranchController',
        'Action' => 'adm'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\BranchController',
        'Action' => 'store'
    ]);
    $map->post('update', '/{id}/update', [
        'Controller' => 'App\Controllers\BranchController',
        'Action' => 'update'
    ]);
    $map->post('remove', '/{id}/remove', [
        'Controller' => 'App\Controllers\BranchController',
        'Action' => 'remove'
    ]);
});
