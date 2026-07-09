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

    public function category()
    {
        return $this->belongsTo(Category::class, 'category_id', 'id');
    }

    public function brand()
    {
        return $this->belongsTo(Brand::class, 'brand_id', 'id');
    }

    public function unit()
    {
        return $this->belongsTo(Unit::class, 'unit_id', 'id');
    }
}
