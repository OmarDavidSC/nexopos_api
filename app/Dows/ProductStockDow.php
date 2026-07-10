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
            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');
            $branch_id = $request->getAttribute('branch_id');

            $stocks = ProductStocks::with(['product.category', 'product.brand', 'product.unit'])
                ->where('company_id', $company_id)
                ->where('branch_id', $branch_id)
                ->get();


            $data = $stocks->map(function ($item) {
                return [
                    'id' => $item->id,
                    'product_id' => $item->product_id,
                    'code' => $item->product?->code,
                    'name' => $item->product?->name,
                    'category' => $item->product?->category?->name,
                    'brand' => $item->product?->brand?->name,
                    'unit' => $item->product?->unit?->name,
                    'current_stock' => $item->current_stock,
                    'minimum_stock' => $item->minimum_stock
                ];
            });

            $response['success'] = true;
            $response['data'] = [
                'summary' => $this->getSummary($company_id, $branch_id),
                'data' => $data
            ];
            $response['message'] = 'successfully';
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

            $exists = ProductStocks::where(['company_id' => $company_id, 'branch_id' => $input['branch_id'], 'product_id' => $input['product_id']])->first();

            if ($exists) {
                $response['success'] = false;
                $response['message'] = 'El producto ya tiene stock asignado en esta sucursal.';
                return $response;
            }

            $stock = new ProductStocks();
            $stock->company_id = $company_id;
            $stock->branch_id = $input['branch_id'];
            $stock->product_id = $input['product_id'];
            $stock->current_stock = $input['current_stock'] ?? 0;
            $stock->minimum_stock = $input['minimum_stock'] ?? 0;
            $stock->save();

            $response['success'] = true;
            $response['data'] = $stock;
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
