<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class PurchaseDetail extends Model
{

    use SoftDeletes;
    protected $table = 'purchase_details';
    protected $fillable = [
        'id',
        'purchase_id',
        'product_id',
        'quantity',
        'purchase_price',
        'subtotal',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
