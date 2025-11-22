## ⚙️ **README.md (khusus folder backend/)**

```markdown
# ⚙️ Backend API - PBL Jawara

Backend ini dibuat menggunakan **Laravel 12** dengan sistem autentikasi **Sanctum** untuk API.  
API digunakan oleh aplikasi Flutter untuk melakukan transaksi data seperti barang, keranjang, transaksi, dan pembayaran.

---

## 🧱 Instalasi

1. Masuk ke folder `backend`
   ```bash
   cd backend
Install dependency Laravel

bash
Copy code
composer install
Salin file environment

bash
Copy code
cp .env.example .env
Atur konfigurasi database di .env

env
Copy code
DB_DATABASE=jawara_db
DB_USERNAME=root
DB_PASSWORD=
Jalankan key generator

bash
Copy code
php artisan key:generate
Jalankan migration dan seeder

bash
Copy code
php artisan migrate --seed
Jalankan server

bash
Copy code
php artisan serve
🔐 Konfigurasi Sanctum
Instal dan konfigurasi Sanctum:

bash
Copy code
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
Tambahkan middleware Sanctum di app/Http/Kernel.php:

php
Copy code
'api' => [
    \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
    'throttle:api',
    \Illuminate\Routing\Middleware\SubstituteBindings::class,
],
🧩 Membuat Controller API
Gunakan command Artisan untuk membuat controller API:

bash
Copy code
php artisan make:controller Api/BarangController --api --model=BarangModel
php artisan make:controller Api/KeranjangController --api --model=KeranjangModel
php artisan make:controller Api/TransaksiController --api --model=TransaksiModel
php artisan make:controller Api/PembayaranController --api --model=PembayaranModel
🔗 Route API
File route berada di: routes/api.php

php
Copy code
use App\Http\Controllers\Api\BarangController;
use App\Http\Controllers\Api\KeranjangController;
use App\Http\Controllers\Api\TransaksiController;
use App\Http\Controllers\Api\PembayaranController;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/barang', [BarangController::class, 'index']);
    Route::get('/barang/{id}', [BarangController::class, 'show']);
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    Route::post('/keranjang', [KeranjangController::class, 'store']);
    Route::get('/transaksi', [TransaksiController::class, 'index']);
    Route::post('/transaksi', [TransaksiController::class, 'store']);
    Route::post('/pembayaran', [PembayaranController::class, 'store']);
});
📤 Testing API dengan Postman
Gunakan header berikut saat testing:

Header	Value
Accept	application/json
Authorization	Bearer {token_sanctum}

Contoh endpoint:

nginx
Copy code
GET http://127.0.0.1:8000/api/barang
🧠 Tips
Gunakan 10.0.2.2 sebagai host untuk koneksi dari Flutter Emulator.

Cek route dengan php artisan route:list.

Untuk debugging, lihat log di storage/logs/laravel.log.

📦 Teknologi
Laravel 12

Sanctum Auth

MySQL

PHP 8.3+

Composer

yaml
Copy code

---