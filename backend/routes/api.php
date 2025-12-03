<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\Api\KegiatanController;
use App\Http\Controllers\Api\ChannelTransferController;
use App\Http\Controllers\Api\WargaController;
use App\Http\Controllers\Api\KeluargaController;
use App\Http\Controllers\Api\RumahController;
use App\Http\Controllers\Api\MutasiKeluargaController;
use App\Http\Controllers\Api\MutasiWargaController;
use App\Http\Controllers\Api\AspirasiController;
use App\Http\Controllers\Api\ActivityLogController;
use App\Http\Controllers\Api\PesanBroadcastController;
use App\Http\Controllers\Api\PesanWargaController;
use App\Http\Controllers\Api\PenggunaController;
use App\Http\Controllers\Api\RoleController;
use App\Http\Controllers\Api\LaporanKeuanganController;

// --- IMPORT PENTING UNTUK PROXY GAMBAR ---
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;

// === PUBLIC ROUTES ===
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/barang', [BarangController::class, 'index']);
Route::get('/barang/{id}', [BarangController::class, 'show'])->whereNumber('id');

// === PROTECTED ROUTES (BUTUH LOGIN) ===
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Keranjang
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    Route::post('/keranjang', [KeranjangController::class, 'store']);
    Route::put('/keranjang/{id}', [KeranjangController::class, 'update']);
    Route::delete('/keranjang/{id}', [KeranjangController::class, 'destroy']);

    // Barang User (Penjual)
    Route::get('/barang/user', [BarangController::class, 'indexUser']);
    Route::post('/barang', [BarangController::class, 'store']);
    Route::put('/barang/{id}', [BarangController::class, 'update'])->whereNumber('id');
    Route::delete('/barang/{id}', [BarangController::class, 'destroy'])->whereNumber('id');

    // Transaksi
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    
    // Penjual melihat pesanan masuk
    Route::get('/transaksi/masuk', [TransaksiController::class, 'indexMasuk']);
    
    // Update Status (Selesai/Dibatalkan)
    Route::put('/transaksi/{id}/status', [TransaksiController::class, 'updateStatus']);

    // Pembayaran
    Route::post('/pembayaran', [PembayaranController::class, 'store']);

    Route::get('/kegiatan', [KegiatanController::class, 'index']);
    Route::get('/kegiatan/{id}', [KegiatanController::class, 'show']);
    Route::post('/kegiatan', [KegiatanController::class, 'store']);
    Route::put('/kegiatan/{id}', [KegiatanController::class, 'update']);
    Route::delete('/kegiatan/{id}', [KegiatanController::class, 'destroy']);

    // Channel Transfer
    Route::get('/channel-transfer', [ChannelTransferController::class, 'index']);
    Route::get('/channel-transfer/{id}', [ChannelTransferController::class, 'show']);
    Route::post('/channel-transfer', [ChannelTransferController::class, 'store']);
    Route::put('/channel-transfer/{id}', [ChannelTransferController::class, 'update']);
    Route::delete('/channel-transfer/{id}', [ChannelTransferController::class, 'destroy']);

    // Data Warga
    Route::get('/warga', [WargaController::class, 'index']);
    Route::get('/warga/{id}', [WargaController::class, 'show']);
    Route::post('/warga', [WargaController::class, 'store']);
    Route::put('/warga/{id}', [WargaController::class, 'update']);
    Route::delete('/warga/{id}', [WargaController::class, 'destroy']);

    // Data Keluarga
    Route::get('/keluarga', [KeluargaController::class, 'index']);
    Route::get('/keluarga/{id}', [KeluargaController::class, 'show']);
    Route::post('/keluarga', [KeluargaController::class, 'store']);
    Route::put('/keluarga/{id}', [KeluargaController::class, 'update']);
    Route::delete('/keluarga/{id}', [KeluargaController::class, 'destroy']);

    // Data Rumah
    Route::get('/rumah', [RumahController::class, 'index']);
    Route::get('/rumah/{id}', [RumahController::class, 'show']);
    Route::post('/rumah', [RumahController::class, 'store']);
    Route::put('/rumah/{id}', [RumahController::class, 'update']);
    Route::delete('/rumah/{id}', [RumahController::class, 'destroy']);

    // Mutasi Keluarga
    Route::get('/mutasi-keluarga', [MutasiKeluargaController::class, 'index']);
    Route::get('/mutasi-keluarga/{id}', [MutasiKeluargaController::class, 'show']);
    Route::post('/mutasi-keluarga', [MutasiKeluargaController::class, 'store']);
    Route::put('/mutasi-keluarga/{id}', [MutasiKeluargaController::class, 'update']);
    Route::delete('/mutasi-keluarga/{id}', [MutasiKeluargaController::class, 'destroy']);
    Route::put('/mutasi-keluarga/{id}/status', [MutasiKeluargaController::class, 'updateStatus']);

    // Mutasi Warga
    Route::get('/mutasi-warga', [MutasiWargaController::class, 'index']);
    Route::get('/mutasi-warga/{id}', [MutasiWargaController::class, 'show']);
    Route::post('/mutasi-warga', [MutasiWargaController::class, 'store']);
    Route::put('/mutasi-warga/{id}', [MutasiWargaController::class, 'update']);
    Route::delete('/mutasi-warga/{id}', [MutasiWargaController::class, 'destroy']);
    Route::put('/mutasi-warga/{id}/status', [MutasiWargaController::class, 'updateStatus']);

    // Aspirasi
    Route::get('/aspirasi', [AspirasiController::class, 'index']);
    Route::post('/aspirasi', [AspirasiController::class, 'store']);
    Route::get('/aspirasi/{id}', [AspirasiController::class, 'show']);
    Route::post('/aspirasi/{id}/konfirmasi', [AspirasiController::class, 'updateStatus']);

    // Activity Log
    Route::get('/activity-logs/stats', [ActivityLogController::class, 'stats']);
    Route::get('/activity-logs', [ActivityLogController::class, 'index']);
    Route::get('/activity-logs/{id}', [ActivityLogController::class, 'show']);

    // Broadcast
    Route::get('/pesan-broadcast', [PesanBroadcastController::class, 'index']);
    Route::post('/pesan-broadcast', [PesanBroadcastController::class, 'store']);
    Route::put('/pesan-broadcast/{id}', [PesanBroadcastController::class, 'update']);
    Route::delete('/pesan-broadcast/{id}', [PesanBroadcastController::class, 'destroy']);

    // === Pesan Warga ===
    Route::get('/pesan-warga', [PesanWargaController::class, 'index']);
    Route::post('/pesan-warga', [PesanWargaController::class, 'store']);
    Route::get('/pesan-warga/{id}', [PesanWargaController::class, 'show']);
    Route::delete('/pesan-warga/{id}', [PesanWargaController::class, 'destroy']);

    Route::get('/roles', [RoleController::class, 'index']);

    // === Manajemen Pengguna ===
    Route::get('/pengguna', [PenggunaController::class, 'index']);
    Route::post('/pengguna', [PenggunaController::class, 'store']); 
    Route::put('/pengguna/{id}', [PenggunaController::class, 'update']); 
    Route::delete('/pengguna/{id}', [PenggunaController::class, 'destroy']); 
    Route::post('/pengguna/{id}/status', [PenggunaController::class, 'updateStatus']);

    // Log Activity
    // Route::get('/log-activity', [LogActivityController::class, 'index']);
    // Route::get('/log-activity/{id}', [LogActivityController::class, 'show']);
    // Route::get('/log-activity/statistics', [LogActivityController::class, 'statistics']);
    // Route::delete('/log-activity/cleanup', [LogActivityController::class, 'cleanup']);

    // Laporan Keuangan
    Route::get('/pemasukan', [LaporanKeuanganController::class, 'pemasukanIndex']);
    Route::post('/pemasukan', [LaporanKeuanganController::class, 'pemasukanStore']);
    Route::put('/pemasukan/{id}', [LaporanKeuanganController::class, 'pemasukanUpdate']);
    Route::delete('/pemasukan/{id}', [LaporanKeuanganController::class, 'pemasukanDestroy']);

    Route::get('/pengeluaran', [LaporanKeuanganController::class, 'pengeluaranIndex']);
    Route::post('/pengeluaran', [LaporanKeuanganController::class, 'pengeluaranStore']);
    Route::put('/pengeluaran/{id}', [LaporanKeuanganController::class, 'pengeluaranUpdate']);
    Route::delete('/pengeluaran/{id}', [LaporanKeuanganController::class, 'pengeluaranDestroy']);

    Route::get('/laporan/ringkasan', [LaporanKeuanganController::class, 'ringkasan']);
});

