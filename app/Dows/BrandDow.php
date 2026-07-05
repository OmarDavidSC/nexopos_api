<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Brand;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class BrandDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Brand::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $units = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $units->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
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

            $brands = Brand::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $brands = $brands->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $brands;
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

            if (empty($name)) {
                $response['success'] = false;
                $response['message'] = "Nombre es campo obligatorio";
                return $response;
            }

            $brand = new Brand();
            $brand->name = $name;
            $brand->company_id = $company_id;
            $brand->status = 1;
            $brand->save();

            $response['success'] = true;
            $response['data'] = $brand;
            $response['message'] = 'Marca registrada correctamente.';
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

            $brand = Brand::find($id);
            if (!$brand) {
                $response['success'] = false;
                $response['message'] = "Marca no fue encontrada.";
                return $response;
            }

            if (empty($input['name'])) {
                $response['success'] = false;
                $response['message'] = "Campo nombre es obligatorio.";
                return $response;
            }

            $brand->name = $input['name'];
            $brand->save();

            $response['success'] = true;
            $response['data'] = $brand;
            $response['message'] = "Marca actualizada correctamente.";
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

            $brand = Brand::find($id);
            if (!$brand) {
                $response['success'] = false;
                $response['message'] = "Marca no fue encontrada.";
                return $response;
            }

            $brand->deleted_at = FG::getDateHour();
            $brand->save();

            $response['success'] = true;
            $response['data'] = $brand;
            $response['message'] = "Marca eliminada correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
