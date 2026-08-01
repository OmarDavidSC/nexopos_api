<?php

namespace App\Repositories;

use App\Models\Quotation;
use App\Services\BranchService;
use App\Utilities\FG;
use Illuminate\Database\Capsule\Manager as DB;

class QuotationRepository
{
    public function getPaginatedList(int $company_id, array $filters)
    {
        $page = $filters['page'];
        $perPage = $filters['per_page'];

        $query = Quotation::query()
            ->with(['customer:id,name,phone', 'branch:id,name', 'creator:id,name'])
            ->withCount('details')
            ->where('company_id', $company_id)->whereNull('deleted_at');

        BranchService::applyBranchScope($query);

        //buscador
        if (!empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('quotation_series', 'LIKE', "%{$search}%")
                    ->orWhere('quotation_number', 'LIKE', "%{$search}%")
                    ->orWhereHas('customer', function ($customer) use ($search) {
                        $customer->where('name', 'LIKE', "%{$search}%");
                    });
            });
        }

        //clientes
        if (!empty($filters['customer_id'])) {
            $query->where('customer_id', $filters['customer_id']);
        }
        //sucursal
        if (!empty($filters['branch_id'])) {
            $query->where('branch_id', $filters['branch_id']);
        }
        //estado
        if (!empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }
        //fecha emision
        if (!empty($filters['issue_date_start'])) {
            $query->whereDate('issue_date', '>=', $filters['issue_date_start']);
        }
        if (!empty($filters['issue_date_end'])) {
            $query->whereDate('issue_date', '<=', $filters['issue_date_end']);
        }
        //fecha vencimiento
        if (!empty($filters['expiration_date_start'])) {
            $query->whereDate('expiration_date', '>=', $filters['expiration_date_start']);
        }
        if (!empty($filters['expiration_date_end'])) {
            $query->whereDate('expiration_date', '<=', $filters['expiration_date_end']);
        }

        $query->orderByDesc('id');
        $total = $query->count();
        $quotations = $query->skip(($page - 1) * $perPage)->take($perPage)->get();
        $data = $quotations->map(function ($item) {
            return [
                'id' => $item->id,
                'customer_id' => $item->customer_id,
                'customer_name' => $item->customer?->name,
                'customer_phone' => $item->customer?->phone,
                'branch_name' => $item->branch?->name,
                'created_by' => $item->creator?->name,
                'quotation' => trim($item->quotation_series . '-' . $item->quotation_number),
                'quotation_series' => $item->quotation_series,
                'quotation_number' => $item->quotation_number,
                'issue_date' => FG::formatDateTimeHuman($item->issue_date),
                'expiration_date' => $item->expiration_date ? FG::formatDateTimeHuman($item->expiration_date) : null,
                'subtotal' => (float) $item->subtotal,
                'tax' => (float) $item->tax,
                'discount' => (float) $item->discount,
                'total' => (float) $item->total,
                'items_count' => $item->details_count,
                'status' => $item->status,
                'status_label' => FG::getStatusLabel($item->status),
                'sale_id' => $item->sale_id,
                'converted' => !empty($item->sale_id),
            ];
        });
        return ['total' => $total, 'summary' => $this->getSummary($company_id), 'data' => $data];
    }

    private function getSummary(int $company_id): array
    {
        $query = Quotation::query()->where('company_id', $company_id)->whereNull('deleted_at');
        BranchService::applyBranchScope($query);
        $summary = $query->selectRaw('COUNT(*) as total')
            ->selectRaw("SUM(CASE WHEN status = 'DRAFT' THEN 1 ELSE 0 END) as draft")
            ->selectRaw("SUM(CASE WHEN status = 'SENT' THEN 1 ELSE 0 END) as sent")
            ->selectRaw("SUM(CASE WHEN status = 'ACCEPTED' THEN 1 ELSE 0 END) as accepted")
            ->selectRaw("SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) as rejected")
            ->selectRaw("SUM(CASE WHEN status = 'EXPIRED' THEN 1 ELSE 0 END) as expired")
            ->selectRaw("SUM(CASE WHEN status = 'CONVERTED' THEN 1 ELSE 0 END) as converted")
            ->selectRaw("SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled")
            ->selectRaw("COALESCE(SUM(CASE WHEN status != 'CANCELLED' THEN total ELSE 0 END), 0) as total_amount")
            ->first();

        return [
            'total' => (int) ($summary->total ?? 0),
            'draft' => (int) ($summary->draft ?? 0),
            'sent' => (int) ($summary->sent ?? 0),
            'accepted' => (int) ($summary->accepted ?? 0),
            'rejected' => (int) ($summary->rejected ?? 0),
            'expired' => (int) ($summary->expired ?? 0),
            'converted' => (int) ($summary->converted ?? 0),
            'cancelled' => (int) ($summary->cancelled ?? 0),
            'total_amount' => round((float) ($summary->total_amount ?? 0), 2)
        ];
    }

    public function getNextQuotationNumber(int $company_id, string $series): string
    {
        $lastQuotation = Quotation::query()
            ->where('company_id', $company_id)
            ->where('quotation_series', $series)
            ->orderByDesc('id')
            ->first();

        if (!$lastQuotation) {
            return '00000001';
        }

        $lastNumber = (int) $lastQuotation->quotation_number;
        $nextNumber = $lastNumber + 1;
        return str_pad((string) $nextNumber, 8, '0', STR_PAD_LEFT);
    }

    public function createQuotation(array $data): Quotation
    {
        return Quotation::create([
            'company_id' => $data['company_id'],
            'branch_id' => $data['branch_id'],
            'customer_id' => $data['customer_id'],
            'sale_id' => null,
            'created_by' => $data['created_by'],
            'quotation_series' => $data['quotation_series'],
            'quotation_number' => $data['quotation_number'],
            'issue_date' => $data['issue_date'],
            'expiration_date' => $data['expiration_date'] ?? null,
            'subtotal' => $data['subtotal'],
            'tax' => $data['tax'],
            'discount' => $data['discount'],
            'total' => $data['total'],
            'status' => $data['status'] ?? 'DRAFT',
            'observations' => $data['observations'] ?? null,
            'terms' => $data['terms'] ?? null
        ]);
    }

    public function getQuotationById(int $quotation_id, int $company_id): ?Quotation
    {
        $query = Quotation::query()
            ->with([
                'customer',
                'branch:id,name,code,address',
                'creator:id,name,paternal_surname,maternal_surname',
                'sale:id,voucher_type,voucher_series,voucher_number,total,status',
                'details' => function ($query) {
                    $query->whereNull('deleted_at')->orderBy('id', 'ASC');
                },
                'details.product:id,code,name'
            ])
            ->where('id', $quotation_id)
            ->where('company_id', $company_id)
            ->whereNull('deleted_at');
        BranchService::applyBranchScope($query);
        return $query->first();
    }

    public function findByIdForUpdate(int $quotation_id, $company_id): ?Quotation
    {
        $query = Quotation::query()
            ->where('id', $quotation_id)
            ->where('company_id', $company_id)
            ->whereNull('deleted_at')
            ->lockForUpdate();
        BranchService::applyBranchScope($query);
        return $query->first();
    }

    public function findForConversion(int $quotation_id, int $company_id): ?Quotation
    {
        $query = Quotation::query()
            ->with([
                'customer',
                'details' => function ($query) {
                    $query->whereNull('deleted_at')->orderBy('id', 'ASC');
                },
                'details.product'
            ])
            ->where('id', $quotation_id)
            ->where('company_id', $company_id)
            ->whereNull('deleted_at')
            ->lockForUpdate();
        BranchService::applyBranchScope($query);
        return $query->first();
    }

    public function markAsConverted(Quotation $quotation, int $sale_id, string $converted_at): Quotation
    {
        $quotation->sale_id = $sale_id;
        $quotation->status = 'CONVERTED';
        $quotation->converted_at = $converted_at;
        $quotation->save();
        return $quotation->fresh(['customer:id,name', 'branch:id,name', 'creator:id,name', 'sale']);
    }

    public function updateStatus(Quotation $quotation, string $status, array $additionalData = []): Quotation
    {
        $quotation->status = $status;
        foreach ($additionalData as $field => $value) {
            $quotation->{$field} = $value;
        }
        $quotation->save();
        return $quotation->fresh(['customer:id,name', 'branch:id,name', 'creator:id,name,paternal_surname,maternal_surname']);
    }
}
