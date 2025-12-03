<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActivityLog;
use Illuminate\Http\Request;

class ActivityLogController extends Controller
{
    public function index(Request $request)
    {
        $query = ActivityLog::with('user:user_id,user_nama_depan,user_nama_belakang,email')
            ->orderBy('created_at', 'desc');

        if ($request->has('type') && $request->type !== 'semua') {
            $query->where('log_type', $request->type);
        }

        if ($request->has('action') && $request->action !== 'semua') {
            $query->where('log_action', $request->action);
        }

        if ($request->has('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        if ($request->has('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('log_description', 'like', "%{$search}%")
                  ->orWhereHas('user', function ($q) use ($search) {
                      $q->where('user_nama_depan', 'like', "%{$search}%")
                        ->orWhere('user_nama_belakang', 'like', "%{$search}%");
                  });
            });
        }

        $logs = $query->paginate($request->get('per_page', 20));

        return response()->json($logs);
    }

    public function show($id)
    {
        $log = ActivityLog::with('user:user_id,user_nama_depan,user_nama_belakang,email')
            ->findOrFail($id);

        return response()->json($log);
    }

    public function stats()
    {
        $today = ActivityLog::whereDate('created_at', today())->count();
        $thisWeek = ActivityLog::whereBetween('created_at', [
            now()->startOfWeek(),
            now()->endOfWeek()
        ])->count();
        $thisMonth = ActivityLog::whereMonth('created_at', now()->month)
            ->whereYear('created_at', now()->year)
            ->count();

        $byType = ActivityLog::selectRaw('log_type, count(*) as count')
            ->groupBy('log_type')
            ->get();

        $byAction = ActivityLog::selectRaw('log_action, count(*) as count')
            ->groupBy('log_action')
            ->get();

        return response()->json([
            'today' => $today,
            'this_week' => $thisWeek,
            'this_month' => $thisMonth,
            'by_type' => $byType,
            'by_action' => $byAction,
        ]);
    }
}
