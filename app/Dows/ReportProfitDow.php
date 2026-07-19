<?php

namespace App\Dows;

use App\Middlewares\Application;
use App\Models\SaleDetail;
use App\Utilities\FG;
use Carbon\Carbon;

class ReportProfitDow
{

    public function index($request)
    {
        $response = FG::responseDefault();

        try {
            $input = $request->getParsedBody();
            $companyId = (int)Application::getItem('company_id');

            $dateStart = !empty($input['date_start']) ? $input['date_start'] : Carbon::now()->startOfMonth()->format('Y-m-d');
            $dateEnd = !empty($input['date_end']) ? $input['date_end'] : Carbon::now()->format('Y-m-d');

            $this->validateDateRange($dateStart, $dateEnd);

            $filters = [
                'branch_id' => !empty($input['branch_id']) ? (int)$input['branch_id'] : null,
                'product_id' => !empty($input['product_id']) ? (int)$input['product_id'] : null,
                'category_id' => !empty($input['category_id']) ? (int)$input['category_id'] : null,
                'date_start' => $dateStart,
                'date_end' => $dateEnd
            ];

            $periods = $this->getCurrentPeriods();

            $response['success'] = true;
            $response['data'] = [
                'summary' => [
                    'today' => $this->getProfitSummary($companyId, $periods['today']['start'], $periods['today']['end'], $filters),
                    'week' => $this->getProfitSummary($companyId, $periods['week']['start'], $periods['week']['end'], $filters),
                    'fortnight' => $this->getProfitSummary($companyId, $periods['fortnight']['start'], $periods['fortnight']['end'], $filters),
                    'month' => $this->getProfitSummary($companyId, $periods['month']['start'], $periods['month']['end'], $filters),
                    'year' => $this->getProfitSummary($companyId, $periods['year']['start'], $periods['year']['end'], $filters),
                    'custom_range' => $this->getProfitSummary($companyId, Carbon::parse($dateStart)->startOfDay(), Carbon::parse($dateEnd)->endOfDay(), $filters)
                ],
                'periods' => array_merge(
                    $this->formatPeriods($periods),
                    ['custom_range' => ['date_start' => $dateStart, 'date_end' => $dateEnd]]
                ),
                'filters' => $filters
            ];

            $response['message'] = 'Reporte de ganancias obtenido correctamente.';
        } catch (\Throwable $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }

        return $response;
    }

    private function getCurrentPeriods(): array
    {
        $now = Carbon::now();

        $todayStart = $now->copy()->startOfDay();
        $todayEnd = $now->copy()->endOfDay();

        $weekStart = $now->copy()->startOfWeek(Carbon::MONDAY)->startOfDay();
        $weekEnd = $now->copy()->endOfWeek(Carbon::SUNDAY)->endOfDay();

        if ($now->day <= 15) {
            $fortnightStart = $now->copy()->startOfMonth()->startOfDay();
            $fortnightEnd = $now->copy()->day(15)->endOfDay();
        } else {
            $fortnightStart = $now->copy()->day(16)->startOfDay();
            $fortnightEnd = $now->copy()->endOfMonth()->endOfDay();
        }

        $monthStart = $now->copy()->startOfMonth()->startOfDay();
        $monthEnd = $now->copy()->endOfMonth()->endOfDay();

        $yearStart = $now->copy()->startOfYear()->startOfDay();
        $yearEnd = $now->copy()->endOfYear()->endOfDay();

        return [
            'today' => ['start' => $todayStart, 'end' => $todayEnd],
            'week' => ['start' => $weekStart, 'end' => $weekEnd],
            'fortnight' => ['start' => $fortnightStart, 'end' => $fortnightEnd],
            'month' => ['start' => $monthStart, 'end' => $monthEnd],
            'year' => ['start' => $yearStart, 'end' => $yearEnd]
        ];
    }

    private function getBaseProfitQuery(int $companyId)
    {
        return SaleDetail::query()
            ->join('sales as s', 's.id', '=', 'sale_details.sale_id')
            ->join('products as p', 'p.id', '=', 'sale_details.product_id')
            ->where('s.company_id', $companyId)
            ->where('s.status', 'COMPLETED')
            ->whereNull('s.deleted_at')
            ->whereNull('sale_details.deleted_at');
    }

    private function applyProfitFilters($query, array $filters)
    {
        if (!empty($filters['branch_id'])) {
            $query->where('s.branch_id', $filters['branch_id']);
        }

        if (!empty($filters['product_id'])) {
            $query->where('sale_details.product_id', $filters['product_id']);
        }

        if (!empty($filters['category_id'])) {
            $query->where('p.category_id', $filters['category_id']);
        }
        return $query;
    }

    private function getProfitSummary(int $companyId, Carbon $dateStart, Carbon $dateEnd, array $filters): array
    {
        $query = $this->getBaseProfitQuery($companyId);

        $query->whereBetween('s.sale_date', [
            $dateStart->format('Y-m-d H:i:s'),
            $dateEnd->format('Y-m-d H:i:s')
        ]);

        $this->applyProfitFilters($query, $filters);

        $result = $query
            ->selectRaw('
            COUNT(DISTINCT s.id) AS total_sales,
            COALESCE(SUM(sale_details.quantity), 0) AS products_sold,
            COALESCE(SUM(sale_details.subtotal), 0) AS total_revenue,
            COALESCE(SUM(sale_details.total_cost), 0) AS total_cost,
            COALESCE(SUM(sale_details.profit), 0) AS gross_profit')->first();
        return $this->formatProfitSummary($result);
    }

    private function formatProfitSummary($result): array
    {
        $totalRevenue = round((float)($result->total_revenue ?? 0), 2);
        $totalCost = round((float)($result->total_cost ?? 0), 2);
        $grossProfit = round((float)($result->gross_profit ?? 0), 2);
        $profitMargin = $totalRevenue > 0 ? round(($grossProfit / $totalRevenue) * 100, 2) : 0;

        return [
            'total_sales' => (int)($result->total_sales ?? 0),
            'products_sold' => round((float)($result->products_sold ?? 0), 2),
            'total_revenue' => $totalRevenue,
            'total_cost' => $totalCost,
            'gross_profit' => $grossProfit,
            'profit_margin' => $profitMargin
        ];
    }

    private function formatPeriods(array $periods): array
    {
        $formatted = [];
        foreach ($periods as $key => $period) {
            $formatted[$key] = [
                'date_start' => $period['start']->format('Y-m-d'),
                'date_end' => $period['end']->format('Y-m-d')
            ];
        }
        return $formatted;
    }

    private function validateDateRange(string $dateStart, string $dateEnd): void
    {
        try {
            $start = Carbon::createFromFormat('Y-m-d', $dateStart)->startOfDay();
            $end = Carbon::createFromFormat('Y-m-d', $dateEnd)->endOfDay();
        } catch (\Throwable $e) {
            throw new \Exception('Las fechas deben tener el formato YYYY-MM-DD.');
        }

        if ($start->greaterThan($end)) {
            throw new \Exception('La fecha inicial no puede ser mayor que la fecha final.');
        }

        if ($start->diffInYears($end) > 5) {
            throw new \Exception('El rango seleccionado no puede superar los 5 años.');
        }
    }
}
