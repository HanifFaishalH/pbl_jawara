<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\PembayaranController;
use App\Http\Controllers\API\AuthController;

// Login tidak butuh token
Route::post('/login', [AuthController::class, 'login']);

// Barang publik (List Semua)
Route::get('/barang', [BarangController::class, 'index']);

// === GROUP ROUTE YANG WAJIB LOGIN (Butuh Token) ===
Route::middleware('auth:sanctum')->group(function () {
    // Auth User
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Keranjang
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    Route::post('/keranjang', [KeranjangController::class, 'store']);
    Route::put('/keranjang/{id}', [KeranjangController::class, 'update']);
    Route::delete('/keranjang/{id}', [KeranjangController::class, 'destroy']);

    // --- POSISI INI AMAN (Specific Route) ---
    // Route ini harus didaftarkan SEBELUM '/barang/{id}'
    Route::get('/barang/user', [BarangController::class, 'indexUser']);

    // Transaksi
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    Route::get('/transaksi/masuk', [TransaksiController::class, 'indexMasuk']);

    // Pembayaran
    Route::post('/pembayaran', [PembayaranController::class, 'store']);
});

// === ROUTE WILDCARD / DINAMIS (Taruh Paling Bawah) ===
// Pindahkan ini ke sini agar tidak "memakan" route /barang/user
Route::get('/barang/{id}', [BarangController::class, 'show']);