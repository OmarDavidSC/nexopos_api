<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\InventoryMovements;
use App\Models\Product;
use App\Models\Purchase;
use App\Models\PurchaseDetail;
use App\Services\InventoryService;
use Illuminate\Database\Capsule\Manager as DB;
use App\Utilities\FG;

class PurchaseDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {

            $input = $request->getParsedBody();
            $company_id = Application::getItem('company_id');

            $page = isset($input['page']) ? (int)$input['page'] : 1;
            $perPage = 10;

            $search = trim($input['search'] ?? '');
            $supplier_id = isset($input['supplier_id']) ? (int)$input['supplier_id'] : null;
            $status = $input['status'] ?? '';

            $query = Purchase::with(['supplier:id, business_name'])
                ->where('company_id', $company_id)
                ->whereNull('deleted_at');

            //buscar por documento
            if (!empty($search)) {
                $query->where(function ($q) use ($search) {
                    $q->where('document_number', 'LIKE', "%{$search}%")
                        ->orWhere('document_type', 'LIKE', "%{$search}%");
                });
            }

            //filtro por proveedor
            if (!empty($supplier_id)) {
                $query->where('supplier_id', $supplier_id);
            }

            if ($status !== '') {
                $query->where('status', $status);
            }

            $query->orderBy('id', 'desc');
            $total = $query->count();

            $purchases = $query
                ->skip(($page - 1) * $perPage)
                ->take($perPage)
                ->get();

            $data = $purchases->map(function ($item) {

                return [
                    'id' => $item->id,
                    'supplier_id' => $item->supplier_id,
                    'supplier' => $item->supplier?->business_name,
                    'document_type' => $item->document_type,
                    'document_number' => $item->document_number,
                    'purchase_date' => $item->purchase_date,
                    'subtotal' => $item->subtotal,
                    'tax' => $item->tax,
                    'total' => $item->total,
                    'status' => $item->status,
                    'status_label' => $item->status,
                    'datecreated_label' => FG::formatDateTimeHuman($item->created_at),
                    'dateupdated_label' => FG::formatDateTimeHuman($item->updated_at),

                ];
            });

            $summary  = $this->getSummary($company_id);

            $response['success'] = true;
            $response['data'] = [
                'page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'total_pages' => ceil($total / $perPage),
                'data' => $data,
                'summary' => $summary,
            ];
            $response['message'] = 'successully';
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
            $user_id = Application::getItem('user_id');

            $this->validateStore($input);
            $purchase = $this->createPurchase($input, $company_id, $user_id);
            $details = json_decode($input['details'], true);
            foreach ($details as $detail) {
                $this->processPurchaseDetail($purchase, $detail, $company_id, $user_id);
            }

            DB::commit();
            $response['success'] = true;
            $response['data'] = $purchase;
            $response['message'] = 'Compra registrada correctamente.';
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
            $purchase = Purchase::with([
                'supplier:id,business_name',
                'details.product:id,code,name'
            ])
                ->where('company_id', $company_id)
                ->where('id', $id)
                ->whereNull('deleted_at')
                ->first();

            if (!$purchase) {
                $response['success'] = false;
                $response['message'] = 'La compra no fue encontrada.';
                return $response;
            }

            $response['success'] = true;
            $response['data'] = [
                'purchase' => [
                    'id' => $purchase->id,
                    'supplier_id' => $purchase->supplier_id,
                    'supplier' => $purchase->supplier?->business_name,
                    'purchase_date' => $purchase->purchase_date,
                    'voucher_type' => $purchase->voucher_type,
                    'voucher_series' => $purchase->voucher_series,
                    'voucher_number' => $purchase->voucher_number,
                    'subtotal' => $purchase->subtotal,
                    'tax' => $purchase->tax,
                    'discount' => $purchase->discount,
                    'total' => $purchase->total,
                    'observation' => $purchase->observation,
                    'status' => $purchase->status,
                    'created_at' => FG::formatDateTimeHuman($purchase->created_at)
                ],
                'details' => $purchase->details->map(function ($item) {
                    return [
                        'id' => $item->id,
                        'product_id' => $item->product_id,
                        'code' => $item->product?->code,
                        'product' => $item->product?->name,
                        'quantity' => $item->quantity,
                        'unit_cost' => $item->unit_cost,
                        'discount' => $item->discount,
                        'tax' => $item->tax,
                        'subtotal' => $item->subtotal,
                        'total' => $item->total
                    ];
                })

            ];

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
            $user_id = Application::getItem('user_id');

            $purchase = Purchase::with('details')
                ->where('company_id', $company_id)
                ->where('id', $id)
                ->whereNull('deleted_at')
                ->first();

