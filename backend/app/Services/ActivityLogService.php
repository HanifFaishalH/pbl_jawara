<?php

namespace App\Services;

use App\Models\ActivityLog;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class ActivityLogService
{
    public static function log(
        string $type,
        string $action,
        string $description,
        ?int $referenceId = null,
        ?array $oldData = null,
        ?array $newData = null,
        ?Request $request = null
    ) {
        try {
            $request = $request ?? request();
            
            ActivityLog::create([
                'user_id' => Auth::id(),
                'log_type' => $type,
                'log_action' => $action,
                'log_reference_id' => $referenceId,
                'log_description' => $description,
                'log_old_data' => $oldData,
                'log_new_data' => $newData,
                'log_ip_address' => $request->ip(),
                'log_user_agent' => $request->userAgent(),
            ]);
        } catch (\Exception $e) {
            \Log::error('Failed to create activity log: ' . $e->getMessage());
        }
    }
}
