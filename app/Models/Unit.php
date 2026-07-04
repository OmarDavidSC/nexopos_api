<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Unit extends Model
{

    use SoftDeletes;
    protected $table = 'units';
    protected $fillable = [
        'id',
        'company_id',
        'name',
        'abbreviation',
        'status',
    ];
}
