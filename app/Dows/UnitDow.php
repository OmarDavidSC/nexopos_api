<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Unit;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class UnitDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Unit::where('company_id', $company_id)
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
                    'abbreviation' => $item->abbreviation,
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

            $units = Unit::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $units = $units->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $units;
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
            $abbreviation = trim($input['abbreviation']);
            $company_id = Application::getItem('company_id');

            if (empty($name)) {
                $response['success'] = false;
                $response['message'] = "Nombre es campo obligatorio";
                return $response;
            }

            if (empty($abbreviation)) {
                $response['success'] = false;
                $response['message'] = "Abreviatura es campo obligatorio";
                return $response;
            }

            $unit = new Unit();
            $unit->name = $name;
            $unit->abbreviation = $abbreviation;
            $unit->company_id = $company_id;
            $unit->status = 1;
            $unit->save();

            $response['success'] = true;
            $response['data'] = $unit;
            $response['message'] = 'Tipo de unidad registrada correctamente.';
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

            $unit = Unit::find($id);
            if (!$unit) {
                $response['success'] = false;
                $response['message'] = "Tipo de unidad no fue encontrada.";
                return $response;
            }

            if (empty($input['name'])) {
                $response['success'] = false;
                $response['message'] = "Campo nombre es obligatorio.";
                return $response;
            }

            if (empty($input['abbreviation'])) {
                $response['success'] = false;
                $response['message'] = "Campo abreviatura es obligatorio.";
                return $response;
            }

            $unit->name = $input['name'];
            $unit->abbreviation = $input['abbreviation'];
            $unit->save();

            $response['success'] = true;
            $response['data'] = $unit;
            $response['message'] = "Tipo de unidad actualizado correctamente.";
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

            $unit = Unit::find($id);
            if (!$unit) {
                $response['success'] = false;
                $response['message'] = "Tipo de unidad no fue encontrada.";
                return $response;
            }

            $unit->deleted_at = FG::getDateHour();
            $unit->save();

            $response['success'] = true;
            $response['data'] = $unit;
            $response['message'] = "Tipo de unidad eliminada correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
