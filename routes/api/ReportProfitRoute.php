<?php

$map->attach('rprofits.', '/rprofit', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\ReportProfitController',
        'Action' => 'index'
    ]);
});
