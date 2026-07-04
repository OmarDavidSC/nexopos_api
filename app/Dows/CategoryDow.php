<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Category;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class CompanyDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Category::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $areas = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $areas->map(function ($item) {
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

            $areas = Category::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $areas = $areas->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $areas;
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

            $department = new Category();
            $department->name = $name;
            $department->company_id = $company_id;
            $department->status = 1;
            $department->save();

            $response['success'] = true;
            $response['data'] = $department;
            $response['message'] = 'Categoria registrada correctamete.';
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

            $area = Category::find($id);
            if (!$area) {
                $response['success'] = false;
                $response['message'] = "Categoria no fue encontrada.";
                return $response;
            }

            if (empty($input['name'])) {
                $response['success'] = false;
                $response['message'] = "Campo nombre es obligatorio.";
                return $response;
            }

            $area->name = $input['name'];
            $area->save();

            $response['success'] = true;
            $response['data'] = $area;
            $response['message'] = "Categoria actualizada correctamente.";
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

            $area = Category::find($id);
            if (!$area) {
                $response['success'] = false;
                $response['message'] = "Categoria no fue encontrada.";
                return $response;
            }

            $area->deleted_at = FG::getDateHour();
            $area->save();

            $response['success'] = true;
            $response['data'] = $area;
            $response['message'] = "Categoria eliminada correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