// =========================================================================
// SOLUSI PROXY GAMBAR (FINAL & ROBUST)
// Route ini mencari file di semua folder kemungkinan (Public & Storage)
// untuk mengatasi masalah 404 dan CORS sekaligus.
// =========================================================================
Route::get('/image-proxy/{filename}', function ($filename) {
    $path1 = public_path('storage/' . $filename);
    $path2 = public_path($filename);
    $path3 = storage_path('app/public/' . $filename);

    // Variabel penampung path yang valid
    $finalPath = null;
    
    // Logika Pencarian
    if (file_exists($path1)) {
        $finalPath = $path1;
    } elseif (file_exists($path2)) {
        $finalPath = $path2;
    } elseif (file_exists($path3)) {
        $finalPath = $path3;
    } else {
        // Jika file benar-benar tidak ada di ketiga lokasi
        return response()->json([
            'status' => 'error',
            'message' => 'Image not found in any standard location.',
            'checked_paths' => [
                'public_storage' => $path1,
                'public_direct' => $path2,
                'storage_private' => $path3
            ],
            'requested_filename' => $filename
        ], 404);
    }

    // Baca file dan kirimkan sebagai gambar
    $file = file_get_contents($finalPath);
    $type = mime_content_type($finalPath);

    return Response::make($file, 200)->header("Content-Type", $type);

})->where('filename', '.*'); // Regex agar support path dengan garis miring