            if (!$purchase) {
                throw new \Exception("La compra no fue encontrada.");
            }

            if ($purchase->status == 'CANCELLED') {
                throw new \Exception("La compra ya fue cancelada.");
            }

            foreach ($purchase->details as $detail) {
                $this->reversePurchaseDetail($purchase, $detail, $company_id, $user_id);
            }

            $purchase->status = 'CANCELLED';
            $purchase->save();

            DB::commit();
            $response['success'] = true;
            $response['data'] = $purchase;
            $response['message'] = 'Compra cancelada correctamente.';
        } catch (\Exception $e) {
            DB::rollBack();
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return $response;
    }

    private function getSummary($company_id)
    {
        return [
            'total_purchases' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->count(),

            'completed' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->where('status', 'COMPLETED')
                ->count(),

            'pending' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->where('status', 'PENDING')
                ->count(),

            'cancelled' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->where('status', 'CANCELLED')
                ->count(),

            'total_amount' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->where('status', 'COMPLETED')
                ->sum('total'),

            'this_month_amount' => Purchase::where('company_id', $company_id)
                ->whereNull('deleted_at')
                ->where('status', 'COMPLETED')
                ->whereMonth('purchase_date', date('m'))
                ->whereYear('purchase_date', date('Y'))
                ->sum('total'),
        ];
    }

    private function validateStore($input)
    {
        if (empty($input['supplier_id'])) {
            throw new \Exception("Seleccione un proveedor.");
        }

        if (empty($input['purchase_date'])) {
            throw new \Exception("Seleccione la fecha de compra.");
        }

        if (empty($input['details'])) {
            throw new \Exception("Debe agregar productos.");
        }

        $details = json_decode($input['details'], true);

        if (!is_array($details) || count($details) == 0) {
            throw new \Exception("Debe agregar al menos un producto.");
        }
    }

    private function createPurchase($input, $company_id, $user_id)
    {
        $purchase = new Purchase();
        $purchase->company_id = $company_id;
        $purchase->supplier_id = $input['supplier_id'];
        $purchase->user_id = $user_id;
        $purchase->purchase_date = $input['purchase_date'];
        $purchase->voucher_type = $input['voucher_type'];
        $purchase->voucher_series = $input['voucher_series'];
        $purchase->voucher_number = $input['voucher_number'];
        $purchase->subtotal = $input['subtotal'];
        $purchase->tax = $input['tax'];
        $purchase->discount = $input['discount'];
        $purchase->total = $input['total'];
        $purchase->observation = $input['observation'];
        $purchase->status = 'COMPLETED';
        $purchase->save();
        return $purchase;
    }

    private function processPurchaseDetail(Purchase $purchase, array $item, int $company_id, int $user_id)
    {

        $product = Product::find($item['product_id']);
        if (!$product) {
            throw new \Exception("Producto no encontrado.");
        }

        $stock_before = $product->current_stock;
        $this->createPurchaseDetail($purchase, $item);
        $this->updateProductStock($product, $item['quantity']);
        InventoryService::createMovement(
            $company_id,
            $product->id,
            $user_id,
            'PURCHASE',
            $item['quantity'],
            $stock_before,
            $product->current_stock,
            'PURCHASE',
            $purchase->id,
            'Ingreso por compra'
        );
    }

    private function createPurchaseDetail(Purchase $purchase, array $item)
    {

        $detail = new PurchaseDetail();
        $detail->purchase_id = $purchase->id;
        $detail->product_id = $item['product_id'];
        $detail->quantity = $item['quantity'];
        $detail->unit_cost = $item['unit_cost'];
        $detail->discount = $item['discount'];
        $detail->tax = $item['tax'];
        $detail->subtotal = $item['subtotal'];
        $detail->total = $item['total'];
        $detail->save();
    }

    private function updateProductStock(Product $product, $quantity)
    {
        $product->current_stock += $quantity;
        $product->save();
    }

    private function reversePurchaseDetail(Purchase $purchase, PurchaseDetail $detail, int $company_id, int $user_id)
    {

        $product = Product::find($detail->product_id);
        if (!$product) {
            throw new \Exception("Producto no encontrado.");
        }

        $stock_before = $product->current_stock;
        if ($stock_before < $detail->quantity) {
            throw new \Exception(
                "No es posible cancelar la compra porque el producto '{$product->name}' ya no tiene suficiente stock."
            );
        }

        $product->current_stock -= $detail->quantity;
        $product->save();

        InventoryService::createMovement(
            $company_id,
            $product->id,
            $user_id,
            'ADJUSTMENT',
            $detail->quantity,
            $stock_before,
            $product->current_stock,
            'PURCHASE_CANCEL',
            $purchase->id,
            'Salida por cancelación de compra'
        );
    }
}
