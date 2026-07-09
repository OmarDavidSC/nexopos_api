<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class InventoryMovements extends Model
{

    use SoftDeletes;
    protected $table = 'inventory_movements';
    protected $fillable = [
        'id',
        'company_id',
        'product_id',
        'user_id',
        'branch_id',
        'type',
        'quantity',
        'stock_before',
        'stock_after',
        'reference_type',
        'reference_id',
        'observation',
    ];
}
