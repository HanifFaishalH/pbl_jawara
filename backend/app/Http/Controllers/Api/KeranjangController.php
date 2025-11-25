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

        // PERBAIKAN: Load 'barang.user' untuk mengambil data penjual (alamat)
        $keranjang = KeranjangModel::with(['barang.user'])
            ->where('user_id', $user->user_id)
            ->get();

        // Mapping data agar Frontend lebih mudah membacanya
        $data = $keranjang->map(function($item) {
            // Ambil alamat dari relasi: Keranjang -> Barang -> User (Penjual)
            $alamat = 'Alamat tidak tersedia';
            if ($item->barang && $item->barang->user) {
                $alamat = $item->barang->user->user_alamat;
            }

            return [
                'keranjang_id' => $item->keranjang_id,
                'barang_id'    => $item->barang_id,
                'jumlah'       => $item->jumlah,
                // Data Barang Flattened (Diratakan)
                'barang_nama'  => $item->barang->barang_nama,
                'barang_harga' => $item->barang->barang_harga,
                'barang_foto'  => $item->barang->barang_foto,
                'barang_stok'  => $item->barang->barang_stok,
                // DATA PENTING: Alamat Penjual
                'alamat_penjual' => $alamat,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // ... (Method store, update, destroy biarkan tetap sama seperti kode Anda sebelumnya)
    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:m_barang,barang_id',
            'jumlah' => 'required|integer|min:1',
        ]);

        $user = $request->user();
        $existingItem = KeranjangModel::where('user_id', $user->user_id)
            ->where('barang_id', $request->barang_id)
            ->first();

        if ($existingItem) {
            $existingItem->jumlah += $request->jumlah;
            $existingItem->save();
            $keranjang = $existingItem;
        } else {
            $keranjang = KeranjangModel::create([
                'user_id' => $user->user_id,
                'barang_id' => $request->barang_id,
                'jumlah' => $request->jumlah,
            ]);
        }

        return response()->json(['success' => true, 'message' => 'Sukses', 'data' => $keranjang]);
    }

    public function update(Request $request, $id)
    {
        $request->validate(['jumlah' => 'required|integer|min:1']);
        $user = $request->user();
        $item = KeranjangModel::where('keranjang_id', $id)->where('user_id', $user->user_id)->first();

        if (!$item) return response()->json(['success' => false, 'message' => 'Not found'], 404);

        $item->jumlah = $request->jumlah;
        $item->save();
        return response()->json(['success' => true]);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $item = KeranjangModel::where('keranjang_id', $id)->where('user_id', $user->user_id)->first();
        if ($item) {
            $item->delete();
            return response()->json(['success' => true]);
        }
        return response()->json(['success' => false], 404);
    }
}