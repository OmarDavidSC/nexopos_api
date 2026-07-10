<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CashSession extends Model
{

    use SoftDeletes;
    protected $table = 'cash_sessions';
    protected $fillable = [
        'id',
        'company_id',
        'branch_id',
        'cash_register_id',
        'user_open_id',
        'user_close_id',
        'opening_amount',
        'expected_amount',
        'closing_amount',
        'difference',
        'status',
        'opened_at',
        'closed_at',
    ];

    public function cashRegister()
    {
        return $this->belongsTo(CashRegister::class, 'cash_register_id');
    }


    public function movements()
    {
        return $this->hasMany(CashMovement::class, 'cash_session_id');
    }
}
