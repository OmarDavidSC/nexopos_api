<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CashRegister extends Model
{

    use SoftDeletes;
    protected $table = 'cash_registers';
    protected $fillable = [
        'id',
        'company_id',
        'branch_id',
        'name',
        'status',
    ];

    public function sessions()
    {
        return $this->hasMany(CashSession::class, 'cash_register_id');
    }
}
