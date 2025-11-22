<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TransaksiModel;
use App\Models\TransaksiDetailModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $transaksi = TransaksiModel::with('detail.barang')
            ->where('user_id', $user->user_id)
            ->get();

        return response()->json(['success' => true, 'data' => $transaksi]);
    }

    public function store(Request $request)
    {
        $user = $request->user();

        DB::beginTransaction();
        try {
            $transaksi = TransaksiModel::create([
                'user_id' => $user->user_id,
                'transaksi_kode' => 'TRX' . time(),
                'transaksi_tanggal' => now(),
                'total_harga' => $request->total_harga,
                'status' => 'pending'
            ]);

            foreach ($request->barang as $item) {
                TransaksiDetailModel::create([
                    'transaksi_id' => $transaksi->transaksi_id,
                    'barang_id' => $item['barang_id'],
                    'harga' => $item['harga'],
                    'jumlah' => $item['jumlah'],
                    'subtotal' => $item['subtotal']
                ]);
            }

            DB::commit();
            return response()->json(['success' => true, 'message' => 'Transaksi berhasil dibuat']);
        } catch (\Throwable $th) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $th->getMessage()], 500);
        }
    }
}
