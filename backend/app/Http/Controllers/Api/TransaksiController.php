<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TransaksiModel;
use App\Models\TransaksiDetailModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Models\BarangModel;

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
        $request->validate([
            'barang' => 'required|array', // List item [{barang_id, jumlah, harga}]
            'total_harga' => 'required|integer',
            'tanggal_pengambilan' => 'required|date',
            'jam_pengambilan' => 'required',
            'catatan' => 'nullable|string'
        ]);

        $user = $request->user();

        DB::beginTransaction();
        try {
            // 1. Buat Header Transaksi
            $transaksi = TransaksiModel::create([
                'user_id' => $user->user_id,
                'transaksi_kode' => 'TRX' . time() . rand(100,999),
                'transaksi_tanggal' => now(),
                'total_harga' => $request->total_harga,
                'status' => 'pending', // Status awal
                // Simpan info tambahan
                'catatan' => $request->catatan, 
                'tanggal_pengambilan' => $request->tanggal_pengambilan,
                'jam_pengambilan' => $request->jam_pengambilan,
            ]);

            // 2. Proses Detail Barang & Kurangi Stok
            foreach ($request->barang as $item) {
                // Ambil data barang di DB untuk cek stok
                $barangDb = BarangModel::lockForUpdate()->find($item['barang_id']);

                if (!$barangDb) {
                    throw new \Exception("Barang ID {$item['barang_id']} tidak ditemukan.");
                }

                if ($barangDb->barang_stok < $item['jumlah']) {
                    throw new \Exception("Stok barang {$barangDb->barang_nama} tidak mencukupi. Sisa: {$barangDb->barang_stok}");
                }

                // Kurangi Stok
                $barangDb->barang_stok -= $item['jumlah'];
                $barangDb->save();

                // Simpan Detail Transaksi
                TransaksiDetailModel::create([
                    'transaksi_id' => $transaksi->transaksi_id,
                    'barang_id' => $item['barang_id'],
                    'harga' => $item['harga'],
                    'jumlah' => $item['jumlah'],
                    'subtotal' => $item['harga'] * $item['jumlah']
                ]);
            }

            DB::commit();
            return response()->json([
                'success' => true, 
                'message' => 'Pesanan berhasil dibuat. Silakan ambil barang sesuai jadwal.',
                'transaksi_kode' => $transaksi->transaksi_kode
            ]);

        } catch (\Throwable $th) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $th->getMessage()], 400);
        }
    }

    public function indexMasuk(Request $request)
    {
        // 1. Ambil ID User yang sedang login (Penjual)
        $userId = $request->user()->user_id;

        // 2. Cari Detail Transaksi dimana barangnya milik User ini
        $transaksiMasuk = TransaksiDetailModel::with(['transaksi.user', 'barang'])
            ->whereHas('barang', function($query) use ($userId) {
                $query->where('user_id', $userId);
            })
            ->orderBy('created_at', 'desc')
            ->get();

        // 3. Format Data sesuai kebutuhan Flutter
        $data = $transaksiMasuk->map(function($detail) {
            return [
                'transaksi_id' => $detail->transaksi->transaksi_id,
                // Nama Barang yang dibeli
                'barang_nama'  => $detail->barang->barang_nama, 
                // Nama Pembeli (User yang membuat transaksi)
                'user_nama'    => $detail->transaksi->user->user_nama_depan . ' ' . $detail->transaksi->user->user_nama_belakang,
                // Status (bisa diambil dari DB atau hardcode dulu)
                'status'       => 'Menunggu Pengambilan', 
                'tanggal'      => $detail->created_at->format('d M Y'),
                'total_harga'  => $detail->harga * $detail->jumlah,
                'jumlah'       => $detail->jumlah,
            ];
        });

        return response()->json([
            'success' => true,
            'data'    => $data
        ]);
    }
}
