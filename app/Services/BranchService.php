<?php

namespace App\Services;

use App\Middlewares\Application;

class BranchService
{
    public static function canViewAllBranches(): bool
    {
        $role = Application::getItem('role')->name;
        return in_array($role, ['Administrador', 'Soporte']);
    }

    public static function applyBranchScope($query)
    {
        if (!self::canViewAllBranches()) {
            $query->where('branch_id', Application::getItem('branch_id'));
        }
        return $query;
    }
}
