<?php

namespace App\Services;

use App\Models\Quotation;
use App\Repositories\QuotationDetailRepository;
use App\Repositories\QuotationRepository;
use App\Utilities\FG;

class QuotationService
{
    public static function getPaginateList(int $company_id, array $filters): array
    {
        $repository = new QuotationRepository();

        $page = max((int) ($filters['page'] ?? 1), 1);
        $perPage = max((int) ($filters['per_page'] ?? 10), 1);
        if ($perPage > 100) {
            $perPage = 100;
        }

        $status = strtoupper(trim($filters['status'] ?? ''));
        $validStatuses = ['', 'DRAFT', 'SENT', 'ACCEPTED', 'REJECTED', 'EXPIRED', 'CONVERTED', 'CANCELLED'];
        if (!in_array($status, $validStatuses, true)) {
            throw new \Exception('El estado de la cotización no es válido');
        }

        $filters['page'] = $page;
        $filters['per_page'] = $perPage;
        $filters['status'] = $status;
        $filters['search'] = trim($filters['search'] ?? '');

        $result = $repository->getPaginatedList($company_id, $filters);
        return [
            'page' => $page,
            'per_page' => $perPage,
            'total' => $result['total'],
            'total_pages' => (int) ceil($result['total'] / $perPage),
            'summary' => $result['summary'],
            'data' => $result['data']
        ];
    }

    public static function store(array $input, int $company_id, int $branch_id, int $user_id): Quotation
    {
        self::validateStore($input);
        $details = self::decodeDetails($input['details']);
        $calculatedDetails = self::calculateDetails($details);

        $quotationRepository = new QuotationRepository();
        $quotationDetailRepository = new QuotationDetailRepository();

        $series = !empty($input['quotation_series']) ? strtoupper(trim($input['quotation_series'])) : 'COT';
        $quotationNumber = $quotationRepository->getNextQuotationNumber($company_id, $series);

        $quotation = $quotationRepository->createQuotation([
            'company_id' => $company_id,
            'branch_id' => $branch_id,
            'customer_id' => (int) $input['customer_id'],
            'created_by' => $user_id,
            'quotation_series' => $series,
            'quotation_number' => $quotationNumber,
            'issue_date' => $input['issue_date'],
            'expiration_date' => $input['expiration_date'] ?? null,
            'subtotal' => $calculatedDetails['subtotal'],
            'tax' => $calculatedDetails['tax'],
            'discount' => $calculatedDetails['discount'],
            'total' => $calculatedDetails['total'],
            'status' => $input['status'] ?? 'DRAFT',
            'observations' => !empty($input['observations']) ? trim($input['observations']) : null,
            'terms' => !empty($input['terms']) ? trim($input['terms']) : null
        ]);

        $quotationDetailRepository->createDetails($quotation->id, $calculatedDetails['details']);
        return $quotation->load(['customer', 'branch', 'creator', 'details.product']);
    }

