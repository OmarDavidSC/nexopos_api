<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\CashRegister;
use App\Services\BranchService;
use App\Services\CashService;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class CashDow
{
    public function index($request)
    {
        $response = FG::responseDefault();

        try {
            $company_id = Application::getItem('company_id');

            $cashRegisters = CashRegister::where('company_id', $company_id);
            $cash = BranchService::applyBranchScope($cashRegisters);
            $cash = $cash->whereNull('deleted_at')->orderBy('name', 'asc')->get();

            $response['success'] = true;
            $response['data'] = $cash;
            $response['message'] = 'successfully.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function show($request)
    {
        $response = FG::responseDefault();

        try {

            $company_id = Application::getItem('company_id');
            $id = $request->getAttribute('id');

            $query = CashRegister::where('company_id', $company_id);

            BranchService::applyBranchScope($query);
            $cash = $query
                ->whereNull('deleted_at')
                ->with(['sessions' => function ($query) {
                    $query->with(['movements'])->orderBy('created_at', 'desc');
                }])->findOrFail($id);

            $response['success'] = true;
            $response['data'] = [
                'cash_register' => $cash,
                'summary' => CashService::cashSummary($cash->id)
            ];
            $response['message'] = 'successfully.';
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
            $branch_id = Application::getItem('branch_id');

            $name = $input['name'];
            if (empty($name)) {
                $response['success'] = false;
                $response['message'] = 'Nombre es campo obligatorio.';
                return $response;
            }

            $cash = new CashRegister();
            $cash->company_id = $company_id;
            $cash->branch_id = $branch_id;
            $cash->name = $name;
            $cash->status = 1;
            $cash->save();

            $response['success'] = true;
            $response['message'] = 'Caja registrada correctamente.';
        } catch (\Exception $e) {

            $response['message'] = $e->getMessage();
        }

        return $response;
    }

    public function update($request)
    {
        $response = FG::responseDefault();
        try {

            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $query = CashRegister::where('company_id', $company_id);
            BranchService::applyBranchScope($query);
            $cash = $query->whereNull('deleted_at')->findOrFail($input['id']);

            $cash->name = trim($input['name']);
            $cash->save();

            $response['success'] = true;
            $response['data'] = $cash;
            $response['message'] = 'Caja actualizada correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function opensession($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');
            $user_id = Application::getItem('user_id');

            $query = CashRegister::where('company_id', $company_id);

            BranchService::applyBranchScope($query);
            $query->findOrFail($input['cash_register_id']);

            if ($input['opening_amount'] < 0) {
                throw new \Exception("El monto inicial no puede ser negativo.");
            }

            $session = CashService::openSession($company_id, $branch_id, $input['cash_register_id'], $user_id, $input['opening_amount']);

            $response['success'] = true;
            $response['data'] = $session;
            $response['message'] = 'Caja aperturada correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function closesession($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();
            $user_id = Application::getItem('user_id');
            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');

            $query = CashRegister::where('company_id', $company_id);
            BranchService::applyBranchScope($query);
            $query->findOrFail($input['cash_register_id']);

            $session = CashService::currentSession($company_id, $branch_id, $input['cash_register_id']);

            if (!$session) {
                throw new \Exception("No existe una caja abierta.");
            }

            $session = CashService::closeSession($session->id, $user_id, $input['closing_amount']);

            $response['success'] = true;
            $response['data'] = $session;
            $response['message'] = 'Caja cerrada correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function income($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');
            $user_id = Application::getItem('user_id');
            $branch_id = Application::getItem('branch_id');

            $amount = (float) $input['amount'];
            $description = $input['description'];

            if (empty($amount)  || empty($description)) {
                $response['success'] = false;
                $response['message'] = 'Complete los campos obligatorios.';
                return $response;
            }

            if ($amount <= 0) {
                throw new \Exception("El monto debe ser mayor a cero.");
            }

            $session = CashService::currentSession($company_id, $branch_id, $input['cash_register_id']);
            if (!$session) {
                throw new \Exception("No existe una caja abierta.");
            }

            $movement = CashService::registerMovement($company_id, $session->id, $user_id, 'INCOME', $amount, $description);

            $response['success'] = true;
            $response['data'] = $movement;
            $response['message'] = 'Ingreso manual registrado correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function expense($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();

            $company_id = Application::getItem('company_id');
            $user_id = Application::getItem('user_id');
            $branch_id = Application::getItem('branch_id');

            $amount = (float) $input['amount'];
            $description = $input['description'];

            if (empty($amount)  || empty($description)) {
                $response['success'] = false;
                $response['message'] = 'Complete los campos obligatorios.';
                return $response;
            }

            if ($amount <= 0) {
                throw new \Exception("El monto debe ser mayor a cero.");
            }

            $session = CashService::currentSession($company_id, $branch_id, $input['cash_register_id']);
            if (!$session) {
                throw new \Exception("No existe una caja abierta.");
            }

            $movement = CashService::registerMovement($company_id,  $session->id, $user_id, 'EXPENSE', $amount, $description);

            $response['success'] = true;
            $response['data'] = $movement;
            $response['message'] = 'Egreso manual registrado correctamente.';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }
}
