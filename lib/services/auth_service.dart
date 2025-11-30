import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Sesuaikan URL dengan IP Address backend Anda
  static const String baseUrl = "http://localhost:8000/api";

  // Kalau pakai emulator Android, ganti localhost yang ini.
  //static const String baseUrl = "http://10.0.2.2:8000/api";
   
  
  // Variabel Global untuk menyimpan sesi saat ini
  static String? token;
  static int? currentRoleId;

  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: (time) => DateTime.now().toString(),
    )
  );

  // --- 1. LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
  final url = Uri.parse("$baseUrl/login");

  try {
    logger.i("Mengirim request login ke: $url");
    
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    logger.d("Response status: ${response.statusCode}");
    logger.d("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String newToken = data['token'];
      int roleId = data['user']['role_id'];
      await _saveSession(newToken, roleId);

      logger.i("Login berhasil untuk user role_id=$roleId");
      return {'success': true, 'data': data};
    } else {
      final data = jsonDecode(response.body);
      logger.w("Login gagal: ${data['message']}");
      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal. Periksa kembali akun Anda.',
      };
    }
  } catch (e, stackTrace) {
    logger.e("Terjadi error saat login", error: e, stackTrace: stackTrace);
    return {
      'success': false,
      'message': 'Ups, ada kesalahan pada server. Coba lagi nanti.',
    };
  }
}


  // --- 2. LOAD SESSION (Dipanggil saat Splash Screen) ---
  // Fungsi ini menjaga user tetap login saat aplikasi dibuka kembali
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    currentRoleId = prefs.getInt('auth_role_id');
  }

  // --- 3. SIMPAN SESSION (Internal) ---
  Future<void> _saveSession(String newToken, int roleId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    await prefs.setInt('auth_role_id', roleId);
    
    // Update variabel static agar bisa diakses langsung
    token = newToken;
    currentRoleId = roleId;
  }

  Future<Map<String, dynamic>> register(Map<String, String> body) async {
  final url = Uri.parse("$baseUrl/register");

  try {
    logger.i("Mengirim request register ke: $url");

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    logger.d("Response status: ${response.statusCode}");
    logger.d("Response body: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      String newToken = data['token'];
      int roleId = data['user']['role_id'] ?? 0; // jika tidak ada role_id
      await _saveSession(newToken, roleId);
      logger.i("✅ Registrasi berhasil untuk ${data['user']['email']}");
      return {'success': true, 'data': data};
    } else {
      logger.w("⚠️ Gagal register: ${data['message']}");
      return {
        'success': false,
        'message': data['message'] ?? 'Registrasi gagal. Periksa data Anda.',
      };
    }
  } catch (e, stackTrace) {
    logger.e("🔥 Error saat register", error: e, stackTrace: stackTrace);
    return {
      'success': false,
      'message': 'Ups, ada kesalahan pada server. Coba lagi nanti.',
    };
  }
}

  // --- 4. LOGOUT ---
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
    } catch (e) {
      // Tetap lanjutkan logout lokal meski server error
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Hapus semua data sesi
      token = null;
      currentRoleId = null;
    }
  }

  // --- 5. CEK USER (ME) ---
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
      // Update role jika ada perubahan di database
      if (data['role_id'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('auth_role_id', data['role_id']);
        currentRoleId = data['role_id'];
      }
      return data;
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }
}