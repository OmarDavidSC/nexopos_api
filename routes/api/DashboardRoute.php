<?php

$map->attach('dashboards.', '/dashboard', function ($map) {

    $map->get('index', '', [
        'Controller' => 'App\Controllers\DashboardController',
        'Action' => 'index'
    ]);
});
