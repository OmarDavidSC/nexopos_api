<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{

    use SoftDeletes;
    protected $table = 'products';
    protected $fillable = [
        'id',
        'company_id',
        'category_id',
        'brand_id',
        'unit_id',
        'image_id',
        'code',
        'barcode',
        'name',
        'description',
        'purchase_price',
        'sale_price',
        'minimum_stock',
        'current_stock',
        'status',
    ];
}
