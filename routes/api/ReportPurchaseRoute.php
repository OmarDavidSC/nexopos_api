<?php

$map->attach('rpurchases.', '/rpurchase', function ($map) {

    $map->post('index', '', [
        'Controller' => 'App\Controllers\ReportPurchaseController',
        'Action' => 'index'
    ]);
});
