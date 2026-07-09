<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Sale extends Model
{

    use SoftDeletes;
    protected $table = 'sales';
    protected $fillable = [
        'id',
        'company_id',
        'customer_id',
        'user_id',
        'branch_id',
        'sale_date',
        'voucher_type',
        'voucher_series',
        'voucher_number',
        'payment_method',
        'subtotal',
        'tax',
        'discount',
        'total',
        'status',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function details()
    {
        return $this->hasMany(SaleDetail::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
