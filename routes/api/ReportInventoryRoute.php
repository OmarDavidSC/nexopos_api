<?php

$map->attach('rinventorys.', '/rinventory', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\ReportInventoryController',
        'Action' => 'index'
    ]);
});
