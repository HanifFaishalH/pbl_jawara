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
        $keranjang = KeranjangModel::with('barang')->where('user_id', $user->user_id)->get();

        return response()->json([
            'success' => true,
            'data' => $keranjang
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'barang_id' => 'required|exists:m_barang,barang_id',
            'jumlah' => 'required|integer|min:1',
        ]);

        $user = $request->user();
        $keranjang = KeranjangModel::create([
            'user_id' => $user->user_id,
            'barang_id' => $request->barang_id,
            'jumlah' => $request->jumlah,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Barang ditambahkan ke keranjang',
            'data' => $keranjang
        ]);
    }
}
