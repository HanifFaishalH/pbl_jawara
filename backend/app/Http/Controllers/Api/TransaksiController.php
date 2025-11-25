<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TransaksiModel;
use App\Models\TransaksiDetailModel;
use App\Models\BarangModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    // 1. GET: Riwayat Pesanan Saya (Pembeli)
    public function index(Request $request)
    {
        $user = $request->user();
        // Urutkan dari yang terbaru
        $transaksi = TransaksiModel::with('detail.barang')
            ->where('user_id', $user->user_id)
            ->orderBy('created_at', 'desc') 
            ->get();

        return response()->json(['success' => true, 'data' => $transaksi]);
    }

    // 2. POST: Buat Pesanan Baru
    public function store(Request $request)
    {
        $request->validate([
            'barang' => 'required|array',
            'total_harga' => 'required|integer',
            'tanggal_pengambilan' => 'required|date',
            'jam_pengambilan' => 'required',
            'catatan' => 'nullable|string'
        ]);

        $user = $request->user();

        DB::beginTransaction();
        try {
            $transaksi = TransaksiModel::create([
                'user_id' => $user->user_id,
                'transaksi_kode' => 'TRX' . time() . rand(100,999),
                'transaksi_tanggal' => now(),
                'total_harga' => $request->total_harga,
                'status' => 'menunggu_diambil', // Status Default
                'catatan' => $request->catatan, 
                'tanggal_pengambilan' => $request->tanggal_pengambilan,
                'jam_pengambilan' => $request->jam_pengambilan,
            ]);

            foreach ($request->barang as $item) {
                $barangDb = BarangModel::lockForUpdate()->find($item['barang_id']);
                
                if (!$barangDb) throw new \Exception("Barang ID {$item['barang_id']} tidak ditemukan.");
                if ($barangDb->barang_stok < $item['jumlah']) {
                    throw new \Exception("Stok {$barangDb->barang_nama} habis.");
                }

                // Kurangi Stok
                $barangDb->barang_stok -= $item['jumlah'];
                $barangDb->save();

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
                'message' => 'Pesanan berhasil dibuat.',
                'transaksi_kode' => $transaksi->transaksi_kode
            ]);

        } catch (\Throwable $th) {
            DB::rollBack();
            return response()->json(['success' => false, 'message' => $th->getMessage()], 400);
        }
    }

    // 3. GET: Pesanan Masuk (Untuk Penjual)
    public function indexMasuk(Request $request)
    {
        $userId = $request->user()->user_id;

        $transaksiMasuk = TransaksiDetailModel::with(['transaksi.user', 'barang'])
            ->whereHas('barang', function($query) use ($userId) {
                $query->where('user_id', $userId);
            })
            ->orderBy('created_at', 'desc')
            ->get();

        $data = $transaksiMasuk->map(function($detail) {
            return [
                // PENTING: ID Transaksi diperlukan untuk tombol update
                'transaksi_id' => $detail->transaksi->transaksi_id, 
                'barang_nama'  => $detail->barang->barang_nama, 
                'user_nama'    => $detail->transaksi->user->user_nama_depan ?? 'Pembeli',
                // Ambil status dari tabel transaksi header
                'status'       => $detail->transaksi->status, 
                'tanggal'      => $detail->created_at->format('d M Y'),
                'total_harga'  => $detail->harga * $detail->jumlah,
                'jumlah'       => $detail->jumlah,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    // 4. PUT: Update Status (Selesai / Dibatalkan) & Logika Stok
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:selesai,dibatalkan'
        ]);

        $transaksi = TransaksiModel::with('detail')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        // Cegah perubahan jika sudah final
        if (in_array($transaksi->status, ['selesai', 'dibatalkan'])) {
            return response()->json(['message' => 'Transaksi sudah final (selesai/batal)'], 400);
        }

        DB::beginTransaction();
        try {
            // Jika status menjadi 'dibatalkan', KEMBALIKAN STOK
            if ($request->status == 'dibatalkan') {
                foreach ($transaksi->detail as $detail) {
                    $barang = BarangModel::lockForUpdate()->find($detail->barang_id);
                    if ($barang) {
                        $barang->barang_stok += $detail->jumlah;
                        $barang->save();
                    }
                }
            }

            // Update status
            $transaksi->status = $request->status;
            $transaksi->save();

            DB::commit();
            return response()->json([
                'success' => true,
                'message' => 'Status berhasil diubah menjadi ' . $request->status
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => $e->getMessage()], 500);
        }
    }
}