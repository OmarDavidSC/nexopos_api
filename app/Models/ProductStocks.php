<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class ProductStocks extends Model
{
    use SoftDeletes;
    protected $table = 'product_stocks';
    protected $fillable = [
        'id',
        'company_id',
        'branch_id',
        'product_id',
        'current_stock',
        'minimum_stock',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}
