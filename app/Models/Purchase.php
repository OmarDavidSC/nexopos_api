<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Purchase extends Model
{

    use SoftDeletes;
    protected $table = 'purchases';
    protected $fillable = [
        'id',
        'company_id',
        'supplier_id',
        'user_id',
        'purchase_date',
        'voucher_type',
        'voucher_series',
        'voucher_number',
        'subtotal',
        'tax',
        'discount',
        'total',
        'observation',
        'status',
    ];

    public function supplier()
    {
        return $this->belongsTo(Supplier::class, 'supplier_id');
    }

    // public function supplier()
    // {
    //     return $this->belongsTo(Supplier::class);
    // }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function details()
    {
        return $this->hasMany(PurchaseDetail::class, 'purchase_id');
    }
}
