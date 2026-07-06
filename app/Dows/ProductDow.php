<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Product;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class ProductDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $query = Product::with([
                'category:id,name',
                'brand:id,name',
                'unit:id,name,abbreviation'
            ])
                ->where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $products = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $products->map(function ($item) {
                return [
                    'id' => $item->id,
                    'code' => $item->code,
                    'name' => $item->name,
                    'category_id' => $item->category_id,
                    'category' => $item->category?->name,
                    'brand_id' => $item->brand_id,
                    'brand' => $item->brand?->name,
                    'unit_id' => $item->unit_id,
                    'unit' => $item->unit?->name,
                    'purchase_price' => $item->purchase_price,
                    'sale_price' => $item->sale_price,
                    'current_stock' => $item->current_stock,
                    'minimum_stock' => $item->minimum_stock,
                    'status' => $item->status == 1 ? 'Activo' : 'Inactivo',
                    'datecreated_label' => FG::formatDateTimeHuman($item->created_at),
                    'dateupdated_label' => FG::formatDateTimeHuman($item->updated_at),
                ];
            });

            $response['success'] = true;
            $response['data'] = [
                'page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'total_pages' => ceil($total / $perPage),
                'data' => $data
            ];
            $response['message'] = 'successully';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function adm($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');

            $products = Product::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $products = $products->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $products;
            $response['message'] = 'adm sucessfully';
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
            $user_id = Application::getItem('user_id');

            $name = trim($input['name']);
            $company_id = Application::getItem('company_id');
            $category_id =  (int) trim($input['category_id']);
            $brand_id =  (int) trim($input['brand_id']);
            $unit_id =  (int) trim($input['unit_id']);
            $code = trim($input['code']);
            $bar_code = trim($input['bar_code']);
            $description = trim($input['description']);
            $purchase_price = trim($input['purchase_price']);
            $sale_price = trim($input['sale_price']);
            $minimum_stock = trim($input['minimum_stock']);
            $current_stock = trim($input['current_stock']);

            //validacion de campos obligatorios
            if (empty($name) || empty($category_id) || empty($brand_id) || empty($unit_id) || empty($purchase_price) || empty($sale_price)) {
                $response['success'] = false;
                $response['message'] = "Campos obligatorios incompletos.";
                return $response;
            }

            $product = new Product();
            $product->company_id = $company_id;
            $product->category_id = $category_id;
            $product->brand_id = $brand_id;
            $product->unit_id = $unit_id;
            $product->code = $code;
            $product->barcode = $bar_code;
            $product->name = $name;
            $product->description = $description;
            $product->purchase_price = $purchase_price;
            $product->sale_price = $sale_price;
            $product->minimum_stock = $minimum_stock;
            $product->current_stock = $current_stock;
            $product->status = 1;
            $product->save();

            $response['success'] = true;
            $response['data'] = $product;
            $response['message'] = 'Producto registrado correctamente.';
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
            $user_id = Application::getItem('user_id');

            $product = Product::find($id);
            if (!$product) {
                $response['success'] = false;
                $response['message'] = "Producto no fue encontrado.";
                return $response;
            }

            if (empty($input['name'])) {
                $response['success'] = false;
                $response['message'] = "Campo nombre es obligatorio.";
                return $response;
            }

            if (empty($input['name']) || empty($input['category_id']) || empty($input['brand_id']) || empty($input['unit_id']) || empty($input['purchase_price']) || empty($input['sale_price'])) {
                $response['success'] = false;
                $response['message'] = "Campos obligatorios incompletos.";
                return $response;
            }

            $product->category_id = $input['category_id'];
            $product->brand_id = $input['brand_id'];
            $product->unit_id = $input['unit_id'];
            $product->code = $input['code'];
            $product->barcode = $input['barcode'];
            $product->name = $input['name'];
            $product->description = $input['description'];
            $product->purchase_price = $input['purchase_price'];
            $product->sale_price = $input['sale_price'];
            $product->minimum_stock = $input['minimum_stock'];
            $product->current_stock = $input['current_stock'];
            $product->save();

            $response['success'] = true;
            $response['data'] = $product;
            $response['message'] = "Producto actualizado correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function remove($request)
    {
        $response = FG::responseDefault();
        try {
            $id = $request->getAttribute('id');

            $product = Product::find($id);
            if (!$product) {
                $response['success'] = false;
                $response['message'] = "Producto no fue encontrado.";
                return $response;
            }

            $product->deleted_at = FG::getDateHour();
            $product->save();

            $response['success'] = true;
            $response['data'] = $product;
            $response['message'] = "Producto eliminado correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
