<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SalePayment extends Model
{

    use SoftDeletes;
    protected $table = 'sale_payments';
    protected $fillable = [
        'id',
        'company_id',
        'branch_id',
        'sale_id',
        'user_id',
        'cash_session_id',
        'amount',
        'payment_method',
        'reference',
        'payment_date',
        'payment_type',
        'status',
        'observation',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'payment_date' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class, 'company_id', 'id');
    }

    public function branch()
    {
        return $this->belongsTo(Branch::class, 'branch_id', 'id');
    }

    public function sale()
    {
        return $this->belongsTo(Sale::class, 'sale_id', 'id');
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function cashSession()
    {
        return $this->belongsTo(CashSession::class, 'chash_session_id', 'id');
    }
}
