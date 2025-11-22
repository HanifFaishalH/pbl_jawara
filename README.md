# 🧵 PBL Jawara - Marketplace RW Berbasis Flutter dan Laravel

Aplikasi ini merupakan sistem marketplace sederhana yang menghubungkan warga RW dengan penjual lokal.  
Frontend dibangun dengan **Flutter**, sedangkan backend API menggunakan **Laravel 12 + Sanctum**.

---

## 🚀 Fitur Utama
- 👤 Autentikasi pengguna (Laravel Sanctum)
- 🛍️ Daftar produk (Barang)
- 🛒 Keranjang belanja
- 💳 Transaksi & Pembayaran
- 📱 Integrasi Flutter ↔ Laravel REST API

---

## 🧩 Struktur Proyek
pbl_jawara/
│
├── backend/ # Laravel API (folder backend)
│ ├── app/Http/Controllers/Api/
│ ├── routes/api.php
│ ├── database/migrations/
│ └── ...
│
└── flutter_app/ # Aplikasi Flutter (frontend)
├── lib/
├── pubspec.yaml
└── ...

yaml
Copy code

---

## 📦 Cara Menjalankan Backend (Laravel)
1. Masuk ke folder `backend`
   ```bash
   cd backend
Install dependency Laravel

bash
Copy code
composer install
Copy file environment

bash
Copy code
cp .env.example .env
Jalankan key generator

bash
Copy code
php artisan key:generate
Jalankan migration & seeder

bash
Copy code
php artisan migrate --seed
Jalankan server Laravel

bash
Copy code
php artisan serve
Server akan berjalan di:
👉 http://127.0.0.1:8000 atau http://10.0.2.2:8000 (untuk Android Emulator)

📱 Cara Menjalankan Flutter
Masuk ke folder aplikasi Flutter:

bash
Copy code
cd flutter_app
Jalankan dependency Flutter:

bash
Copy code
flutter pub get
Jalankan emulator Android.

Jalankan aplikasi Flutter:

bash
Copy code
flutter run
🔗 Menghubungkan Flutter ke Laravel API
Pastikan Laravel sudah berjalan (php artisan serve).

Di Flutter, buat file service (misal barang_service.dart):

dart
Copy code
import 'dart:convert';
import 'package:http/http.dart' as http;

class BarangService {
  static const String baseUrl = "http://10.0.2.2:8000/api";

  Future<List<dynamic>> fetchBarang() async {
    final response = await http.get(
      Uri.parse("$baseUrl/barang"),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer <TOKEN_SANCTUM>'
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load barang');
    }
  }
}
Pastikan URL menggunakan 10.0.2.2 untuk emulator Android.

👩‍💻 Teknologi yang Digunakan
Frontend: Flutter (Dart)

Backend: Laravel 12 + Sanctum

Database: MySQL

Tool: Laragon / XAMPP, Postman, Android Studio