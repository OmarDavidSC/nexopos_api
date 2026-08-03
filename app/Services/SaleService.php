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

    public static function emitTosunat(Sale $sale): Sale
    {
        $voucherType = strtoupper(trim((string) $sale->voucher_type));

        if (!in_array($voucherType, ['BOLETA', 'FACTURA'], true)) {
            throw new \Exception('La venta debe generar una BOLETA o FACTURA para enviarse a SUNAT.');
        }

        $payload = self::buildSunatPayload($sale);
        $sunatService = new SunatApiService();
        $sunatResult = $sunatService->emit($payload);
        $sunatResponse = $sunatResult['response'] ?? [];

        if (!($sunatResponse['success'] ?? false)) {
            throw new \Exception($sunatResponse['message'] ?? 'No se pudo emitir el comprobante electrónico.');
        }
        $sunatData = $sunatResponse['data'] ?? [];
        if (empty($sunatData['documentId'])) {
            throw new \Exception('El servicio de SUNAT no devolvió el identificador del documento.');
        }

        $pdf = $sunatData['pdf'] ?? [];
        $sale->sunat_document_id = $sunatData['documentId'];
        $sale->sunat_status = strtoupper(trim((string) ($sunatData['status'] ?? 'PENDIENTE')));
        $sale->voucher_series = $sunatData['serie'] ?? $sale->voucher_series;
        $sale->voucher_number = $sunatData['number'] ?? $sale->voucher_number;
        $sale->pdf_58mm = $pdf['58mm'] ?? $sale->pdf_58mm;
        $sale->pdf_80mm = $pdf['80mm'] ?? $sale->pdf_80mm;
        $sale->pdf_a5 = $pdf['A5'] ?? $sale->pdf_a5;
        $sale->pdf_a4 = $pdf['A4'] ?? $sale->pdf_a4;
        $sale->save();
        return $sale->fresh();
    }

    public static function buildSunatPayload(Sale $sale): array
    {
        $sale->loadMissing(['company', 'customer', 'details.product']);
        $company = $sale->company;
        $customer = $sale->customer;

        if (!$company) {
            throw new \Exception('No se encontró la empresa asociada a la venta.');
        }
        if (!$customer) {
            throw new \Exception('No se encontró el cliente asociado a la venta.');
        }
        if ($sale->details->isEmpty()) {
            throw new \Exception('La venta no contiene productos para emitir a SUNAT.');
        }

        $voucherType = strtoupper(trim((string) $sale->voucher_type));
        $tipoDocumento = match ($voucherType) {
            'BOLETA' => '03',
            'FACTURA' => '01',
            default => null,
        };

        if (!$tipoDocumento) {
            throw new \Exception('El tipo de comprobante seleccionado no se envía a SUNAT.');
        }

        $customerDocumentType = strtoupper(trim((string) $customer->document_type));
        $tipoDocumentoCliente = match ($customerDocumentType) {
            'DNI' => '1',
            'RUC' => '6',
            'CE' => '4',
            'PASSPORT', 'PASAPORTE' => '7',
            default => '0'
        };

        if ($tipoDocumento === '01' && $tipoDocumentoCliente !== '6') {
            throw new \Exception('Para emitir una factura, el cliente debe tener RUC.');
        }
        if (empty($customer->document_number)) {
            throw new \Exception('El cliente no tiene un número de documento registrado.');
        }

        $items = [];
        foreach ($sale->details as $detail) {
            if (!$detail->product) {
                throw new \Exception("No se encontró el producto del detalle {$detail->id}.");
            }
            $items[] = ['descripcion' => $detail->product->name, 'cantidad' => (float) $detail->quantity, 'precio' => (float) $detail->sale_price];
        }

        return [
            'empresa' => [
                'ruc' => $company->ruc,
                'persona_id' => $company->sunat_persona_id,
                'persona_token' => $company->sunat_persona_token,
                'razon_social' => $company->business_name,
                'nombre_comercial' => $company->name,
                'direccion' => $company->fiscal_address
            ],
            'cliente' => ['tipo_documento' => $tipoDocumentoCliente, 'numero_documento' => $customer->document_number, 'nombre' => $customer->name, 'direccion' => $customer->address ?? '-'],
            'comprobante' => ['tipo_documento' => $tipoDocumento, 'serie' => $sale->voucher_series, 'moneda' => $company->currency_code ?? 'PEN'],
            'items' => $items
        ];
    }
}
