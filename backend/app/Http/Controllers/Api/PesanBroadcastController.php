<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PesanBroadcastModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class PesanBroadcastController extends Controller
{
    public function index()
    {
        $pesan = PesanBroadcastModel::with('admin:user_id,user_nama_depan')
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['status' => 'success', 'data' => $pesan]);
    }

    public function store(Request $request)
    {
        $user = Auth::user();

        if ($user->role_id != 1) {
            return response()->json(['status' => 'error', 'message' => 'Hanya admin yang dapat mengirim broadcast.'], 403);
        }

        $request->validate([
            'judul' => 'required|string|max:100',
            'isi_pesan' => 'required|string',
        ]);

        $broadcast = PesanBroadcastModel::create([
            'admin_id' => $user->user_id,
            'judul' => $request->judul,
            'isi_pesan' => $request->isi_pesan,
        ]);

        return response()->json(['status' => 'success', 'data' => $broadcast]);
    }

    public function update(Request $request, $id)
    {
        $user = Auth::user();

        if ($user->role_id != 1) {
            return response()->json(['status' => 'error', 'message' => 'Hanya admin yang dapat mengedit broadcast.'], 403);
        }

        $request->validate([
            'judul' => 'required|string|max:100',
            'isi_pesan' => 'required|string',
        ]);

        $broadcast = PesanBroadcastModel::findOrFail($id);

        $broadcast->update([
            'judul' => $request->judul,
            'isi_pesan' => $request->isi_pesan,
        ]);

        if ($request->hasFile('foto')) {
            $path = $request->file('foto')->store('broadcast_foto', 'public');
            $broadcast->foto = $path;
        }

        if ($request->hasFile('dokumen')) {
            $path = $request->file('dokumen')->store('broadcast_dokumen', 'public');
            $broadcast->dokumen = $path;
        }

        $broadcast->save();

        return response()->json(['status' => 'success', 'data' => $broadcast]);
    }

    public function destroy($id)
    {
        $user = Auth::user();

        if ($user->role_id != 1) {
            return response()->json(['status' => 'error', 'message' => 'Hanya admin yang dapat menghapus broadcast.'], 403);
        }

        PesanBroadcastModel::destroy($id);

        return response()->json(['status' => 'success', 'message' => 'Broadcast berhasil dihapus.']);
    }
}
