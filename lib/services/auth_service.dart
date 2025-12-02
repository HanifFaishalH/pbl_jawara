import 'dart:convert';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Base URL otomatis sesuai platform
  static String get baseUrl {
    // Android emulator maps host loopback to 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return "http://10.0.2.2:8000/api";
    }
    // iOS simulator and desktop/web use localhost
    return "http://127.0.0.1:8000/api";
  }

  // 🧠 Variabel global sesi
  static String? token;
  static int? currentRoleId;

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // ===========================
  // LOGIN
  // ===========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      logger.i("🔹 Login request: $url");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      logger.d("Status: ${response.statusCode}");
      logger.d("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();

        // 💾 Simpan data user
        await prefs.setString('user_nama_depan', user['user_nama_depan'] ?? 'User');
        await prefs.setString('user_nama_belakang', user['user_nama_belakang'] ?? '');
        await _saveSession(data['token'], user['role_id']);

        logger.i("✅ Login sukses: ${user['email']}");
        return {'success': true, 'data': data};
      }

      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Login gagal. Periksa kredensial Anda.'
      };
    } catch (e, s) {
      logger.e("❌ Error login", error: e, stackTrace: s);
      return {'success': false, 'message': 'Kesalahan server. Coba lagi nanti.'};
    }
  }

  // ===========================
  // REGISTER
  // ===========================
  Future<Map<String, dynamic>> register(Map<String, String> body) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      logger.i("🟢 Register request: $url");

      final response = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      logger.d("Status: ${response.statusCode}");
      logger.d("Body: ${response.body}");

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        final prefs = await SharedPreferences.getInstance();

        // 💾 Simpan data user
        await prefs.setString('user_nama_depan', user['user_nama_depan'] ?? 'User');
        await prefs.setString('user_nama_belakang', user['user_nama_belakang'] ?? '');
        await _saveSession(data['token'], user['role_id']);

        logger.i("✅ Registrasi sukses: ${user['email']}");
        return {'success': true, 'data': data};
      }

      final error = jsonDecode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Registrasi gagal. Coba lagi.'
      };
    } catch (e, s) {
      logger.e("❌ Error register", error: e, stackTrace: s);
      return {'success': false, 'message': 'Kesalahan server. Coba lagi nanti.'};
    }
  }

  // ===========================
  // SIMPAN & LOAD SESSION
  // ===========================
  Future<void> _saveSession(String newToken, int roleId,
      {String? namaDepan, String? namaBelakang}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    await prefs.setInt('auth_role_id', roleId);
    if (namaDepan != null) prefs.setString('user_nama_depan', namaDepan);
    if (namaBelakang != null) prefs.setString('user_nama_belakang', namaBelakang);
    token = newToken;
    currentRoleId = roleId;
  }

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    currentRoleId = prefs.getInt('auth_role_id');
  }

  // ===========================
  // LOGOUT
  // ===========================
  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");
    try {
      await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (_) {
      // Abaikan error jaringan, tetap lanjut logout lokal
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      token = null;
      currentRoleId = null;
      logger.i("👋 Logout berhasil, sesi dihapus");
    }
  }

  // ===========================
  // ME (Cek data user)
  // ===========================
  Future<Map<String, dynamic>> me() async {
    final url = Uri.parse("$baseUrl/me");
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      if (data['role_id'] != null) {
        await prefs.setInt('auth_role_id', data['role_id']);
        currentRoleId = data['role_id'];
      }
      return data;
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }
}
