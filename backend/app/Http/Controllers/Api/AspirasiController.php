<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AspirasiModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AspirasiController extends Controller
{
    public function index()
    {
        $user = Auth::user();
        
        // Load relasi 'user' (pengirim) dan 'penanggap' (pejabat) beserta role-nya
        $query = AspirasiModel::with(['user', 'penanggap.role'])
                    ->orderBy('created_at', 'desc');

        if ($user->role_id == 6) {
            // Warga hanya lihat punya sendiri
            $query->where('user_id', $user->user_id);
        }

        $data = $query->get();
        return response()->json($data);
    }

    public function store(Request $request)
    {
        $user = Auth::user();
        if ($user->role_id != 6) {
            return response()->json(['message' => 'Hanya warga yang boleh mengirim aspirasi'], 403);
        }

        $request->validate([
            'judul' => 'required|string|max:200',
            'deskripsi' => 'required|string',
        ]);

        $aspirasi = AspirasiModel::create([
            'user_id' => $user->user_id,
            'judul' => $request->judul,
            'deskripsi' => $request->deskripsi,
            'status' => 'Pending',
        ]);

        return response()->json(['message' => 'Aspirasi berhasil dikirim', 'data' => $aspirasi], 201);
    }

    public function show($id)
    {
        // Load detail lengkap termasuk siapa yang menanggapi
        $aspirasi = AspirasiModel::with(['user', 'penanggap.role'])->find($id);
        
        if (!$aspirasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);
        return response()->json($aspirasi);
    }

    public function updateStatus(Request $request, $id)
    {
        $user = Auth::user();
        if ($user->role_id == 6) { 
            return response()->json(['message' => 'Anda tidak memiliki akses konfirmasi'], 403);
        }

        $aspirasi = AspirasiModel::find($id);
        if (!$aspirasi) return response()->json(['message' => 'Data tidak ditemukan'], 404);

        $request->validate([
            'status' => 'required|in:Pending,Diterima',
            'tanggapan' => 'nullable|string'
        ]);

        $aspirasi->update([
            'status' => $request->status,
            'tanggapan' => $request->tanggapan,
            'feedback_by' => $user->user_id // <-- SIMPAN ID PEJABAT
        ]);

        return response()->json(['message' => 'Status aspirasi diperbarui', 'data' => $aspirasi]);
    }
}