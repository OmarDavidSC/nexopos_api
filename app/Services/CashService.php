<?php

namespace App\Services;

use App\Models\CashMovement;
use App\Models\CashSession;
use App\Utilities\FG;

class CashService
{
    /**
     * Obtiene la sesión abierta de una caja.
     */
    public static function currentSession(
        int $company_id,
        int $branch_id,
        int $cash_register_id
    ): ?CashSession {
        return CashSession::where('company_id', $company_id)
            ->where('branch_id', $branch_id)
            ->where('cash_register_id', $cash_register_id)
            ->where('status', 'OPEN')
            ->first();
    }

    /**
     * Verifica si existe una sesión abierta.
     */
    public static function hasOpenSession(int $company_id, int $branch_id, int $cash_register_id): bool
    {
        return self::currentSession($company_id, $branch_id, $cash_register_id) != null;
    }

    /**
     * Aperturar caja.
     */
    public static function openSession(int $company_id, int $branch_id, int $cash_register_id, int $user_id, float $opening_amount): CashSession
    {

        if (self::hasOpenSession($company_id, $branch_id, $cash_register_id)) {
            throw new \Exception("La caja ya se encuentra abierta.");
        }

        return CashSession::create([
            'company_id'       => $company_id,
            'branch_id'        => $branch_id,
            'cash_register_id' => $cash_register_id,
            'user_open_id'     => $user_id,
            'opening_amount'   => $opening_amount,
            'expected_amount'  => $opening_amount,
            'status'           => 'OPEN'
        ]);
    }

    /**
     * Registrar movimiento.
     */
    public static function registerMovement(int $company_id, int $cash_session_id, int $user_id, string $type, float $amount, string $description = ''): CashMovement
    {

        $movement = CashMovement::create([
            'company_id'      => $company_id,
            'cash_session_id' => $cash_session_id,
            'user_id'         => $user_id,
            'type'            => $type,
            'amount'          => $amount,
            'description'     => $description
        ]);

        $session = CashSession::find($cash_session_id);
        switch ($type) {
            case 'SALE':
            case 'INCOME':
                $session->expected_amount += $amount;
                break;
            case 'PURCHASE':
            case 'EXPENSE':
                $session->expected_amount -= $amount;
                break;
        }

        $session->save();
        return $movement;
    }

    public static function closeSession(int $cash_session_id, int $user_id, float $closing_amount): CashSession
    {

        $session = CashSession::findOrFail($cash_session_id);
        if ($session->status == 'CLOSED') {
            throw new \Exception("La caja ya fue cerrada.");
        }

        $session->user_close_id = $user_id;
        $session->closing_amount = $closing_amount;
        $session->difference = $closing_amount - $session->expected_amount;
        $session->closed_at = FG::getDateHour();
        $session->status = 'CLOSED';
        $session->save();
        return $session;
    }

    /**
     * Obtiene el saldo esperado.
     */
    public static function expectedBalance(int $cash_session_id): float
    {
        $session = CashSession::findOrFail($cash_session_id);
        return (float) $session->expected_amount;
    }

    /**
     * Obtiene todos los movimientos de una sesión.
     */
    public static function movements(int $cash_session_id)
    {
        return CashMovement::where('cash_session_id', $cash_session_id)->orderBy('created_at', 'desc')->get();
    }

    public static function summary(int $cash_session_id)
    {
        $session = CashSession::findOrFail($cash_session_id);
        $movements = CashMovement::where('cash_session_id', $cash_session_id);

        return [
            'opening_amount' => (float)$session->opening_amount,
            'sales' => (float)(clone $movements)->where('type', 'SALE')->sum('amount'),
            'income' => (float)(clone $movements)->where('type', 'INCOME')->sum('amount'),
            'expense' => (float)(clone $movements)->where('type', 'EXPENSE')->sum('amount'),
            'purchase' => (float)(clone $movements)->where('type', 'PURCHASE')->sum('amount'),
            'expected_amount' => (float)$session->expected_amount
        ];
    }

    public static function cashSummary(int $cash_register_id)
    {
        $sessions = CashSession::where('cash_register_id', $cash_register_id)->pluck('id');
        $movements = CashMovement::whereIn('cash_session_id', $sessions);
        $opening = CashSession::where('cash_register_id', $cash_register_id)->sum('opening_amount');
        $expected = CashSession::where('cash_register_id', $cash_register_id)->sum('expected_amount');
        return [
            'opening_amount' => (float)$opening,
            'sales' => (float)(clone $movements)->where('type', 'SALE')->sum('amount'),
            'income' => (float)(clone $movements)->where('type', 'INCOME')->sum('amount'),
            'expense' => (float)(clone $movements)->where('type', 'EXPENSE')->sum('amount'),
            'purchase' => (float)(clone $movements)->where('type', 'PURCHASE')->sum('amount'),
            'expected_amount' => (float)$expected,
            'sessions' => $sessions->count()
        ];
    }
}
