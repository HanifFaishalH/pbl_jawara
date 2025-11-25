import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Sesuaikan URL dengan IP Address backend Anda
  static const String baseUrl = "http://localhost:8000/api"; 
  
  // Variabel Global untuk menyimpan sesi saat ini
  static String? token;
  static int? currentRoleId;

  // --- 1. LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    try {
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String newToken = data['token'];
        // Pastikan backend mengirim object 'user' yang berisi 'role_id'
        int roleId = data['user']['role_id']; 

        // Simpan ke sesi aplikasi (Memory & Storage)
        await _saveSession(newToken, roleId);
        
        return data;
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      rethrow;
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