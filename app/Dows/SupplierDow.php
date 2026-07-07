<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Supplier;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class SupplierDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Supplier::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $suppliers = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $suppliers->map(function ($item) {
                return [
                    'id' => $item->id,
                    'document_number' => $item->document_number,
                    'business_name' => $item->business_name,
                    'contact' => $item->contact,
                    'phone' => $item->phone,
                    'email' => $item->email,
                    'address' => $item->address,
                    'status' => $item->status,
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

            $suppliers = Supplier::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('business_name', 'asc')
                ->get();

            $suppliers = $suppliers->map(function ($item) {
                return [
                    'id' => $item->id,
                    'business_name' => $item->business_name,
                ];
            });

            $response['success'] = true;
            $response['data'] = $suppliers;
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

            $company_id = Application::getItem('company_id');
            $document_number = trim($input['document_number']);
            $business_name = trim($input['business_name']);
            $contact = trim($input['contact']);
            $phone = trim($input['phone']);
            $email = trim($input['email']);
            $address = trim($input['address']);

            //validar los campos obligatorios
            if (empty($document_number) || empty($business_name)) {
                $response['success'] = false;
                $response['message'] = 'Los campos documento y razón social son obligatorios.';
                return $response;
            }

            if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $response['success'] = false;
                $response['message'] = 'El correo debe ser un formato valido.';
                return $response;
            }

            $supplier = new Supplier();
            $supplier->company_id = $company_id;
            $supplier->document_number = $document_number;
            $supplier->business_name = $business_name;
            $supplier->contact = $contact;
            $supplier->phone = $phone;
            $supplier->email = $email;
            $supplier->address = $address;
            $supplier->status = 1;
            $supplier->save();

            $response['success'] = true;
            $response['data'] = $supplier;
            $response['message'] = 'Proveedor registrado correctamente.';
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
            $company_id = Application::getItem('company_id');

            $supplier = Supplier::where('company_id', $company_id)
                ->where('id', $id)
                ->first();
            if (!$supplier) {
                $response['success'] = false;
                $response['message'] = "Proveedor no fue encontrado.";
                return $response;
            }

            if (empty($input['document_number']) || empty($input['business_name'])) {
                $response['success'] = false;
                $response['message'] = "Los campos documento y razón social son obligatorios.";
                return $response;
            }

            $supplier->document_number = $input['document_number'];
            $supplier->business_name = $input['business_name'];
            $supplier->contact = $input['contact'];
            $supplier->phone = $input['phone'];
            $supplier->email = $input['email'];
            $supplier->address = $input['address'];
            $supplier->save();

            $response['success'] = true;
            $response['data'] = $supplier;
            $response['message'] = "Proveedor actualizado correctamente.";
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
            $company_id = Application::getItem('company_id');

            $supplier = Supplier::where('company_id', $company_id)
                ->where('id', $id)
                ->first();
            if (!$supplier) {
                $response['success'] = false;
                $response['message'] = "Proveedor no fue encontrado.";
                return $response;
            }

            $supplier->deleted_at = FG::getDateHour();
            $supplier->save();

            $response['success'] = true;
            $response['data'] = $supplier;
            $response['message'] = "Proveedor eliminado correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
