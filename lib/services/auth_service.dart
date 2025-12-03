import 'dart:convert';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ------------------------------------------------------------------------
  // 🔧 KONFIGURASI URL
  // ------------------------------------------------------------------------
  // Gunakan 10.0.2.2 jika menggunakan Android Emulator bawaan Android Studio
  // Gunakan 127.0.0.1 jika menggunakan Web atau iOS Simulator
  // Gunakan IP Laptop (misal 192.168.1.x) jika menggunakan HP fisik
  
  // static const String baseUrl = "http://10.0.2.2:8000/api"; 
  static const String baseUrl = "http://127.0.0.1:8000/api";

  // 🧠 Variabel global sesi (disimpan di memori statis agar mudah diakses)
  static String? token;
  static int? currentRoleId;
  static int? userId;
  static String? userNamaDepan;

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, 
      errorMethodCount: 3, 
      lineLength: 80, 
      colors: true, 
      printEmojis: true,
    ),
  );

  // ===========================
  // 🔐 LOGIN
  // ===========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      logger.i("🔹 Login request ke: $url");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      logger.d("Status Code: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        
        // ✅ Login Sukses: SIMPAN SESI
        await _saveSession(
          data['token'], 
          user['role_id'],
          namaDepan: user['user_nama_depan'],
          namaBelakang: user['user_nama_belakang']
        );

        logger.i("✅ Login berhasil: ${user['email']} (Role ID: ${user['role_id']})");
        return {'success': true, 'data': data};
      }

      // ❌ Login Gagal (Password salah / User tidak ditemukan)
      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Email atau password salah.'
      };

    } catch (e) {
      logger.e("❌ Error login: $e");
      return {'success': false, 'message': 'Gagal terhubung ke server.'};
    }
  }

  // ===========================
  // 📝 REGISTER
  // ===========================
  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      logger.i("🟢 Register request ke: $url");
      logger.d("📦 Data: $body");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      logger.d("Status Code: ${response.statusCode}");

      if (response.statusCode == 201) { // 201 = Created
        // ✅ Register Sukses
        // ⚠️ PENTING: Kita TIDAK memanggil _saveSession disini.
        // User harus menunggu konfirmasi admin dan login manual nanti.
        
        logger.i("✅ Registrasi berhasil dibuat (Status: Pending)");
        return {
          'success': true, 
          'message': 'Registrasi berhasil. Silakan tunggu verifikasi admin.'
        };
      }

      // ❌ Register Gagal (Validasi Error)
      final responseData = jsonDecode(response.body);
      String message = responseData['message'] ?? 'Registrasi gagal.';
      
      // Ambil pesan error spesifik jika ada (misal: Email sudah dipakai)
      if (responseData['errors'] != null) {
        // Mengambil error pertama dari list error
        Map<String, dynamic> errors = responseData['errors'];
        if (errors.isNotEmpty) {
           message = errors.values.first[0];
        }
      }

      logger.w("⚠️ Gagal register: $message");
      return {
        'success': false,
        'message': message
      };

    } catch (e) {
      logger.e("❌ Error register: $e");
      return {'success': false, 'message': 'Gagal terhubung ke server.'};
    }
  }

  // ===========================
  // 💾 MANAJEMEN SESI (Simpan & Load)
  // ===========================
  
  // Fungsi internal untuk menyimpan data ke HP (Shared Preferences)
  Future<void> _saveSession(String newToken, int roleId,
      {String? namaDepan, String? namaBelakang}) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('auth_token', newToken);
    await prefs.setInt('auth_role_id', roleId);
    
    if (namaDepan != null) {
      await prefs.setString('user_nama_depan', namaDepan);
    }
    if (namaBelakang != null) {
      await prefs.setString('user_nama_belakang', namaBelakang);
    }

    // Update variabel static agar bisa langsung dipakai di aplikasi
    token = newToken;
    currentRoleId = roleId;
    userNamaDepan = namaDepan;
  }

  // Dipanggil saat aplikasi pertama kali dibuka (Splash Screen)
  static Future<bool> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    currentRoleId = prefs.getInt('auth_role_id');
    userNamaDepan = prefs.getString('user_nama_depan');

    // Return true jika ada token (artinya user masih login)
    return token != null;
  }

  // ===========================
  // 🚪 LOGOUT
  // ===========================
  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");
    
    // Coba request logout ke server (agar token di server dihapus)
    try {
      if (token != null) {
        await http.post(
          url,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }
    } catch (e) {
      logger.w("⚠️ Logout server gagal (mungkin koneksi), lanjut logout lokal.");
    } finally {
      // Hapus data di HP (Wajib)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset variabel static
      token = null;
      currentRoleId = null;
      userNamaDepan = null;
      userId = null;
      
      logger.i("👋 Logout berhasil, sesi dibersihkan.");
    }
  }

  // ===========================
  // 👤 CEK USER (ME)
  // ===========================
  // Berguna untuk memastikan token masih valid
  Future<Map<String, dynamic>> me() async {
    final url = Uri.parse("$baseUrl/me");
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else {
        // Token kadaluarsa atau tidak valid
        await logout(); // Paksa logout
        return {'success': false, 'message': 'Sesi habis'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error koneksi'};
    }
  }
}