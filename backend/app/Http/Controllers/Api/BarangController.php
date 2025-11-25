<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

// --- PERBAIKAN PENTING: IMPORT MODEL ---
use App\Models\BarangModel; 
// ---------------------------------------

class BarangController extends Controller
{
    public function index()
    {
        // Kode index tetap sama
        $barang = BarangModel::with(['kategori', 'user'])->get();
        
        $data = $barang->map(function($item) {
            return [
                'barang_id' => $item->barang_id,
                'barang_nama' => $item->barang_nama,
                'barang_harga' => $item->barang_harga,
                'barang_stok' => $item->barang_stok,
                'barang_foto' => $item->barang_foto,
                'kategori' => $item->kategori->kategori_nama,
                'alamat_penjual' => $item->user ? $item->user->user_alamat : 'Alamat tidak tersedia',
                'penjual_id' => $item->user_id,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function show($id)
    {
        // Kode show tetap sama
        $barang = BarangModel::with('kategori')->find($id);
        if (!$barang) {
            return response()->json(['success' => false, 'message' => 'Barang tidak ditemukan'], 404);
        }
        return response()->json(['success' => true, 'data' => $barang]);
    }

    public function indexUser(Request $request)
    {
        // Kode indexUser tetap sama
        $user = $request->user();

        $barang = BarangModel::with(['kategori'])
                    ->where('user_id', $user->user_id)
                    ->orderBy('created_at', 'desc')
                    ->get();
        
        $data = $barang->map(function($item) {
            return [
                'barang_id' => $item->barang_id,
                'barang_nama' => $item->barang_nama,
                'barang_harga' => $item->barang_harga,
                'barang_stok' => $item->barang_stok,
                'barang_foto' => $item->barang_foto,
                'kategori' => $item->kategori->kategori_nama,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }
}