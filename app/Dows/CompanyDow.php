<?php

namespace App\Dows;

use App\Middlewares\Application;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;
use App\Models\Area;
use App\Models\Company;
use App\Models\User;

class CompanyDow
{

    public function index($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();


            $response['success'] = true;
            $response['data'] = null;
            $response['message'] = 'exito';
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
            $files = $request->getUploadedFiles();

            $company = Company::find($id);
            if (!$company) {
                $response['success'] = false;
                $response['message'] = "Los datos de la compañia no fueron encontrados.";
                return $response;
            }

            $company->name = $input['name'] ?? $company->name;
            $company->ruc = $input['ruc'] ?? $company->ruc;
            $company->business_name = $input['business_name'] ?? $company->business_name;
            $company->fiscal_address = $input['fiscal_address'] ?? $company->fiscal_address;
            $company->phone = $input['phone'] ?? $company->phone;
            $company->country_code = $input['country_code'] ?? $company->country_code;
            $company->currency_code = $input['currency_code'] ?? $company->currency_code;
            $company->currency_symbol = $input['currency_symbol'] ?? $company->currency_symbol;
            $company->currency_name = $input['currency_name'] ?? $company->currency_name;

            if (!preg_match('/^\d{11}$/', $company->ruc)) {
                throw new \Exception('El RUC debe contener 11 dígitos.');
            }

            if (!preg_match('/^\d{9,15}$/', $company->phone)) {
                throw new \Exception('El teléfono debe contener entre 9 y 15 dígitos.');
            }

            if ($company->business_name === '') {
                throw new \Exception('El nombre comercial es obligatorio.');
            }

            if ($company->fiscal_address === '') {
                throw new \Exception('La dirección fiscal es obligatoria.');
            }

            if (isset($input['terms_conditions'])) {
                $company->terms_conditions = $input['terms_conditions'];
            }

            if (isset($input['privacy_policies'])) {
                $company->privacy_policies = $input['privacy_policies'];
            }

            if (isset($files['favicon'])) {
                $uploadResponse = StorageDow::upload('profile', $files, 'localhost', 'favicon', $id);
                if ($uploadResponse['success']) {
                    $company->favicon_id = $uploadResponse['data']->id;
                } else {
                    throw new \Exception("Error al subir la Imagen: " . $uploadResponse['message']);
                }
            }

            if (isset($files['logo'])) {
                $uploadResponse = StorageDow::upload('profile', $files, 'localhost', 'logo', $id);
                if ($uploadResponse['success']) {
                    $company->logo_id = $uploadResponse['data']->id;
                } else {
                    throw new \Exception("Error al subir la Imagen: " . $uploadResponse['message']);
                }
            }

            $company->save();

            $response['success'] = true;
            $response['data'] = $company;
            $response['message'] = "Datos de la compañia actualizados correctamente.";
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
