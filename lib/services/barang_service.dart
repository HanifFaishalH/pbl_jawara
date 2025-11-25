import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:flutter/foundation.dart'; // PENTING: Untuk kIsWeb

class BarangService {
  
  // --- KONFIGURASI OTOMATIS (WEB vs ANDROID) ---
  
  // 1. Base URL API
  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api"; // Browser Chrome
    } else {
      return "http://10.0.2.2:8000/api";  // Emulator Android
    }
  }

  // 2. Base URL Gambar (Menggunakan Proxy Route yang baru dibuat)
  // Ini mengarah ke route: Route::get('/image-proxy/{filename}')
  static String get baseImageUrl {
    if (kIsWeb) {
      return "http://localhost:8000/api/image-proxy/"; 
    } else {
      return "http://10.0.2.2:8000/api/image-proxy/";
    }
  }

  // --- HELPER TOKEN ---
  Future<String?> _getToken() async {
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('auth_token');
    
    if (storedToken != null) {
      AuthService.token = storedToken;
    }
    
    return storedToken;
  }

  // --- FETCH SEMUA BARANG ---
  Future<List<dynamic>> fetchBarang() async {
    final url = Uri.parse("$baseUrl/barang"); // Menggunakan getter baseUrl
    
    final token = await _getToken(); 

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
      throw Exception('Gagal load barang: ${response.statusCode}');
    }
  }

  // --- FETCH BARANG SAYA ---
  Future<List<dynamic>> fetchUserBarang() async {
    final url = Uri.parse("$baseUrl/barang/user"); // Menggunakan getter baseUrl
    
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
      print("Gagal Fetch User Barang: ${response.body}");
      throw Exception('Gagal load barang saya');
    }
  }
}