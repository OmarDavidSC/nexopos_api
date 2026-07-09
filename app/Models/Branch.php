<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Branch extends Model
{

    use SoftDeletes;
    protected $table = 'branches';
    protected $fillable = [
        'id',
        'company_id',
        'name',
        'code',
        'phone',
        'email',
        'address',
        'status',
    ];
}
