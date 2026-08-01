<?php

$map->attach('quotations.', '/quotation', function ($map) {
    $map->post('index', '', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'index'
    ]);
    $map->post('store', '/store', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'store'
    ]);
    $map->post('show', '/{id}/show', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'show'
    ]);
    $map->post('accept', '/{id}/accept', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'accept'
    ]);
    $map->post('reject', '/{id}/reject', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'reject'
    ]);
    $map->post('sent', '/{id}/sent', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'sent'
    ]);
    $map->post('convert', '/{id}/convert', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'convert'
    ]);
    $map->post('cancel', '/{id}/cancel', [
        'Controller' => 'App\Controllers\QuotationController',
        'Action' => 'cancel'
    ]);
});
