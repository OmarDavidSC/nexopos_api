<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SaleDetail extends Model
{

    use SoftDeletes;
    protected $table = 'sale_details';
    protected $fillable = [
        'id',
        'sale_id',
        'product_id',
        'quantity',
        'sale_price',
        'discount',
        'subtotal',
    ];

    public function sale()
    {
        return $this->belongsTo(Sale::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
