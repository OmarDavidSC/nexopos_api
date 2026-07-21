<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Purchase;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class DashboardDow
{

    public function index($request)
    {
        $response = FG::responseDefault();
        try {

            $data = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $response['success'] = true;
            $response['data'] = [
                "summary" => $this->summary($company_id),

                // "inventory" => $this->inventorySummary($company_id),
                // "alerts" => $this->alerts($company_id),
                // "sales_today" => $this->salesToday($company_id),
                // "purchases_today" => $this->purchasesToday($company_id),
                // "sales_chart" => $this->salesChart($company_id),
                "top_products" => $this->topProducts($company_id),
                "top_categories" => $this->topCategories($company_id),
                // "branch_performance" => $this->branchPerformance($company_id)
            ];

            $response['message'] = 'successfully.';
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function summary($company_id)
    {
        return [
            "total_products" => DB::table('products')->where('company_id', $company_id)->count(),
            "sales_month" => DB::table('sales')
                ->where('company_id', $company_id)
                ->whereMonth('sale_date', date('m'))
                ->whereYear('sale_date', date('Y'))
                ->sum('total'),
            "purchases_month" => DB::table('purchases')
                ->where('company_id', $company_id)
                ->whereMonth('purchase_date', date('m'))
                ->whereYear('purchase_date', date('Y'))
                ->sum('total'),
            "inventory_value" => DB::table('product_stocks')
                ->join('products', 'products.id', '=', 'product_stocks.product_id')
                ->where('product_stocks.company_id', $company_id)
                ->sum(DB::raw(
                    'product_stocks.current_stock * products.purchase_price'
                ))
        ];
    }

    private function alerts($company_id)
    {
        return DB::table('product_stocks')
            ->join('products', 'products.id', '=', 'product_stocks.product_id')
            ->join('branches', 'branches.id', '=', 'product_stocks.branch_id')
            ->where('product_stocks.company_id', $company_id)
            ->whereRaw('current_stock <= minimum_stock')
            ->select(
                'products.name as product',
                'products.code',
                'branches.name as branch',
                'product_stocks.current_stock',
                'product_stocks.minimum_stock'
            )->orderBy('current_stock', 'ASC')->limit(10)->get();
    }

    private function inventorySummary($company_id)
    {
        return [
            "total_stock" => DB::table('product_stocks')->where('company_id', $company_id)->sum('current_stock'),
            "out_stock" => DB::table('product_stocks')->where('company_id', $company_id)->where('current_stock', 0)->count(),
            "low_stock" => DB::table('product_stocks')->where('company_id', $company_id)->whereRaw('current_stock < minimum_stock')->count()
        ];
    }

    private function salesToday($company_id)
    {
        return DB::table('sales')
            ->where('company_id', $company_id)
            ->whereDate('sale_date', date('Y-m-d'))
            ->where('status', 'COMPLETED')
            ->select(
                DB::raw("COUNT(id) as total_sales"),
                DB::raw("SUM(total) as total_amount")
            )->first();
    }

    private function purchasesToday($company_id)
    {
        return DB::table('purchases')
            ->where('company_id', $company_id)
            ->whereDate('purchase_date', date('Y-m-d'))
            ->where('status', 'COMPLETED')
            ->select(
                DB::raw("COUNT(id) as total_purchases"),
                DB::raw("SUM(total) as total_amount")
            )->first();
    }

    private function salesChart($company_id)
    {
        return DB::table('sales')
            ->where('company_id', $company_id)
            ->where('status', 'COMPLETED')
            ->whereDate('sale_date', '>=', date('Y-m-d', strtotime('-6 days')))
            ->select(
                DB::raw("DATE(sale_date) as date"),
                DB::raw("COUNT(id) as sales"),
                DB::raw("SUM(total) as amount")
            )
            ->groupBy(DB::raw("DATE(sale_date)"))->orderBy('date')->get();
    }

    private function topProducts($company_id)
    {
        return DB::table('sale_details')
            ->join('sales', 'sales.id', '=', 'sale_details.sale_id')
            ->join('products', 'products.id', '=', 'sale_details.product_id')
            ->where('sales.company_id', $company_id)
            ->where('sales.status', 'COMPLETED')
            ->select(
                'products.id',
                'products.name',
                'products.code',
                DB::raw("SUM(sale_details.quantity) as quantity"),
                DB::raw("SUM(sale_details.subtotal) as amount")
            )
            ->groupBy('products.id', 'products.name', 'products.code')
            ->orderByDesc('quantity')
            ->limit(10)
            ->get();
    }

    private function topCategories($company_id)
    {
        return DB::table('sale_details')
            ->join('sales', 'sales.id', '=', 'sale_details.sale_id')
            ->join('products', 'products.id', '=', 'sale_details.product_id')
            ->leftJoin('categories', 'categories.id', '=', 'products.category_id')
            ->where('sales.company_id', $company_id)
            ->where('sales.status', 'COMPLETED')
            ->select(
                DB::raw("COALESCE(categories.name,'SIN CATEGORIA') as category"),
                DB::raw("SUM(sale_details.quantity) as quantity"),
                DB::raw("SUM(sale_details.subtotal) as amount")
            )->groupBy('categories.name')->orderByDesc('quantity')->limit(10)->get();
    }

    private function branchPerformance($company_id)
    {
        return DB::table('sales')
            ->join('branches', 'branches.id', '=', 'sales.branch_id')
            ->where('sales.company_id', $company_id)
            ->where('sales.status', 'COMPLETED')
            ->select(
                'branches.id',
                'branches.name as branch',
                DB::raw("COUNT(sales.id) as total_sales"),
                DB::raw("SUM(sales.total) as total_amount")
            )->groupBy('branches.id', 'branches.name')->orderByDesc('total_amount')->get();
    }
}
