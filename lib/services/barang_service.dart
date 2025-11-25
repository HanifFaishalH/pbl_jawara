import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 1. WAJIB TAMBAH INI
import 'package:jawaramobile_1/services/auth_service.dart';

class BarangService {
  // PENTING: Gunakan 10.0.2.2 untuk Emulator
  static const String BaseURl = "http://localhost:8000/api"; 

  // --- 2. HELPER: AMBIL TOKEN MANUAL (Anti Reset) ---
  Future<String?> _getToken() async {
    // Cek apakah di memory (AuthService) masih ada?
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    
    // Jika memory kosong (habis restart), ambil dari Storage HP
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('auth_token');
    
    // (Opsional) Isi balik ke AuthService biar request selanjutnya cepat
    if (storedToken != null) {
      AuthService.token = storedToken;
    }
    
    return storedToken;
  }

  // Method untuk Marketplace (Semua Barang)
  Future<List<dynamic>> fetchBarang() async {
    final url = Uri.parse("$BaseURl/barang");
    
    // 3. GUNAKAN HELPER _getToken()
    final token = await _getToken(); 

    // Header Authorization
    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(url, headers: headers);
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];      
    } else {
      throw Exception('Gagal load barang');
    }
  }

  // Method untuk Dagangan Saya (Barang User Login)
  Future<List<dynamic>> fetchUserBarang() async {
    final url = Uri.parse("$BaseURl/barang/user");
    
    // 4. GUNAKAN HELPER _getToken() DI SINI JUGA
    final token = await _getToken(); 

    if (token == null) {
      throw Exception('Sesi habis. Silakan logout dan login lagi.');
    }

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];      
    } else {
      // Print error body untuk debugging
      print("Gagal Fetch User Barang: ${response.body}");
      throw Exception('Gagal load barang saya');
    }
  }
}