<?php

$map->attach('paymentssa.', '/spayment', function ($map) {
    $map->post('payments', '/{id}/payments', [
        'Controller' => 'App\Controllers\SalePaymentController',
        'Action' => 'payments'
    ]);
    $map->post('store', '/{id}/store', [
        'Controller' => 'App\Controllers\SalePaymentController',
        'Action' => 'store'
    ]);
});
