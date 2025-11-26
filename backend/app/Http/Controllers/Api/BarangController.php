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
        // Eager load 'user' untuk mengambil data penjual
        $barang = BarangModel::with(['kategori', 'user'])->get();
        
        $data = $barang->map(function($item) {
            // Logika pengambilan nama user
            $namaPenjual = 'Penjual Jawara';
            if ($item->user) {
                $namaPenjual = trim(($item->user->user_nama_depan ?? '') . ' ' . ($item->user->user_nama_belakang ?? ''));
                if (empty($namaPenjual)) $namaPenjual = "User #" . $item->user->user_id;
            }

            return [
                'barang_id' => $item->barang_id,
                'barang_nama' => $item->barang_nama,
                'barang_harga' => $item->barang_harga,
                'barang_stok' => $item->barang_stok,
                'barang_foto' => $item->barang_foto,
                'kategori' => $item->kategori->kategori_nama,
                'alamat_penjual' => $item->user ? $item->user->user_alamat : 'Alamat tidak tersedia',
                // Tambahkan ini:
                'nama_penjual' => $namaPenjual, 
                'penjual_id' => $item->user_id,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    public function show($id)
    {
        $barang = BarangModel::with(['kategori', 'user'])->find($id);
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