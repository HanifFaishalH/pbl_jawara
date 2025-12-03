import 'dart:convert';
import 'dart:io'; // Untuk Platform.isAndroid
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class BarangService {
  
  // --- KONFIGURASI SERVER ---
  // GANTI MANUAL SESUAI KEBUTUHAN:
  // - "http://10.0.2.2:8000/api" untuk Android Emulator
  // - "http://192.168.1.3:8000/api" untuk HP Fisik via WiFi
  
  // 1. Base URL API
  static String get baseUrl => "http://192.168.1.3:8000/api"; // 🔥 HP FISIK

  // 2. Base URL Gambar
  static String get baseImageUrl => "http://192.168.1.3:8000/api/image-proxy/"; // 🔥 HP FISIK

  // --- HELPER TOKEN ---
  Future<String?> _getToken() async {
    // Cek token di memori static dulu
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    
    // Jika tidak ada, ambil dari storage HP
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('auth_token');
    
    if (storedToken != null) {
      AuthService.token = storedToken;
    }
    
    return storedToken;
  }

  // --- FETCH SEMUA BARANG ---
  Future<List<dynamic>> fetchBarang() async {
    final url = Uri.parse("$baseUrl/barang"); 
    
    final token = await _getToken(); 

    Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data'];      
      } else {
        throw Exception('Gagal load barang: ${response.statusCode}');
      }
    } catch (e) {
      print("Error Fetch Barang: $e");
      throw Exception('Gagal terhubung ke server');
    }
  }

  // --- FETCH BARANG SAYA ---
  Future<List<dynamic>> fetchUserBarang() async {
    final url = Uri.parse("$baseUrl/barang/user"); 
    
    final token = await _getToken(); 

    if (token == null) {
      throw Exception('Sesi habis. Silakan logout dan login lagi.');
    }

    try {
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
    } catch (e) {
       print("Error User Barang: $e");
       throw Exception('Error koneksi');
    }
  }
}