<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class CashMovement extends Model
{

    use SoftDeletes;
    protected $table = 'cash_movements';
    protected $fillable = [
        'id',
        'company_id',
        'cash_session_id',
        'user_id',
        'type',
        'amount',
        'description',
    ];

    public function session()
    {
        return $this->belongsTo(CashSession::class, 'cash_session_id');
    }
}
