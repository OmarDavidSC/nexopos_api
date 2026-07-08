<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Customer;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class CustomerDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $company_id = Application::getItem('company_id');

            $query = Customer::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('id', 'desc');

            $total = $query->count();

            $customers = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $customers->map(function ($item) {
                return [
                    'id' => $item->id,
                    'document_type' => $item->document_type,
                    'document_number' => $item->document_number,
                    'name' => $item->name,
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

            $customers = Customer::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->orderBy('name', 'asc')
                ->get();

            $customers = $customers->map(function ($item) {
                return [
                    'id' => $item->id,
                    'name' => $item->name,
                    'document_number' => $item->document_number
                ];
            });

            $response['success'] = true;
            $response['data'] = $customers;
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
            $document_type = trim($input['document_type']);
            $document_number = trim($input['document_number']);
            $name = trim($input['name']);
            $phone = trim($input['phone']);
            $email = trim($input['email']);
            $address = trim($input['address']);

            //validar los campos obligatorios
            if (empty($document_type) || empty($document_number)) {
                $response['success'] = false;
                $response['message'] = 'Los campos tipo y número de documento son obligatorios.';
                return $response;
            }

            if (empty($name) || empty($address)) {
                $response['success'] = false;
                $response['message'] = 'Los Campos Nombre y Dirección son obligatorios.';
                return $response;
            }

            if (!empty($email) && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
                $response['success'] = false;
                $response['message'] = 'El correo debe ser un formato valido.';
                return $response;
            }

            $customer = new Customer();
            $customer->company_id = $company_id;
            $customer->document_type = $document_type;
            $customer->document_number = $document_number;
            $customer->name = $name;
            $customer->phone = $phone;
            $customer->email = $email;
            $customer->address = $address;
            $customer->status = 1;
            $customer->save();

            $response['success'] = true;
            $response['data'] = $customer;
            $response['message'] = 'Cliente Registrador Correctamente.';
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

            $customer = Customer::where('company_id', $company_id)
                ->where('id', $id)
                ->first();
            if (!$customer) {
                $response['success'] = false;
                $response['message'] = "Cliente no fue encontrado.";
                return $response;
            }

            if (empty($input['document_type']) || empty($input['document_number'])) {
                $response['success'] = false;
                $response['message'] = 'Los campos tipo y número de documento son obligatorios.';
                return $response;
            }

            if (empty($input['name']) || empty($input['address'])) {
                $response['success'] = false;
                $response['message'] = 'Los Campos Nombre y Dirección son obligatorios.';
                return $response;
            }

            if (!empty($input['email']) && !filter_var($input['email'], FILTER_VALIDATE_EMAIL)) {
                $response['success'] = false;
                $response['message'] = 'El correo debe ser un formato valido.';
                return $response;
            }


            $customer->document_type = $input['document_type'];
            $customer->document_number = $input['document_number'];
            $customer->name = $input['name'];
            $customer->phone = $input['phone'];
            $customer->email = $input['email'];
            $customer->address = $input['address'];
            $customer->save();

            $response['success'] = true;
            $response['data'] = $customer;
            $response['message'] = "Cliente actualizado correctamente.";
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

            $customer = Customer::where('company_id', $company_id)
                ->where('id', $id)
                ->first();
            if (!$customer) {
                $response['success'] = false;
                $response['message'] = "Cliente no fue encontrado.";
                return $response;
            }

            $customer->deleted_at = FG::getDateHour();
            $customer->save();

            $response['success'] = true;
            $response['data'] = $customer;
            $response['message'] = "Cliente eliminado correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
