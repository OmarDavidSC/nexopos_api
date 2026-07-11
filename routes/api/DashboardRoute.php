<?php

$map->attach('dashboards.', '/dashboard', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\DashboardController',
        'Action' => 'index'
    ]);
});
