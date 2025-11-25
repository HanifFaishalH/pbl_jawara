<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\API\AuthController;

Route::post('/login', [AuthController::class, 'login']);
Route::get('/barang', [BarangController::class, 'index']);

// === GROUP AUTH SANCTUM ===
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
    
    // BARU: Update Status (Selesai/Dibatalkan)
    Route::put('/transaksi/{id}/status', [TransaksiController::class, 'updateStatus']);

    // Pembayaran
    Route::post('/pembayaran', [PembayaranController::class, 'store']);
});

Route::get('/barang/{id}', [BarangController::class, 'show']);