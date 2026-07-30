<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Sale;
use App\Models\SalePayment;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class SalePaymentDow
{
    public function payments($request)
    {
        $response = FG::responseDefault();
        try {

            $sale_id = $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            $sale = Sale::query()
                ->where('id', $sale_id)
                ->where('company_id', $company_id)
                ->first();


            if (!$sale) {
                $response['success'] = false;
                $response['message'] = "La venta no existe";
                return $response;
            }

            if ($sale->payment_condition !== 'CREDIT') {
                $response['success'] = false;
                $response['message'] = "La venta no corresponde a una venta a crédito";
                return $response;
            }

            $payments = SalePayment::query()
                ->with(['user', 'branch', 'cashSession'])
                ->where('company_id', $company_id)
                ->where('sale_id', $sale_id)
                ->where('status', 'ACTIVE')
                ->orderByDesc('payment_date')
                ->orderByDesc('id')
                ->get();

            $totalVenta = round((float) $sale->total, 2);
            $totalPagado = round((float) $payments->sum('amount'), 2);
            $saldoPendiente = round(max($totalVenta - $totalPagado, 0), 2);

            $paymentStatus = 'PENDING';
            if ($saldoPendiente <= 0) {
                $paymentStatus = 'PAID';
            } else if ($totalPagado > 0) {
                $paymentStatus = 'PARTIAL';
            }

            $rsp = [
                'sale' => [
                    'id' => $sale->id,
                    'total' => $totalVenta,
                    'amount_paid' => $totalPagado,
                    'balance_due' => $saldoPendiente,
                    'payment_status' => $paymentStatus,
                    'payment_condition' => $sale->payment_condition,
                    'due_date' => $sale->due_date,
                    'voucher_type' => $sale->voucher_type,
                    'voucher_series' => $sale->voucher_series,
                    'voucher_number' => $sale->voucher_number
                ],

                'summary' => [
                    'total_sale' => $totalVenta,
                    'total_paid' => $totalPagado,
                    'balance_due' => $saldoPendiente,
                    'payment_count' => $payments->count(),
                    'payment_status' => $paymentStatus
                ],

                'payments' => $payments
            ];

            $response['success'] = true;
            $response['data'] =  $rsp;
            $response['message'] = 'Historial de pagos obtenidos correctamente.';
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function store($request)
    {
        $response = FG::responseDefault();
        // DB::beginTransaction();
        try {

            $input = $request->getParsedBody();
            $sale_id = $request->getAttribute('id');

            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');
            $user_id = Application::getItem('user_id');

            $amount = isset($input['amount']) ? round((float) $input['amount'], 2) : 0;
            if ($amount <= 0) {
                $response['success'] = false;
                $response['message'] = "El monto del pago debe ser mayor a cero.";
                return $response;
            }

            $sale = Sale::query()
                ->where('id', $sale_id)
                ->where('company_id', $company_id)
                ->first();

            if (!$sale) {
                $response['success'] = false;
                $response['message'] = "La venta no existe.";
                return $response;
            }

            if ($sale->payment_condition !== 'CREDIT') {
                $response['success'] = false;
                $response['message'] = "Solamente se pueden registrar pagos en ventas a crédito.";
                return $response;
            }

            if ($sale->status === 'CANCELLED') {
                $response['success'] = false;
                $response['message'] = "No se puede registrar pagos en una venta anulada";
                return $response;
            }

            $totalPagado = SalePayment::query()
                ->where('company_id', $company_id)
                ->where('sale_id', $sale_id)
                ->where('status', 'ACTIVE')
                ->sum('amount');

            $totalVenta = round((float) $sale->total, 2);
            $totalPagado = round((float)$totalPagado, 2);
            $saldoPendiente =  round($totalVenta - $totalPagado, 2);
            if ($saldoPendiente <= 0) {
                $response['success'] = false;
                $response['message'] = "La venta ya se encuentra pagada completamente";
            }

            if ($amount > $saldoPendiente) {
                $response['success'] = false;
                $response['message'] = "El monto ingresado supera el saldo pendiente de la venta";
                return $response;
            }

            $nuevoTotalPagado  = round($totalPagado + $amount, 2);
            $nuevoSaldoPendiente = round(max($totalVenta - $nuevoTotalPagado, 0), 2);
            $pagoCompleto = $nuevoSaldoPendiente <= 0;
            $paymentType = $pagoCompleto ? 'FINAL' : 'INSTALLMENT';
            $paymentStatus = $pagoCompleto ? 'PAID' : 'PARTIAL';

            DB::beginTransaction();
            $payment = SalePayment::create([
                'company_id' => $company_id,
                'branch_id' => $branch_id,
                'sale_id' => $sale_id,
                'user_id' => $user_id,
                'cash_session_id' => $input['cash_session_id'] ?? null,
                'amount' => $amount,
                'payment_method' => $input['payment_method'] ?? 'CASH',
                'reference' => $input['reference'] ?? null,
                'payment_date' => $input['payment_date'] ?? FG::getDateHour(),
                'payment_type' => $paymentType,
                'status' => 'ACTIVE',
                'observation' => $input['observation'] ?? null
            ]);
            $sale->amount_paid = $nuevoTotalPagado;
            $sale->balance_due = $nuevoSaldoPendiente;
            $sale->payment_status = $paymentStatus;
            $sale->save();
            DB::commit();

            $payment->load([
                'user',
                'branch',
                'cashSession'
            ]);

            $response['success'] = true;
            $response['data'] =  $payment;
            $response['message'] = $paymentType === 'FINAL' ? 'La venta fue pagada completamente' : 'El pago fue registrado correctamente';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
