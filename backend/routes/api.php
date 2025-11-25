<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\API\AuthController;

// --- IMPORT PENTING UNTUK PROXY GAMBAR ---
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Response;

// === PUBLIC ROUTES ===
Route::post('/login', [AuthController::class, 'login']);
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

    // Transaksi
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    
    // Penjual melihat pesanan masuk
    Route::get('/transaksi/masuk', [TransaksiController::class, 'indexMasuk']);
    
    // Update Status (Selesai/Dibatalkan)
    Route::put('/transaksi/{id}/status', [TransaksiController::class, 'updateStatus']);

    // Pembayaran
    Route::post('/pembayaran', [PembayaranController::class, 'store']);
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