    public static function show(int $quotation_id, int $company_id): array
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }

        $respository = new QuotationRepository();
        $quotation = $respository->getQuotationById($quotation_id, $company_id);

        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }

        return [
            'quotation' => [
                'id' => $quotation->id,
                'company_id' => $quotation->company_id,
                'branch_id' => $quotation->branch_id,
                'branch' => $quotation->branch?->name,
                'customer_id' => $quotation->customer_id,
                'customer' => $quotation->customer?->name,
                'customer_document' => $quotation->customer?->document_number,
                'customer_phone' => $quotation->customer?->phone,
                'customer_email' => $quotation->customer?->email,
                'customer_address' => $quotation->customer?->address,
                'created_by' => $quotation->created_by,
                'created_by_name' => self::getCreatorName($quotation->creator),
                'quotation_series' => $quotation->quotation_series,
                'quotation_number' => $quotation->quotation_number,
                'quotation' => trim($quotation->quotation_series . '-' . $quotation->quotation_number),
                'issue_date' => FG::formatDateTimeHuman($quotation->issue_date),
                'issue_date_raw' => $quotation->issue_date,
                'expiration_date' => $quotation->expiration_date ? FG::formatDateTimeHuman($quotation->expiration_date) : null,
                'expiration_date_raw' => $quotation->expiration_date,
                'subtotal' => (float) $quotation->subtotal,
                'tax' => (float) $quotation->tax,
                'discount' => (float) $quotation->discount,
                'total' => (float) $quotation->total,
                'status' => $quotation->status,
                // 'status_label' =>FG::getStatusLabel($quotation->status),
                'observations' => $quotation->observations,
                'terms' => $quotation->terms,
                'sale_id' => $quotation->sale_id,
                'converted_at' => $quotation->converted_at ? FG::formatDateTimeHuman($quotation->converted_at) : null,
                'accepted_at' => $quotation->accepted_at ? FG::formatDateTimeHuman($quotation->accepted_at) : null,
                'rejected_at' => $quotation->rejected_at ? FG::formatDateTimeHuman($quotation->rejected_at) : null,
                'cancelled_at' => $quotation->cancelled_at ? FG::formatDateTimeHuman($quotation->cancelled_at) : null,
                'sale' => $quotation->sale ? [
                    'id' => $quotation->sale->id,
                    'voucher' => trim($quotation->sale->voucher_type . ' ' . $quotation->sale->voucher_series . '-' . $quotation->sale->voucher_number),
                    'total' => (float) $quotation->sale->total,
                    'status' => $quotation->sale->status
                ] : null
            ],
            'details' => $quotation->details->map(
                function ($item) {
                    return [
                        'id' => $item->id,
                        'quotation_id' => $item->quotation_id,
                        'product_id' => $item->product_id,
                        'product_code' => $item->product?->code,
                        'product_name' => $item->product?->name,
                        'quantity' => (float) $item->quantity,
                        'unit_price' => (float) $item->unit_price,
                        'discount_percentage' => (float) $item->discount_percentage,
                        'discount' => (float) $item->discount,
                        'subtotal' => (float) $item->subtotal,
                        'tax' => (float) $item->tax,
                        'total' => (float) $item->total,
                        'description' => $item->description
                    ];
                }
            )->values()
        ];
    }

    public static function cancel(int $quotation_id, int $company_id): Quotation
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }

        $repository = new QuotationRepository();
        $quotation  =  $repository->findByIdForUpdate($quotation_id, $company_id);

        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }
        if ($quotation->status === 'CANCELLED') {
            throw new \Exception('La cotización ya se encuentra cancelada.');
        }
        if ($quotation->status === 'CONVERTED'  || !empty($quotation->sale_id)) {
            throw new \Exception('No se puede cancelar una cotización que ya fue convertida en venta.');
        }

        return $repository->updateStatus($quotation, 'CANCELLED', ['cancelled_at' => FG::getDateHour()]);
    }

    public static function accept(int $quotation_id, int $company_id): Quotation
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }

        $repository = new QuotationRepository();
        $quotation = $repository->findByIdForUpdate($quotation_id, $company_id);
        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }
        if ($quotation->status === 'ACCEPTED') {
            throw new \Exception('La cotización ya se encuentra aceptada.');
        }
        if ($quotation->status === 'CONVERTED') {
            throw new \Exception('La cotización ya fue convertida en venta.');
        }
        if ($quotation->status === 'CANCELLED') {
            throw new \Exception('No se puede aceptar una cotización cancelada.');
        }
        if ($quotation->status === 'REJECTED') {
            throw new \Exception('No se puede aceptar una cotización rechazada.');
        }
        if ($quotation->status === 'EXPIRED') {
            throw new \Exception('No se puede aceptar una cotización vencida.');
        }
        if (!empty($quotation->expiration_date) && strtotime($quotation->expiration_date) < strtotime(date('Y-m-d'))) {
            $repository->updateStatus($quotation, 'EXPIRED');
            throw new \Exception('La cotización se encuentra vencida.');
        }
        return $repository->updateStatus(
            $quotation,
            'ACCEPTED',
            ['accepted_at' => FG::getDateHour(),   'rejected_at' => null, 'cancelled_at' => null]
        );
    }

    public static function reject(int $quotation_id, int $company_id): Quotation
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }
        $repository = new QuotationRepository();
        $quotation = $repository->findByIdForUpdate($quotation_id, $company_id);
        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }
        if ($quotation->status === 'REJECTED') {
            throw new \Exception('La cotización ya se encuentra rechazada.');
        }
        if ($quotation->status === 'CONVERTED') {
            throw new \Exception('No se puede rechazar una cotización convertida en venta.');
        }
        if ($quotation->status === 'CANCELLED') {
            throw new \Exception('No se puede rechazar una cotización cancelada.');
        }
        if ($quotation->status === 'EXPIRED') {
            throw new \Exception('No se puede rechazar una cotización vencida.');
        }

        return $repository->updateStatus(
            $quotation,
            'REJECTED',
            ['rejected_at' => FG::getDateHour(), 'accepted_at' => null, 'cancelled_at' => null]
        );
    }

    public static function markAsSent(int $quotation_id, int $company_id): Quotation
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }
        $repository = new QuotationRepository();
        $quotation = $repository->findByIdForUpdate($quotation_id, $company_id);
        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }
        if ($quotation->status === 'SENT') {
            throw new \Exception('La cotización ya se encuentra marcada como enviada.');
        }
        if ($quotation->status !== 'DRAFT') {
            throw new \Exception('Solo se pueden enviar cotizaciones en estado borrador.');
        }
        if (!empty($quotation->expiration_date) && strtotime((string) $quotation->expiration_date) < strtotime(date('Y-m-d'))) {
            $repository->updateStatus($quotation, 'EXPIRED');
            throw new \Exception('No se puede enviar la cotización porque ya se encuentra vencida.');
        }
        return $repository->updateStatus($quotation, 'SENT');
    }

    public static function convertToSale(int $quotation_id, array $input, int $company_id, int $user_id): array
    {
        if ($quotation_id <= 0) {
            throw new \Exception('El identificador de la cotización no es válido.');
        }
        $quotationRepository = new QuotationRepository();
        $quotation = $quotationRepository->findForConversion($quotation_id, $company_id);
        if (!$quotation) {
            throw new \Exception('La cotización no fue encontrada.');
        }

        if ($quotation->status === 'CONVERTED' || !empty($quotation->sale_id)) {
            throw new \Exception('La cotizaciób ya fue convertida en venta.');
        }
        if ($quotation->status === 'CANCELLED') {
            throw new \Exception('No se puede convertir una cotización cancelada.');
        }
        if ($quotation->status === 'REJECTED') {
            throw new \Exception('No se puede convertir una cotización rechazada.');
        }
        if ($quotation->status === 'EXPIRED') {
            throw new \Exception('No se puede convertir una cotización vencida.');
        }

        if (!empty($quotation->expiration_date) && strtotime((string) $quotation->expiration_date) < strtotime(date('Y-m-d'))) {
            $quotationRepository->updateStatus($quotation, 'EXPIRED');
            throw new \Exception('La cotización se encuentra vencida.');
        }

        $allowedStatuses = ['DRAFT', 'SENT', 'ACCEPTED'];
        if (!in_array($quotation->status, $allowedStatuses, true)) {
            throw new \Exception('El estado actual de la cotización no permite convertirla en venta.');
        }

        if (empty($quotation->customer_id)) {
            throw new \Exception('La cotización no tiene un cliente asociado.');
        }
        if ($quotation->details->isEmpty()) {
            throw new \Exception('La cotización no contiene productos.');
        }

        //crear venta
        $sale = SaleService::createFromQuotation($quotation, $input, $company_id, $user_id);
        //marcar cotización como convertirda
        $updatedQuotation =  $quotationRepository->markAsConverted($quotation, $sale->id, FG::getDateHour());
        return ['quotation' => $updatedQuotation, 'sale' => $sale];
    }

    private static function validateStore(array $input): void
    {
        if (empty($input['customer_id'])) {
            throw new \Exception('Seleccione el cliente');
        }
        if (empty($input['issue_date'])) {
            throw new \Exception('Ingrese la fecha de emisión.');
        }
        if (empty($input['details'])) {
            throw new \Exception('Debe agregar al menos un producto.');
        }
        if (!empty($input['expiration_date']) && $input['expiration_date'] < $input['issue_date']) {
            throw new \Exception('La fecha de vencimiento no puede ser menor que la fecha de emisión.');
        }
        $status = strtoupper(trim($input['status'] ?? 'DRAFT'));
        $validStatuses = ['DRAFT', 'SENT'];
        if (!in_array($status, $validStatuses, true)) {
            throw new \Exception('El estado inicial de la cotización no es válido.');
        }
    }

    private static function decodeDetails($details): array
    {
        if (is_array($details)) {
            $decodedDetails = $details;
        } else {
            $decodedDetails = json_decode($details, true);
        }
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new \Exception('El detalle de la cotización no contiene un JSON válido.');
        }
        if (empty($decodedDetails)) {
            throw new \Exception('Debe agregar al menos un producto.');
        }
        return $decodedDetails;
    }

    private static function calculateDetails(array $details): array
    {
        $calculatedDetails = [];
        $subtotalGeneral = 0;
        $taxGeneral = 0;
        $discountGeneral = 0;
        $totalGeneral = 0;

        foreach ($details as $index => $detail) {
            $productId = isset($detail['product_id']) ? (int) $detail['product_id'] : 0;
            $quantity = isset($detail['quantity']) ? round((float) $detail['quantity'], 3) : 0;
            $unitPrice = isset($detail['unit_price']) ? round((float) $detail['unit_price'], 2) : 0;
            $discountPercentage = isset($detail['discount_percentage']) ? round((float) $detail['discount_percentage'], 2) : 0;
            if ($productId <= 0) {
                throw new \Exception('El producto de la fila ' . ($index + 1) . ' no es válido.');
            }
            if ($quantity <= 0) {
                throw new \Exception('La cantidad del producto de la fila ' . ($index + 1) . ' debe ser mayor a cero.');
            }
            if ($unitPrice < 0) {
                throw new \Exception('El precio del producto de la fila ' . ($index + 1) . ' no puede ser negativo.');
            }
            if ($discountPercentage < 0 || $discountPercentage > 100) {
                throw new \Exception('El descuento del producto de la fila ' . ($index + 1) . ' debe estar entre 0 y 100.');
            }

            $grossSubtotal = round($quantity * $unitPrice, 2);
            $discount = round($grossSubtotal * ($discountPercentage / 100), 2);
            $subtotal = round($grossSubtotal - $discount, 2);
            $tax = 0;
            $total = round($subtotal + $tax, 2);
            $calculatedDetails[] = [
                'product_id' => $productId,
                'quantity' => $quantity,
                'unit_price' => $unitPrice,
                'discount_percentage' =>
                $discountPercentage,
                'discount' => $discount,
                'subtotal' => $subtotal,
                'tax' => $tax,
                'total' => $total,
                'description' => !empty($detail['description']) ? trim($detail['description']) : null
            ];

            $subtotalGeneral += $grossSubtotal;
            $discountGeneral += $discount;
            $taxGeneral += $tax;
            $totalGeneral += $total;
        }
        return [
            'subtotal' => round($subtotalGeneral, 2),
            'discount' => round($discountGeneral, 2),
            'tax' => round($taxGeneral, 2),
            'total' => round($totalGeneral, 2),
            'details' => $calculatedDetails
        ];
    }

    private static function getCreatorName($creator): ?string
    {
        if (!$creator) {
            return null;
        }
        return trim(implode(' ', array_filter([$creator->name, $creator->paternal_surname, $creator->maternal_surname])));
    }
}