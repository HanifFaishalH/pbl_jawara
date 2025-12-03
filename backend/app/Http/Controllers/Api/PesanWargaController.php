<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PesanWargaModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PesanWargaController extends Controller
{
    public function index()
    {
        $userId = Auth::id();

        $pesan = PesanWargaModel::with(['pengirim:user_id,user_nama_depan', 'penerima:user_id,user_nama_depan'])
            ->where('pengirim_id', $userId)
            ->orWhere('penerima_id', $userId)
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['status' => 'success', 'data' => $pesan]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'penerima_id' => 'required|exists:m_user,user_id|different:' . Auth::id(),
            'isi_pesan' => 'required|string|max:500',
        ]);

        $pesan = PesanWargaModel::create([
            'pengirim_id' => Auth::id(),
            'penerima_id' => $request->penerima_id,
            'isi_pesan' => $request->isi_pesan,
        ]);

        return response()->json(['status' => 'success', 'data' => $pesan]);
    }

    public function updateDibaca($id)
    {
        $pesan = PesanWargaModel::findOrFail($id);
        $pesan->update(['dibaca' => true]);

        return response()->json(['status' => 'success']);
    }

    public function getChat($id)
    {
        $userId = Auth::id();

        $pesan = PesanWargaModel::where(function ($q) use ($userId, $id) {
            $q->where('pengirim_id', $userId)->where('penerima_id', $id);
        })->orWhere(function ($q) use ($userId, $id) {
            $q->where('pengirim_id', $id)->where('penerima_id', $userId);
        })
        ->orderBy('created_at', 'asc')
        ->get()
        ->map(function ($p) {
            $p->waktu = $p->created_at->format('H:i');
            return $p;
        });

        return response()->json(['status' => 'success', 'data' => $pesan]);
    }

}
