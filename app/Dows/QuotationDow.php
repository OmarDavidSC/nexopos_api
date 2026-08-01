<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Services\QuotationService;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class QuotationDow
{

    public function index($request)
    {
        $response = FG::responseDefault();
        try {

            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $filters = [
                'page' => isset($input['page']) ? max((int) $input['page'], 1) : 1,
                'per_page' => isset($input['per_page']) ? max((int) $input['per_page'], 1) : 10,
                'search' => trim($input['search'] ?? ''),
                'customer_id' => isset($input['customer_id']) && $input['customer_id'] !== '' ? (int) $input['customer_id'] : null,
                'branch_id' => isset($input['branch_id']) && $input['branch_id'] !== '' ? (int) $input['branch_id'] : null,
                'status' => $input['status'] ?? '',
                'issue_date_start' => $input['issue_date_start'] ?? null,
                'issue_date_end' => $input['issue_date_end'] ?? null,
                'expiration_date_start' => $input['expiration_date_start'] ?? null,
                'expiration_date_end' => $input['expiration_date_end'] ?? null,
            ];

            $result = QuotationService::getPaginateList($company_id, $filters);

            $response['success'] = true;
            $response['data'] = $result;
            $response['message'] = 'Cotizaciones obtenidas correctamente';
        } catch (\Exception $e) {
            $response['success'] = false;
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
            $branch_id  = Application::getItem('branch_id');
            $user_id = Application::getItem('user_id');

            DB::beginTransaction();
            $quotation = QuotationService::store($input, $company_id, $branch_id, $user_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $quotation;
            $response['message'] = 'Cotización registrada correctamente.';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function show($request)
    {
        $response = FG::responseDefault();
        try {
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            $result = QuotationService::show($quotation_id, $company_id);

            $response['success'] = true;
            $response['data'] = $result;
            $response['message'] = 'Cotización obtenida correctamente';
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function accept($request)
    {
        $response = FG::responseDefault();
        try {
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            DB::beginTransaction();
            $quotation = QuotationService::accept($quotation_id, $company_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $quotation;
            $response['message'] = 'Cotización aceptada correctamente.!';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function reject($request)
    {
        $response = FG::responseDefault();
        try {
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            DB::beginTransaction();
            $quotation = QuotationService::reject($quotation_id, $company_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $quotation;
            $response['message'] = 'Cotización rechazada correctamente.!';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function sent($request)
    {
        $response = FG::responseDefault();
        try {
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            DB::beginTransaction();
            $quotation = QuotationService::markAsSent($quotation_id, $company_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $quotation;
            $response['message'] = 'Cotización marcada como enviada correctamente.!';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function convert($request)
    {
        $response = FG::responseDefault();
        try {
            $input = $request->getParsedBody();
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');
            $user_id = Application::getItem('user_id');

            DB::beginTransaction();
            $result = QuotationService::convertToSale($quotation_id, $input, $company_id, $user_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $result;
            $response['message'] = 'Cotización convertida en venta correctamente.!';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function cancel($request)
    {
        $response = FG::responseDefault();
        try {
            $quotation_id = (int) $request->getAttribute('id');
            $company_id = Application::getItem('company_id');

            DB::beginTransaction();
            $quotation = QuotationService::cancel($quotation_id, $company_id);
            DB::commit();

            $response['success'] = true;
            $response['data'] = $quotation;
            $response['message'] = 'Cotización cancelada correctamente.!';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
