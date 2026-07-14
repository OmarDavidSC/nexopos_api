<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\Product;
use App\Models\Sale;
use App\Models\SaleDetail;
use App\Services\BranchService;
use App\Services\InventoryService;
use App\Services\ProductStockService;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class SaleDow
{

    public function index($request)
    {
        $response = FG::responseDefault();
        try {

            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');
            // $branch_id = Application::getItem('branch_id');

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $search = trim($input['search'] ?? '');
            $customer_id = isset($input['customer_id']) && $input['customer_id'] !== '' ? (int)$input['customer_id'] : null;
            $branch_id = isset($input['branch_id']) && $input['branch_id'] !== '' ? (int)$input['branch_id'] : null;
            $status = $input['status'] ?? '';
            $payment_method = $input['payment_method'] ?? '';

            $query = Sale::with([
                'customer:id,name',
                'user:id,name'
            ])
                ->withCount('details')
                ->where('company_id', $company_id)
                ->whereNull('deleted_at');

            BranchService::applyBranchScope($query);

            if (!empty($search)) {
                $query->where(function ($q) use ($search) {
                    $q->where('voucher_series', 'LIKE', "%{$search}%")
                        ->orWhere('voucher_number', 'LIKE', "%{$search}%")
                        ->orWhereHas('customer', function ($customer) use ($search) {
                            $customer->where('name', 'LIKE', "%{$search}%");
                        });
                });
            }

            if (!empty($customer_id)) {
                $query->where('customer_id', $customer_id);
            }

            if (!empty($branch_id)) {
                $query->where('branch_id', $branch_id);
            }

            if ($status !== '') {
                $query->where('status', $status);
            }

            if ($payment_method !== '') {
                $query->where('payment_method', $payment_method);
            }

            $query->orderBy('id', 'DESC');
            $total = $query->count();
            $sales = $query->skip(($page - 1) * $perPage)->take($perPage)->get();
            $data = $sales->map(function ($item) {
                return [
                    'id' => $item->id,
                    'customer_id' => $item->customer_id,
                    'customer_name' => $item->customer?->name,
                    'user' => $item->user?->name,
                    'sale_date' => FG::formatDateTimeHuman($item->sale_date),
                    'voucher_type' => $item->voucher_type,
                    'voucher_series' => $item->voucher_series,
                    'voucher_number' => $item->voucher_number,
                    'voucher' => trim($item->voucher_type . ' ' . $item->voucher_series . '-' . $item->voucher_number),
                    'payment_method' => $item->payment_method,
                    'subtotal' => (float)$item->subtotal,
                    'tax' => (float)$item->tax,
                    'discount' => (float)$item->discount,
                    'total' => (float)$item->total,
                    'items_count' => $item->details_count,
                    'status' => $item->status,
                    'status_label' => FG::getStatusLabel($item->status),
                ];
            });

            $response['success'] = true;
            $response['data'] = [
                'page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'total_pages' => ceil($total / $perPage),
                'summary' => $this->getSummary($company_id),
                'data' => $data
            ];

            $response['message'] = 'successfully';
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function store($request)
    {
        $response = FG::responseDefault();
        DB::beginTransaction();
        try {
            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');
            $user_id = Application::getItem('user_id');

            $this->validateStore($input);
            $sale = $this->createSale($input, $company_id, $user_id, $branch_id);
            $details = json_decode($input['details'], true);

            foreach ($details as $detail) {
                $this->processSaleDetail($sale, $detail, $company_id, $user_id);
            }
            DB::commit();

            $response['success'] = true;
            $response['data'] = $sale;
            $response['message'] = 'Venta registrada correctamente.';
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
            $id = $request->getAttribute('id');
            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');

            $query = Sale::with([
                'customer:id,name',
                'details.product:id,code,name'
            ])
                ->where('company_id', $company_id)
                ->where('id', $id)
                ->whereNull('deleted_at');

            BranchService::applyBranchScope($query);
            $sale = $query->first();

            if (!$sale) {
                throw new \Exception("La venta no fue encontrada.");
            }

            $response['success'] = true;
            $response['data'] = [
                'sale' => [
                    'id' => $sale->id,
                    'customer_id' => $sale->customer_id,
                    'customer' => $sale->customer?->name,
                    'sale_date' => FG::formatDateTimeHuman($sale->sale_date),
                    'voucher_type' => $sale->voucher_type,
                    'voucher_series' => $sale->voucher_series,
                    'voucher_number' => $sale->voucher_number,
                    'payment_method' => $sale->payment_method,
                    'subtotal' => $sale->subtotal,
                    'tax' => $sale->tax,
                    'discount' => $sale->discount,
                    'total' => $sale->total,
                    'status' => $sale->status,
                ],
                'details' => $sale->details->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'product_id' => $item->product_id,
                        'code' => $item->product?->code,
                        'product' => $item->product?->name,
                        'quantity' => $item->quantity,
                        'sale_price' => $item->sale_price,
                        'discount' => $item->discount,
                        'subtotal' => $item->subtotal
                    ];
                })
            ];
            $response['success'] = true;
            $response['message'] = 'successfully';
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    public function cancel($request)
    {

        $response = FG::responseDefault();
        DB::beginTransaction();
        try {
            $id = $request->getAttribute('id');
            $company_id = Application::getItem('company_id');
            $branch_id = Application::getItem('branch_id');
            $user_id = Application::getItem('user_id');

            $query = Sale::with('details')
                ->where('company_id', $company_id)
                ->where('id', $id)
                ->whereNull('deleted_at');

            BranchService::applyBranchScope($query);
            $sale = $query->first();

            if (!$sale) {
                throw new \Exception("La venta no fue encontrada.");
            }

            if ($sale->status == 'CANCELLED') {
                throw new \Exception("La venta ya fue cancelada.");
            }

            foreach ($sale->details as $detail) {
                $this->reverseSaleDetail($sale, $detail, $company_id, $user_id);
            }

            $sale->status = 'CANCELLED';
            $sale->save();
            DB::commit();
            $response['success'] = true;
            $response['data'] = $sale;
            $response['message'] = 'Venta cancelada correctamente.';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function getSummary($company_id)
    {
        $query = Sale::where('company_id', $company_id)
            ->whereNull('deleted_at');
        BranchService::applyBranchScope($query);

        return [
            'total_sales' => (clone $query)->count(),
            'completed' => (clone $query)->where('status', 'COMPLETED')->count(),
            'cancelled' => (clone $query)->where('status', 'CANCELLED')->count(),
            'total_amount' => (clone $query)->where('status', 'COMPLETED')->sum('total'),
        ];
    }

    private function validateStore($input)
    {
        if (empty($input['customer_id'])) {
            throw new \Exception("Seleccione un cliente.");
        }

        if (empty($input['sale_date'])) {
            throw new \Exception("Seleccione la fecha de venta.");
        }

        if (empty($input['details'])) {
            throw new \Exception("Debe agregar productos.");
        }

        $details = json_decode($input['details'], true);
        if (!is_array($details) || count($details) == 0) {
            throw new \Exception("Debe agregar al menos un producto.");
        }
    }

    private function createSale($input, $company_id, $user_id, $branch_id)
    {

        $sale = new Sale();
        $sale->company_id = $company_id;
        $sale->branch_id = $branch_id;
        $sale->customer_id = $input['customer_id'];
        $sale->user_id = $user_id;
        $sale->sale_date = $input['sale_date'];
        $sale->voucher_type = $input['voucher_type'];
        $sale->voucher_series = $input['voucher_series'];
        $sale->voucher_number = $input['voucher_number'];
        $sale->payment_method = $input['payment_method'];
        $sale->subtotal = $input['subtotal'];
        $sale->tax = $input['tax'];
        $sale->discount = $input['discount'];
        $sale->total = $input['total'];
        $sale->status = 'COMPLETED';
        $sale->save();
        return $sale;
    }

    private function processSaleDetail(Sale $sale, array $item, int $company_id, int $user_id)
    {
        $product = Product::find($item['product_id']);
        if (!$product) {
            throw new \Exception("Producto no encontrado.");
        }

        $this->createSaleDetail($sale, $item);
        $result = ProductStockService::decrease($company_id, $sale->branch_id, $product->id, $item['quantity']);
        InventoryService::createMovement(
            $company_id,
            $product->id,
            $user_id,
            $sale->branch_id,
            'SALE',
            $item['quantity'],
            $result['before'],
            $result['after'],
            'SALE',
            $sale->id,
            'Salida por venta'
        );
    }

    private function createSaleDetail(Sale $sale, array $item)
    {
        $detail = new SaleDetail();
        $detail->sale_id = $sale->id;
        $detail->product_id = $item['product_id'];
        $detail->quantity = $item['quantity'];
        $detail->sale_price = $item['sale_price'];
        $detail->discount = $item['discount'] ?? 0;
        $detail->subtotal = $item['subtotal'];
        $detail->save();
    }

    private function reverseSaleDetail(Sale $sale, SaleDetail $detail, int $company_id, int $user_id)
    {
        $product = Product::find($detail->product_id);
        if (!$product) {
            throw new \Exception("Producto no encontrado.");
        }

        $stock_before = $product->current_stock;
        $result = ProductStockService::increase($company_id, $sale->branch_id, $detail->product_id, $detail->quantity);
        InventoryService::createMovement(
            $company_id,
            $product->id,
            $user_id,
            $sale->branch_id,
            'ADJUSTMENT_IN',
            $detail->quantity,
            $result['before'],
            $result['after'],
            'SALE_CANCEL',
            $sale->id,
            'Ingreso por cancelación de venta'
        );
    }
}
