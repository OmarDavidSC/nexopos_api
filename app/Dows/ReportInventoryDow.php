<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Purchase;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class ReportInventoryDow
{

    public function index($request)
    {
        $response = FG::responseDefault();
        try {

            $data = $request->getParsedBody();
            $company_id = Application::getItem('company_id');


            $query = DB::table('inventory_movements')->where('inventory_movements.company_id', $company_id);
            if (!empty($data['branch_id'])) {
                $query->where('inventory_movements.branch_id', $data['branch_id']);
            }


            if (!empty($data['product_id'])) {
                $query->where('inventory_movements.product_id', $data['product_id']);
            }


            if (!empty($data['date_start'])) {
                $query->whereDate('inventory_movements.created_at', '>=', $data['date_start']);
            }


            if (!empty($data['date_end'])) {
                $query->whereDate('inventory_movements.created_at', '<=', $data['date_end']);
            }


            $response['success'] = true;
            $response['data'] = [
                "summary" => $this->summary($query),
                "stock" => $this->currentStock($company_id, $data),
                "movements" => $this->movements($query),
                "products" => $this->productsInventory($company_id, $data),
                "low_stock" => $this->lowStock($company_id, $data),
                "by_category" => $this->inventoryByCategory($company_id, $data),
                "by_branch" => $this->inventoryByBranch($company_id, $data)
            ];

            $response['message'] = 'successfully.';
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function summary($query)
    {
        return [
            "total_movements" => $query->count(),
            "total_entries" => (clone $query)->whereIn('type', ['ENTRY', 'PURCHASE', 'ADJUSTMENT_IN'])->sum('quantity'),
            "total_exits" => (clone $query)->whereIn('type', ['EXIT', 'SALE', 'ADJUSTMENT_OUT'])->sum('quantity'),
            "total_products" => DB::table('products')
                ->where('company_id', Application::getItem('company_id'))
                ->count()
        ];
    }

    private function currentStock($company_id, $data)
    {

        $query = DB::table('product_stocks')
            ->join('products', 'products.id', '=', 'product_stocks.product_id')
            ->join('branches', 'branches.id', '=', 'product_stocks.branch_id')
            ->where('product_stocks.company_id', $company_id)
            ->select(
                'products.id',
                'products.code',
                'products.name',
                'branches.name as branch_name',
                'product_stocks.current_stock',
                'product_stocks.minimum_stock'
            );


        if (!empty($data['branch_id'])) {
            $query->where('product_stocks.branch_id', $data['branch_id']);
        }
        return $query->get();
    }

    private function movements($query)
    {

        return $query
            ->join('products', 'products.id', '=', 'inventory_movements.product_id')
            ->join('users', 'users.id', '=', 'inventory_movements.user_id')
            ->select(
                'inventory_movements.*',
                'products.name as product_name',
                'products.code',
                DB::raw("CONCAT(users.name,' ',users.paternal_surname) as user_name")
            )->orderBy('inventory_movements.created_at', 'DESC')->get();
    }

    private function productsInventory($company_id, $data)
    {

        return DB::table('inventory_movements')
            ->join('products', 'products.id', '=', 'inventory_movements.product_id')
            ->where(
                'inventory_movements.company_id',
                $company_id
            )->select(
                'products.id',
                'products.name',
                DB::raw("SUM(inventory_movements.quantity)as total_quantity"),
                DB::raw("COUNT(inventory_movements.id)as total_movements")
            )
            ->groupBy('products.id', 'products.name')
            ->orderBy('total_quantity', 'DESC')->get();
    }

    private function lowStock($company_id, $data)
    {

        $query = DB::table('product_stocks')
            ->join('products', 'products.id', '=', 'product_stocks.product_id')
            ->join('branches', 'branches.id', '=', 'product_stocks.branch_id')
            ->where('product_stocks.company_id', $company_id)
            ->whereRaw('product_stocks.current_stock <= product_stocks.minimum_stock');


        if (!empty($data['branch_id'])) {
            $query->where('product_stocks.branch_id', $data['branch_id']);
        }

        return $query->select(
            'products.name',
            'products.code',
            'branches.name as branch_name',
            'product_stocks.current_stock',
            'product_stocks.minimum_stock'
        )->get();
    }

    private function inventoryByCategory($company_id, $data)
    {

        $query = DB::table('product_stocks')
            ->join('products', 'products.id', '=', 'product_stocks.product_id')
            ->leftJoin('categories', 'categories.id', '=', 'products.category_id')
            ->where('product_stocks.company_id', $company_id);

        if (!empty($data['branch_id'])) {
            $query->where('product_stocks.branch_id', $data['branch_id']);
        }

        return $query
            ->select(
                DB::raw("COALESCE(categories.name,'SIN CATEGORIA')as category"),
                DB::raw("COUNT(products.id)as total_products"),
                DB::raw("SUM(product_stocks.current_stock)as total_stock"),
                DB::raw("SUM(product_stocks.current_stock *products.purchase_price)as inventory_value")
            )
            ->groupBy('categories.name')
            ->orderBy('total_stock', 'DESC')->get();
    }

    private function inventoryByBranch($company_id, $data)
    {

        return DB::table('product_stocks')
            ->join('branches', 'branches.id', '=', 'product_stocks.branch_id')
            ->join('products', 'products.id', '=', 'product_stocks.product_id')
            ->where('product_stocks.company_id', $company_id)
            ->select(
                'branches.name as branch',
                DB::raw("COUNT(products.id)as total_products"),
                DB::raw("SUM(product_stocks.current_stock)as total_stock"),
                DB::raw("SUM( product_stocks.current_stock *products.purchase_price)as inventory_value")
            )
            ->groupBy('branches.id', 'branches.name')
            ->orderBy('total_stock', 'DESC')->get();
    }
}
