<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\KeranjangModel;

class KeranjangController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $keranjang = KeranjangModel::with('barang')
            ->where('user_id', $user->user_id)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $keranjang
        ]);
    }

    // UPDATE: LOGIKA MERGE (GABUNG JUMLAH)
    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:m_barang,barang_id',
            'jumlah' => 'required|integer|min:1',
        ]);

        $user = $request->user();

        // Cek apakah barang ini sudah ada di keranjang user?
        $existingItem = KeranjangModel::where('user_id', $user->user_id)
            ->where('barang_id', $request->barang_id)
            ->first();

        if ($existingItem) {
            // Jika ada, update jumlahnya saja (Jumlah Lama + Jumlah Baru)
            $existingItem->jumlah += $request->jumlah;
            $existingItem->save();
            $keranjang = $existingItem;
        } else {
            // Jika belum ada, buat baru
            $keranjang = KeranjangModel::create([
                'user_id' => $user->user_id,
                'barang_id' => $request->barang_id,
                'jumlah' => $request->jumlah,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Barang berhasil masuk keranjang',
            'data' => $keranjang
        ]);
    }

    // UPDATE: UBAH JUMLAH (+ / -) LANGSUNG DARI KERANJANG
    public function update(Request $request, $id)
    {
        $request->validate([
            'jumlah' => 'required|integer|min:1'
        ]);

        $user = $request->user();
        
        // Pastikan keranjang milik user yang login
        $item = KeranjangModel::where('keranjang_id', $id)
                ->where('user_id', $user->user_id)
                ->first();

        if (!$item) {
            return response()->json(['success' => false, 'message' => 'Item tidak ditemukan'], 404);
        }

        $item->jumlah = $request->jumlah;
        $item->save();

        return response()->json([
            'success' => true,
            'message' => 'Jumlah berhasil diupdate'
        ]);
    }

    // HAPUS ITEM
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $item = KeranjangModel::where('keranjang_id', $id)->where('user_id', $user->user_id)->first();

        if ($item) {
            $item->delete();
            return response()->json(['success' => true, 'message' => 'Item dihapus']);
        }
        return response()->json(['success' => false, 'message' => 'Gagal menghapus'], 404);
    }
}
