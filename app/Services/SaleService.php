<?php

namespace App\Services;

use App\Models\Product;
use App\Models\Quotation;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Repositories\SaleRepository;
use App\Utilities\FG;

class SaleService
{

    public static function createFromQuotation(Quotation $quotation, array $input, int $company_id, int $user_id): Sale
    {
        if ($quotation->details->isEmpty()) {
            throw new \Exception('La cotización no contiene productos.');
        }

        $paymentCondition = strtoupper(trim($input['payment_condition'] ?? ''));
        if (!in_array($paymentCondition, ['CASH', 'CREDIT'], true)) {
            throw new \Exception('Seleccione una condición de pago válida.');
        }

        $paymentMethod = strtoupper(trim($input['payment_method'] ?? ''));
        $allowedPaymentMethods = ['CASH', 'CARD', 'TRANSFER', 'YAPE', 'PLIN', 'OTHER'];
        if (!in_array($paymentMethod, $allowedPaymentMethods, true)) {
            throw new \Exception('Seleccione un método de pago válido.');
        }

        $voucherType = strtoupper(trim($input['voucher_type'] ?? ''));
        if (!in_array($voucherType, ['BOLETA', 'FACTURA', 'TICKET', 'NOTA'], true)) {
            throw new \Exception('Seleccione un tipo de comprobante válido.');
        }

        $total = round((float) $quotation->total, 2);
        if ($total <= 0) {
            throw new \Exception('El total de la cotización debe ser mayor a cero.');
        }

        if ($paymentCondition === 'CASH') {
            $amountPaid = $total;
        } else {
            $amountPaid = round((float) ($input['amount_paid'] ?? 0), 2);
        }
        if ($amountPaid < 0) {
            throw new \Exception('El monto pagado no puede ser negativo.');
        }

        if ($amountPaid > $total) {
            throw new \Exception('El monto pagado no puede superar el total de la venta.');
        }

        if ($paymentCondition === 'CREDIT' && empty($input['due_date'])) {
            throw new \Exception('Seleccione la fecha de vencimiento.');
        }

        if ($paymentCondition === 'CREDIT' && !empty($input['due_date']) && strtotime($input['due_date']) < strtotime(date('Y-m-d'))) {
            throw new \Exception('La fecha de vencimiento no puede ser anterior a la fecha actual.');
        }

        $balanceDue = round(max($total - $amountPaid, 0), 2);
        if ($amountPaid <= 0) {
            $paymentStatus = 'PENDING';
        } elseif ($amountPaid < $total) {
            $paymentStatus = 'PARTIAL';
        } else {
            $paymentStatus = 'PAID';
        }

        $sale = new Sale();
        $sale->company_id = $company_id;
        $sale->branch_id = $quotation->branch_id;
        $sale->customer_id = $quotation->customer_id;
        $sale->user_id = $user_id;
        $sale->sale_date = $input['sale_date'] ?? FG::getDateHour();
        $sale->voucher_type = $voucherType;
        $sale->voucher_series = !empty($input['voucher_series']) ? strtoupper(trim($input['voucher_series'])) : null;
        $sale->voucher_number = !empty($input['voucher_number']) ? trim($input['voucher_number']) : null;
        $sale->payment_method = $paymentMethod;
        $sale->payment_condition = $paymentCondition;
        $sale->subtotal = round((float) $quotation->subtotal, 2);
        $sale->tax = round((float) $quotation->tax, 2);
        $sale->discount = round((float) $quotation->discount, 2);
        $sale->total = $total;
        $sale->amount_paid = $amountPaid;
        $sale->balance_due = $balanceDue;
        $sale->payment_status = $paymentStatus;
        $sale->due_date = $paymentCondition === 'CREDIT' ? $input['due_date'] : null;
        $sale->status = 'COMPLETED';
        $sale->save();
        self::createInitialPayment($sale, ['payment_method' => $paymentMethod]);

        foreach ($quotation->details as $quotationDetail) {
            self::createDetailFromQuotation($sale, $quotationDetail, $company_id, $user_id);
        }
        return $sale->load(['customer', 'company', 'details.product']);
    }

    public static function createInitialPayment(Sale $sale, array $input)
    {
        if ($sale->amount_paid <= 0) {
            return;
        }

        $repository = new SaleRepository();
        $repository->createPayment([
            'company_id'     => $sale->company_id,
            'branch_id'      => $sale->branch_id,
            'sale_id'        => $sale->id,
            'user_id'        => $sale->user_id,
            'amount'         => $sale->amount_paid,
            'payment_method' => $input['payment_method'],
            'payment_type'   => $sale->payment_condition == 'CREDIT' ? 'INITIAL' : 'FINAL',
            'payment_date'   => $sale->sale_date,
        ]);
    }

    private static function createDetailFromQuotation(Sale $sale, $quotationDetail, int $company_id, int $user_id): void
    {
        $product = Product::query()
            ->where('company_id', $company_id)
            ->where('id', $quotationDetail->product_id)
            ->whereNull('deleted_at')->first();

        if (!$product) {
            throw new \Exception('No se encontró uno de los productos de la cotización.');
        }

        $quantity = round((float) $quotationDetail->quantity, 3);
        $salePrice = round((float) $quotationDetail->unit_price, 2);
        $discount = round((float) $quotationDetail->discount, 2);
        if ($quantity <= 0) {
            throw new \Exception("La cantidad del producto {$product->name} debe ser mayor a cero.");
        }

        if ($salePrice <= 0) {
            throw new \Exception("El precio del producto {$product->name} debe ser mayor a cero.");
        }

        $grossAmount = round($quantity * $salePrice, 2);
        if ($discount < 0) {
            throw new \Exception("El descuento del producto {$product->name} no puede ser negativo.");
        }

        if ($discount > $grossAmount) {
            throw new \Exception("El descuento del producto {$product->name} supera su importe.");
        }

        $subtotal = round($grossAmount - $discount, 2);
        $unitCost = round((float) $product->purchase_price, 2);
        $totalCost = round($quantity * $unitCost, 2);
        $profit = round($subtotal - $totalCost, 2);

        $detail = new SaleDetail();
        $detail->sale_id = $sale->id;
        $detail->product_id = $product->id;
        $detail->quantity = $quantity;
        $detail->sale_price = $salePrice;
        $detail->unit_cost = $unitCost;
        $detail->total_cost = $totalCost;
        $detail->discount = $discount;
        $detail->subtotal = $subtotal;
        $detail->profit = $profit;
        $detail->save();

        $stockResult = ProductStockService::decrease($company_id, $sale->branch_id, $product->id, $quantity);
        InventoryService::createMovement(
            $company_id,
            $product->id,
            $user_id,
            $sale->branch_id,
            'SALE',
            $quantity,
            $stockResult['before'],
            $stockResult['after'],
            'QUOTATION_SALE',
            $sale->id,
            'Salida por venta generada desde cotización'
        );
    }
}
