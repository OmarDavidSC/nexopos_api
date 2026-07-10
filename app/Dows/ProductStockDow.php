<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Product;
use App\Models\ProductStocks;
use App\Services\ProductStockService;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class ProductStockDow
{
    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $company_id = Application::getItem('company_id');
            $branch_id = $request->getAttribute('branch_id');

            $query = Product::with([
                'category:id,name',
                'brand:id,name',
                'unit:id,name'
            ])
                ->leftJoin('product_stocks as ps', function ($join) use ($branch_id) {
                    $join->on('ps.product_id', '=', 'products.id')
                        ->where('ps.branch_id', '=', $branch_id);
                })
                ->where('products.company_id', $company_id)
                ->whereNull('products.deleted_at')
                ->select([
                    'products.id as product_id',
                    'products.code',
                    'products.name',
                    'products.category_id',
                    'products.brand_id',
                    'products.unit_id',
                    'ps.id as stock_id',
                    DB::raw('COALESCE(ps.current_stock,0) as current_stock'),
                    DB::raw('COALESCE(ps.minimum_stock,0) as minimum_stock')
                ]);

            $products = $query->get();

            $data = $products->map(function ($item) {
                if ($item->current_stock <= 0) {
                    $stock_status = 'Agotado';
                    $stock_color = 'danger';
                } elseif ($item->current_stock <= $item->minimum_stock) {
                    $stock_status = 'Stock Bajo';
                    $stock_color = 'warning';
                } else {
                    $stock_status = 'Disponible';
                    $stock_color = 'success';
                }

                return [
                    'id' => $item->stock_id,
                    'product_id' => $item->product_id,
                    'code' => $item->code,
                    'name' => $item->name,
                    'category' => $item->category?->name,
                    'brand' => $item->brand?->name,
                    'unit' => $item->unit?->name,
                    'current_stock' => $item->current_stock,
                    'minimum_stock' => $item->minimum_stock,
                    'stock_status' => $stock_status,
                    'stock_color' => $stock_color
                ];
            });

            $response['success'] = true;
            $response['data'] = [
                'summary' => $this->getSummary($company_id, $branch_id),
                'data' => $data
            ];
            $response['message'] = 'successfully.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function store($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            ProductStocks::updateOrCreate(
                [
                    'company_id' => $company_id,
                    'branch_id' => $input['branch_id'],
                    'product_id' => $input['product_id']
                ],
                [
                    'current_stock' => $input['current_stock'],
                    'minimum_stock' => $input['minimum_stock']
                ]
            );

            $response['success'] = true;
            $response['message'] = 'Stock asignado correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function update($request)
    {
        $response = FG::responseDefault();
        try {
            $id = $request->getAttribute('id');
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $stock = ProductStocks::where('company_id', $company_id)->where('id', $id)->first();

            if (!$stock) {
                $response['success'] = false;
                $response['message'] = 'Stock no encontrado.';
                return $response;
            }

            if (isset($input['current_stock'])) {
                $stock->current_stock = $input['current_stock'];
            }

            if (isset($input['minimum_stock'])) {
                $stock->minimum_stock = $input['minimum_stock'];
            }

            $stock->save();
            $response['success'] = true;
            $response['data'] = $stock;
            $response['message'] = 'Stock actualizado correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function getSummary($company_id, $branch_id)
    {
        $products = Product::leftJoin('product_stocks as ps', function ($join) use ($branch_id, $company_id) {
            $join->on('ps.product_id', '=', 'products.id')
                ->where('ps.branch_id', '=', $branch_id)
                ->where('ps.company_id', '=', $company_id);
        })
            ->where('products.company_id', $company_id)
            ->whereNull('products.deleted_at')
            ->get([
                'products.status',
                DB::raw('COALESCE(ps.current_stock,0) as current_stock'),
                DB::raw('COALESCE(ps.minimum_stock,0) as minimum_stock')
            ]);
        return [
            'total_products' => $products->count(),
            'active_products' => $products->where('status', 1)->count(),
            'low_stock' => $products->filter(function ($p) {
                return $p->current_stock > 0 && $p->current_stock <= $p->minimum_stock;
            })->count(),
            'out_stock' => $products->where('current_stock', '<=', 0)->count()
        ];
    }
}
