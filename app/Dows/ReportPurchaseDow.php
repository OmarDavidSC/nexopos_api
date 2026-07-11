<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Purchase;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class ReportPurchaseDow
{
    public function index($request)
    {
        $response = FG::responseDefault();
        try {

            $filters = $this->buildFilters($request);

            $query = $this->baseQuery($filters);

            $response['success'] = true;
            $response['data'] = [
                'summary'            => $this->summary(clone $query),
                'purchases_by_day'   => $this->purchasesByDay(clone $query),
                'purchases_by_month' => $this->purchasesByMonth(clone $query),
                'top_products'       => $this->topProducts(clone $query),
                'top_suppliers'      => $this->topSuppliers(clone $query),
                'voucher_types'      => $this->voucherTypes(clone $query),
                'purchase_status'    => $this->purchaseStatus(clone $query),
                'purchases'          => $this->purchaseList(clone $query)
            ];

            $response['message'] = 'successfully.';
        } catch (\Exception $e) {

            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function buildFilters($request): array
    {
        $input = $request->getParsedBody();

        return [

            'company_id' => Application::getItem('company_id'),

            'branch_id' => $input['branch_id'] ?? null,
            'supplier_id' => $input['supplier_id'] ?? null,
            'user_id' => $input['user_id'] ?? null,
            'voucher_type' => $input['voucher_type'] ?? null,
            'status' => $input['status'] ?? null,

            'date_start' => $input['date_start'] ?? null,
            'date_end' => $input['date_end'] ?? null,
        ];
    }

    private function baseQuery(array $filters)
    {
        $query = Purchase::query()
            ->where('purchases.company_id', $filters['company_id']);

        if (!empty($filters['branch_id'])) {
            $query->where('purchases.branch_id', $filters['branch_id']);
        }

        if (!empty($filters['supplier_id'])) {
            $query->where('purchases.supplier_id', $filters['supplier_id']);
        }

        if (!empty($filters['user_id'])) {
            $query->where('purchases.user_id', $filters['user_id']);
        }

        if (!empty($filters['voucher_type'])) {
            $query->where('purchases.voucher_type', $filters['voucher_type']);
        }

        if (!empty($filters['status'])) {
            $query->where('purchases.status', $filters['status']);
        }

        if (!empty($filters['date_start'])) {
            $query->whereDate('purchases.purchase_date', '>=', $filters['date_start']);
        }

        if (!empty($filters['date_end'])) {
            $query->whereDate('purchases.purchase_date', '<=', $filters['date_end']);
        }

        return $query;
    }

    private function summary($query)
    {
        return [
            'purchases_count' => (clone $query)->count(),
            'total_amount' => (float) (clone $query)->sum('purchases.total'),
            'subtotal_amount' => (float) (clone $query)->sum('purchases.subtotal'),
            'tax_amount' => (float) (clone $query)->sum('purchases.tax'),
            'discount_amount' => (float) (clone $query)->sum('purchases.discount'),
            'total_products' => (float) (clone $query)->join('purchase_details', 'purchase_id', '=', 'purchase_details.purchase_id')->sum('purchase_details.quantity'),
            'average_ticket' => (float) ((clone $query)->count() > 0 ? (clone $query)->sum('purchases.total') / (clone $query)->count() : 0)
        ];
    }

    private function purchasesByDay($query)
    {
        return (clone $query)
            ->selectRaw(" DATE(purchase_date) AS date,COUNT(id) AS total_purchases,SUM(total) AS total_amount")
            ->groupBy(
                DB::raw("DATE(purchase_date)")
            )
            ->orderBy('date')->get();
    }

    private function purchasesByMonth($query)
    {
        return (clone $query)
            ->selectRaw(" YEAR(purchase_date) AS year,MONTH(purchase_date) AS month,COUNT(id) AS total_purchases,SUM(total) AS total_amount")
            ->groupBy(DB::raw("YEAR(purchase_date)"), DB::raw("MONTH(purchase_date)"))
            ->orderBy('year')
            ->orderBy('month')->get();
    }

    private function topProducts($query)
    {
        return (clone $query)
            ->join('purchase_details', 'purchases.id', '=', 'purchase_details.purchase_id')
            ->join('products', 'purchase_details.product_id', '=', 'products.id')
            ->select('products.id', 'products.code', 'products.name')
            ->selectRaw('SUM(purchase_details.quantity) AS total_quantity')
            ->selectRaw('SUM(purchase_details.subtotal) AS total_amount')
            ->selectRaw('COUNT(DISTINCT purchases.id) AS total_orders')
            ->groupBy('products.id', 'products.code', 'products.name')
            ->orderByDesc('total_quantity')
            ->limit(10)->get();
    }

    private function topSuppliers($query)
    {
        return (clone $query)
            ->join('suppliers', 'purchases.supplier_id', '=', 'suppliers.id')
            ->select('suppliers.id', 'suppliers.business_name')
            ->selectRaw('COUNT(purchases.id) AS total_purchases')
            ->selectRaw('SUM(purchases.total) AS total_amount')
            ->selectRaw('AVG(purchases.total) AS average_ticket')
            ->selectRaw('MAX(purchases.purchase_date) AS last_purchase')
            ->groupBy('suppliers.id', 'suppliers.business_name')
            ->orderByDesc('total_amount')
            ->limit(10)
            ->get();
    }

    private function voucherTypes($query)
    {
        return (clone $query)
            ->select('purchases.voucher_type')
            ->selectRaw('COUNT(purchases.id) AS total_purchases')
            ->selectRaw('SUM(purchases.total) AS total_amount')
            ->selectRaw('AVG(purchases.total) AS average_ticket')
            ->groupBy('purchases.voucher_type')
            ->orderByDesc('total_amount')
            ->get();
    }

    private function purchaseStatus($query)
    {
        return (clone $query)
            ->select('purchases.status')
            ->selectRaw('COUNT(purchases.id) AS total_purchases')
            ->selectRaw('SUM(purchases.total) AS total_amount')
            ->groupBy('purchases.status')
            ->orderByDesc('total_purchases')
            ->get();
    }

    private function purchaseList($query)
    {
        return (clone $query)
            ->leftJoin('suppliers', 'purchases.supplier_id', '=', 'suppliers.id')
            ->join('users', 'purchases.user_id', '=', 'users.id')
            ->join('branches', 'purchases.branch_id', '=', 'branches.id')
            ->select(
                'purchases.id',
                'purchases.purchase_date',
                'purchases.voucher_type',
                'purchases.status',

                'purchases.subtotal',
                'purchases.tax',
                'purchases.discount',
                'purchases.total',

                'suppliers.business_name AS supplier_name',
                'users.name AS user_name',
                'branches.name AS branch_name'
            )
            ->orderByDesc('purchases.purchase_date')->get();
    }
}
