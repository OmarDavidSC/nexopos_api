<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{

    use SoftDeletes;
    protected $table = 'customers';
    protected $fillable = [
        'id',
        'company_id',
        'document_type',
        'document_number',
        'name',
        'phone',
        'email',
        'address',
        'status',
    ];
}
