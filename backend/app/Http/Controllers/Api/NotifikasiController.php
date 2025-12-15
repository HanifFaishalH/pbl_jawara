<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;
use Illuminate\Http\Request;

class NotifikasiController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        
        $query = Notifikasi::where('user_id', $user->user_id)
            ->orderBy('created_at', 'desc');

        if ($request->has('is_read')) {
            $query->where('is_read', $request->is_read);
        }

        $notifikasi = $query->paginate($request->get('per_page', 20));

        return response()->json($notifikasi);
    }

    public function unreadCount(Request $request)
    {
        $user = $request->user();
        
        $count = Notifikasi::where('user_id', $user->user_id)
            ->where('is_read', false)
            ->count();

        return response()->json(['unread_count' => $count]);
    }

    public function markAsRead($id, Request $request)
    {
        $user = $request->user();
        
        $notifikasi = Notifikasi::where('notifikasi_id', $id)
            ->where('user_id', $user->user_id)
            ->firstOrFail();

        $notifikasi->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai sebagai sudah dibaca',
        ]);
    }

    public function markAllAsRead(Request $request)
    {
        $user = $request->user();
        
        Notifikasi::where('user_id', $user->user_id)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai sebagai sudah dibaca',
        ]);
    }

    public function delete($id, Request $request)
    {
        $user = $request->user();
        
        $notifikasi = Notifikasi::where('notifikasi_id', $id)
            ->where('user_id', $user->user_id)
            ->firstOrFail();

        $notifikasi->delete();

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi berhasil dihapus',
        ]);
    }
}
