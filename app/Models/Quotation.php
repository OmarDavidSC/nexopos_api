<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use Pcntl\QosClass;

class Quotation extends Model
{

    use SoftDeletes;
    protected $table = 'quotations';
    protected $fillable = [
        'id',
        'company_id',
        'branch_id',
        'customer_id',
        'sale_id',
        'created_by',
        'quotation_series',
        'quotation_number',
        'issue_date',
        'expiration_date',
        'subtotal',
        'tax',
        'discount',
        'total',
        'status',
        'observations',
        'terms',
        'converted_at',
        'accepted_at',
        'rejected_at',
        'cancelled_at',
    ];

    protected $casts = [
        'issue_date' => 'datetime',
        'expiration_date' => 'date',
        'converted_at' => 'datetime',
        'accepted_at' => 'datetime',
        'rejected_at' => 'datetime',
        'cancelled_at' => 'datetime',
        'subtotal' => 'decimal:2',
        'tax' => 'decimal:2',
        'discount' => 'decimal:2',
        'total' => 'decimal:2',
    ];

    public function company()
    {
        return $this->belongsTo(Company::class, 'company_id', 'id');
    }

    public function branch()
    {
        return $this->belongsTo(Branch::class, 'branch_id', 'id');
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class, 'customer_id', 'id');
    }

    public function sale()
    {
        return $this->belongsTo(Sale::class, 'sale_id', 'id');
    }

    public function creator()
    {
        return $this->belongsTo(User::class, 'created_by', 'id');
    }

    public function details()
    {
        return $this->hasMany(QuotationDetail::class, 'quotation_id', 'id');
    }
}
