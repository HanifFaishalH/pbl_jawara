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

// Barang publik (bisa dilihat tanpa login)
Route::get('/barang', [BarangController::class, 'index']);
Route::get('/barang/{id}', [BarangController::class, 'show']);

// === GROUP ROUTE YANG WAJIB LOGIN (Butuh Token) ===
Route::middleware('auth:sanctum')->group(function () {
    // Auth User
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Keranjang (WAJIB DISINI AGAR $request->user() BERFUNGSI)
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    Route::post('/keranjang', [KeranjangController::class, 'store']);
    Route::put('/keranjang/{id}', [KeranjangController::class, 'update']);
    Route::delete('/keranjang/{id}', [KeranjangController::class, 'destroy']);

    // Transaksi
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);

    // Pembayaran
    Route::post('/pembayaran', [PembayaranController::class, 'store']);
});