<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PembayaranModel;

class PembayaranController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'transaksi_id' => 'required|exists:t_transaksi,transaksi_id',
            'metode' => 'required|string',
            'jumlah_bayar' => 'required|integer|min:1000',
        ]);

        $bayar = PembayaranModel::create([
            'transaksi_id' => $request->transaksi_id,
            'metode' => $request->metode,
            'jumlah_bayar' => $request->jumlah_bayar,
            'status' => 'sukses',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pembayaran berhasil disimpan',
            'data' => $bayar
        ]);
    }
}
