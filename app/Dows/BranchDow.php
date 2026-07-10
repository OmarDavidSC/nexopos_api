<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Branch;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class BranchDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Branch::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $branches = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $branches->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'code' => $item->code,
                    'phone' => $item->phone,
                    'email' => $item->email,
                    'address' => $item->address,
                    'status' => $item->status == 1,
                    'status_label' => $item->status == 1 ? 'Activo' : 'Inactivo',
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

            $branches = Branch::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $branches = $branches->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'code' => $item->code
                ];
            });

            $response['success'] = true;
            $response['data'] = $branches;
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
            $code = trim($input['code']);
            $phone = trim($input['phone']);
            $email = trim($input['email']);
            $address = trim($input['address']);
            $company_id = Application::getItem('company_id');

            if (empty($name) || empty($code)) {
                $response['success'] = false;
                $response['message'] = "Complete los campos obligatorios.";
                return $response;
            }

            $branch = new Branch();
            $branch->name = $name;
            $branch->code = $code;
            $branch->phone = $phone;
            $branch->email = $email;
            $branch->address = $address;
            $branch->company_id = $company_id;
            $branch->status = 1;
            $branch->save();

            $response['success'] = true;
            $response['data'] = $branch;
            $response['message'] = 'Sucursal registrada correctamente.';
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

            $branch = Branch::find($id);
            if (!$branch) {
                $response['success'] = false;
                $response['message'] = "Sucursal no fue encontrada.";
                return $response;
            }

            if (empty($input['name']) || empty($input['code'])) {
                $response['success'] = false;
                $response['message'] = "Complete los campos obligatorios.";
                return $response;
            }

            $branch->name = $input['name'];
            $branch->code = $input['code'];
            $branch->phone = $input['phone'];
            $branch->email = $input['email'];
            $branch->address = $input['address'];
            $branch->save();

            $response['success'] = true;
            $response['data'] = $branch;
            $response['message'] = "Sucursal fue actualizada correctamente.";
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

            $branch = Branch::find($id);
            if (!$branch) {
                $response['success'] = false;
                $response['message'] = "Sucursal no fue encontrada.";
                return $response;
            }

            $branch->deleted_at = FG::getDateHour();
            $branch->save();

            $response['success'] = true;
            $response['data'] = $branch;
            $response['message'] = "Sucursal eliminada correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
