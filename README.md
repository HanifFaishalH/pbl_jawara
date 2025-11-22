```
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
```

pbl_jawara/
│
├── backend/            # Laravel API (folder backend)
│   ├── app/Http/Controllers/Api/
│   ├── routes/api.php
│   ├── database/migrations/
│   └── ...
│
└── flutter_app/        # Aplikasi Flutter (frontend)
├── lib/
├── pubspec.yaml
└── ...

````

---

## 📦 Cara Menjalankan Backend (Laravel)

1. Masuk ke folder backend:
   ```bash
   cd backend
````

2. Install dependency Laravel:

   ```bash
   composer install
   ```

3. Salin file environment:

   ```bash
   cp .env.example .env
   ```

4. Jalankan key generator:

   ```bash
   php artisan key:generate
   ```

5. Jalankan migration & seeder:

   ```bash
   php artisan migrate --seed
   ```

6. Jalankan server Laravel:

   ```bash
   php artisan serve
   ```

Server akan berjalan di:

> 🖥️ `http://127.0.0.1:8000`
> 📱 `http://10.0.2.2:8000` (untuk Android Emulator)

---

## 📱 Cara Menjalankan Flutter

1. Masuk ke folder aplikasi Flutter:

   ```bash
   cd flutter_app
   ```

2. Jalankan dependency Flutter:

   ```bash
   flutter pub get
   ```

3. Jalankan emulator Android.

4. Jalankan aplikasi Flutter:

   ```bash
   flutter run
   ```

---

## 🔗 Menghubungkan Flutter ke Laravel API

1. Pastikan Laravel sudah berjalan (`php artisan serve`).

2. Di Flutter, buat file service (misal: `barang_service.dart`):

   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;

   class BarangService {
     static const String baseUrl = "http://10.0.2.2:8000/api";

     Future<List<dynamic>> fetchBarang() async {
       final response = await http.get(
         Uri.parse("$baseUrl/barang"),
         headers: {
           'Accept': 'application/json',
           'Authorization': 'Bearer <TOKEN_SANCTUM>',
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
   ```

3. Pastikan URL menggunakan `10.0.2.2` untuk emulator Android.

---

## 👩‍💻 Teknologi yang Digunakan

| Komponen     | Teknologi                                |
| ------------ | ---------------------------------------- |
| **Frontend** | Flutter (Dart)                           |
| **Backend**  | Laravel 12 + Sanctum                     |
| **Database** | MySQL                                    |
| **Tools**    | Laragon / XAMPP, Postman, Android Studio |

---

## ✨ Pengembang

Proyek ini dikembangkan sebagai bagian dari mata kuliah **Proyek Berbasis Pembelajaran (PBL)**.
Dibuat untuk memudahkan transaksi dan interaksi antara warga RW dan pelaku UMKM lokal.

```
