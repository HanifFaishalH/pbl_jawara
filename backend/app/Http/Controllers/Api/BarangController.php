<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BarangModel;
use Illuminate\Http\Request;

class BarangController extends Controller
{
    public function index()
    {
        $barang = BarangModel::with('kategori')->get();
        return response()->json([
            'success' => true,
            'message' => 'Daftar Barang',
            'data' => $barang
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Route berhasil dipanggil!',
            'data' => []
        ]);
    }

    public function show($id)
    {
        $barang = BarangModel::with('kategori')->find($id);
        if (!$barang) {
            return response()->json(['success' => false, 'message' => 'Barang tidak ditemukan'], 404);
        }
        return response()->json(['success' => true, 'data' => $barang]);
    }
}
