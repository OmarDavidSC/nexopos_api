<?php

$map->attach('api.', '/api', function ($map) {
    $map->attach('aws.', '/aws', function ($map) {
        include __DIR__ . "/api/S3AwsRoute.php";
    });

    include __DIR__ . "/api/AuthRoute.php";
    include __DIR__ . "/api/VimeoRoute.php";
    include __DIR__ . "/api/CompanyRoute.php";
    include __DIR__ . "/api/FileRoute.php";
    include __DIR__ . "/api/UtiliesRoute.php";
    include __DIR__ . "/api/MeetingRoute.php";
    include __DIR__ . "/api/S3AwsRoute.php";
    include __DIR__ . "/api/ProfileRoute.php";
    include __DIR__ . "/api/UserRoute.php";
    include __DIR__ . "/api/BranchRoute.php";

    //1 modulo
    include __DIR__ . "/api/BrandRoute.php";
    include __DIR__ . "/api/CategoryRoute.php";
    include __DIR__ . "/api/UnitRoute.php";
    include __DIR__ . "/api/ProductRoute.php";
    include __DIR__ . "/api/ProductStockRoute.php";
    //2 modulo
    include __DIR__ . "/api/SupplierRoute.php";
    include __DIR__ . "/api/PurchaseRoute.php";
    //3 modulo
    include __DIR__ . "/api/CustomerRoute.php";
    include __DIR__ . "/api/SaleRoute.php";
    //4 caja
    include __DIR__ . "/api/CashRoute.php";
});
