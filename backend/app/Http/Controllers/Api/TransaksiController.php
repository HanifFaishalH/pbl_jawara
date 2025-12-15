<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TransaksiModel;
use App\Models\TransaksiDetailModel;
use App\Models\BarangModel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Helpers\NotifikasiHelper;

class TransaksiController extends Controller
{
    // 1. GET: Riwayat Pesanan Saya (Pembeli)
    public function index(Request $request)
    {
        $user = $request->user();
        
        $transaksi = TransaksiModel::with('detail.barang.user')
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
                'status' => 'menunggu_diambil', 
                'catatan' => $request->catatan, 
                'tanggal_pengambilan' => $request->tanggal_pengambilan,
                'jam_pengambilan' => $request->jam_pengambilan,
            ]);

            foreach ($request->barang as $item) {
                // Lock for Update untuk mencegah Race Condition stok
                $barangDb = BarangModel::lockForUpdate()->find($item['barang_id']);
                
                if (!$barangDb) throw new \Exception("Barang ID {$item['barang_id']} tidak ditemukan.");
                
                    // Validasi: Cek apakah barang milik user sendiri
                    if ($barangDb->user_id === $user->user_id) {
                        throw new \Exception("Tidak bisa membeli barang '{$barangDb->barang_nama}' karena barang tersebut milik Anda sendiri.");
                    }
                
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

            // Kirim notifikasi ke pembeli
            NotifikasiHelper::create(
                userId: $user->user_id,
                judul: 'Pesanan Berhasil',
                pesan: "Pesanan Anda dengan kode {$transaksi->transaksi_kode} berhasil dibuat.",
                tipe: 'success',
                link: '/riwayat-pesanan'
            );

            // Kirim notifikasi ke penjual
            foreach ($request->barang as $item) {
                $barang = BarangModel::find($item['barang_id']);
                if ($barang && $barang->user_id != $user->user_id) {
                    NotifikasiHelper::create(
                        userId: $barang->user_id,
                        judul: 'Pesanan Masuk',
                        pesan: "Anda mendapat pesanan baru untuk {$barang->barang_nama}",
                        tipe: 'info',
                        link: '/pesanan-masuk'
                    );
                }
            }

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
                'transaksi_id' => $detail->transaksi->transaksi_id, 
                'barang_nama'  => $detail->barang->barang_nama, 
                'user_nama'    => $detail->transaksi->user->user_nama_depan ?? 'Pembeli',
                'status'       => $detail->transaksi->status, 
                'tanggal'      => $detail->created_at->format('d M Y'),
                'total_harga'  => $detail->harga * $detail->jumlah,
                'jumlah'       => $detail->jumlah,
            ];
        });

        return response()->json(['success' => true, 'data' => $data]);
    }

    // 4. PUT: Update Status
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:selesai,dibatalkan'
        ]);

        $transaksi = TransaksiModel::with('detail')->find($id);

        if (!$transaksi) {
            return response()->json(['message' => 'Transaksi tidak ditemukan'], 404);
        }

        if (in_array($transaksi->status, ['selesai', 'dibatalkan'])) {
            return response()->json(['message' => 'Transaksi sudah final (selesai/batal)'], 400);
        }

        DB::beginTransaction();
        try {
            // Logika Pengembalian Stok jika Dibatalkan
            if ($request->status == 'dibatalkan') {
                foreach ($transaksi->detail as $detail) {
                    $barang = BarangModel::lockForUpdate()->find($detail->barang_id);
                    if ($barang) {
                        $barang->barang_stok += $detail->jumlah;
                        $barang->save();
                    }
                }
            }

            $transaksi->status = $request->status;
            $transaksi->save();

            DB::commit();
            
            // Kirim notifikasi ke pembeli
            $tipeNotif = $request->status === 'selesai' ? 'success' : 'warning';
            $pesanNotif = $request->status === 'selesai' 
                ? "Pesanan Anda dengan kode {$transaksi->transaksi_kode} telah selesai."
                : "Pesanan Anda dengan kode {$transaksi->transaksi_kode} dibatalkan.";
            
            NotifikasiHelper::create(
                userId: $transaksi->user_id,
                judul: 'Status Pesanan Diperbarui',
                pesan: $pesanNotif,
                tipe: $tipeNotif,
                link: '/riwayat-pesanan'
            );

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