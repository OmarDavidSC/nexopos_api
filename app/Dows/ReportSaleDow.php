<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Sale;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class ReportSaleDow
{
    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $filters = $this->buildFilters($request);

            $query = $this->baseQuery($filters);

            $response['success'] = true;
            $response['data'] = [
                'summary'          => $this->summary(clone $query),
                'sales_by_day'     => $this->salesByDay(clone $query),
                'sales_by_month'   => $this->salesByMonth(clone $query),
                'top_products'     => $this->topProducts(clone $query),
                'top_customers'    => $this->topCustomers(clone $query),
                'payment_methods'  => $this->paymentMethods(clone $query),
                'voucher_types'    => $this->voucherTypes(clone $query),
                // 'sales'            => $this->salesList(clone $query)
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
            'company_id'      => Application::getItem('company_id'),

            'branch_id'       => $input['branch_id'] ?? null,
            'customer_id'     => $input['customer_id'] ?? null,
            'user_id'         => $input['user_id'] ?? null,
            'payment_method'  => $input['payment_method'] ?? null,
            'voucher_type'    => $input['voucher_type'] ?? null,
            'status'          => $input['status'] ?? null,

            'date_start'      => $input['date_start'] ?? null,
            'date_end'        => $input['date_end'] ?? null,
        ];
    }

    private function baseQuery(array $filters)
    {
        $query = Sale::query()
            ->where('sales.company_id', $filters['company_id']);

        if (!empty($filters['branch_id'])) {
            $query->where('sales.branch_id', $filters['branch_id']);
        }

        if (!empty($filters['customer_id'])) {
            $query->where('sales.customer_id', $filters['customer_id']);
        }

        if (!empty($filters['user_id'])) {
            $query->where('sales.user_id', $filters['user_id']);
        }

        if (!empty($filters['payment_method'])) {
            $query->where('sales.payment_method', $filters['payment_method']);
        }

        if (!empty($filters['voucher_type'])) {
            $query->where('sales.voucher_type', $filters['voucher_type']);
        }

        if (!empty($filters['status'])) {
            $query->where('sales.status', $filters['status']);
        }

        if (!empty($filters['date_start'])) {
            $query->whereDate('sales.sale_date', '>=', $filters['date_start']);
        }

        if (!empty($filters['date_end'])) {
            $query->whereDate('sales.sale_date', '<=', $filters['date_end']);
        }
        return $query;
    }

    private function summary($query)
    {
        $sales = clone $query;
        return [
            'sales_count' => $sales->count(),
            'total_amount' => (float) (clone $query)->sum('total'),
            'subtotal_amount' => (float) (clone $query)->sum('subtotal'),
            'tax_amount' => (float) (clone $query)->sum('tax'),
            'discount_amount' => (float) (clone $query)->sum('discount'),
            'total_products' => (float) (clone $query)
                ->join('sale_details', 'sales.id', '=', 'sale_details.sale_id')
                ->sum('sale_details.quantity'),
            'average_ticket' => (float) (
                (clone $query)->count() > 0 ? (clone $query)->sum('total') / (clone $query)->count() : 0
            ),
        ];
    }

    private function salesByDay($query)
    {
        return (clone $query)
            ->selectRaw("
            DATE(sale_date) as date,
            COUNT(id) as total_sales,
            SUM(total) as total_amount
        ")
            ->groupBy(DB::raw("DATE(sale_date)"))
            ->orderBy("date")
            ->get();
    }

    private function salesByMonth($query)
    {
        return (clone $query)
            ->selectRaw("
            YEAR(sale_date) AS year,
            MONTH(sale_date) AS month,
            COUNT(id) AS total_sales,
            SUM(total) AS total_amount
        ")
            ->groupBy(
                DB::raw("YEAR(sale_date)"),
                DB::raw("MONTH(sale_date)")
            )
            ->orderBy("year")
            ->orderBy("month")
            ->get();
    }

    private function topProducts($query)
    {
        return (clone $query)
            ->join('sale_details', 'sales.id', '=', 'sale_details.sale_id')
            ->join('products', 'sale_details.product_id', '=', 'products.id')
            ->select(
                'products.id',
                'products.code',
                'products.name'
            )
            ->selectRaw('SUM(sale_details.quantity) AS total_quantity')
            ->selectRaw('SUM(sale_details.subtotal) AS total_sales')
            ->selectRaw('COUNT(DISTINCT sales.id) AS total_orders')
            ->groupBy(
                'products.id',
                'products.code',
                'products.name'
            )
            ->orderByDesc('total_quantity')
            ->limit(10)
            ->get();
    }

    private function topCustomers($query)
    {
        return (clone $query)
            ->leftJoin('customers', 'sales.customer_id', '=', 'customers.id')
            ->select(
                'customers.id',
                'customers.name'
            )
            ->selectRaw('COUNT(sales.id) AS total_sales')
            ->selectRaw('SUM(sales.total) AS total_amount')
            ->selectRaw('AVG(sales.total) AS average_ticket')
            ->selectRaw('MAX(sales.sale_date) AS last_purchase')
            ->groupBy(
                'customers.id',
                'customers.name'
            )
            ->orderByDesc('total_amount')
            ->limit(10)
            ->get();
    }

    private function paymentMethods($query)
    {
        return (clone $query)
            ->select(
                'payment_method'
            )
            ->selectRaw('COUNT(id) AS total_sales')
            ->selectRaw('SUM(total) AS total_amount')
            ->selectRaw('AVG(total) AS average_ticket')
            ->groupBy(
                'payment_method'
            )
            ->orderByDesc('total_amount')
            ->get();
    }

    private function voucherTypes($query)
    {
        return (clone $query)
            ->select(
                'voucher_type'
            )
            ->selectRaw('COUNT(id) AS total_sales')
            ->selectRaw('SUM(total) AS total_amount')
            ->selectRaw('AVG(total) AS average_ticket')
            ->groupBy(
                'voucher_type'
            )
            ->orderByDesc('total_amount')
            ->get();
    }

    private function salesList($query)
    {
        return (clone $query)
            ->join('customers', 'sales.customer_id', '=', 'customers.id')
            ->join('users', 'sales.user_id', '=', 'users.id')
            ->join('branches', 'sales.branch_id', '=', 'branches.id')
            ->select(
                'sales.id',
                'sales.sale_date',
                'sales.voucher_type',
                'sales.payment_method',
                'sales.status',

                'sales.subtotal',
                'sales.tax',
                'sales.discount',
                'sales.total',

                'customers.name AS customer_name',
                'users.name AS seller_name',
                'branches.name AS branch_name'
            )
            ->orderByDesc('sales.sale_date')
            ->get();
    }
}
