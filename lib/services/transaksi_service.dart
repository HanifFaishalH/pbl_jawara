import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini
import 'package:jawaramobile_1/services/auth_service.dart';

class TransaksiService {
  // PENTING: Jika pakai Emulator Android, GANTI 'localhost' jadi '10.0.2.2'
  // Jika pakai HP Fisik via USB, ganti dengan IP Address Laptop (contoh: 192.168.1.x)
  static const String baseUrl = "http://localhost:8000/api"; 

  // Fungsi Helper: Ambil token secara manual tanpa mengubah AuthService
  Future<String?> _getToken() async {
    // 1. Cek dulu dari AuthService (Memory)
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    
    // 2. Jika Memory kosong (habis restart), ambil paksa dari Storage HP
    final prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('auth_token');
    
    // (Opsional) Isi balik ke AuthService agar request selanjutnya cepat
    if (storedToken != null) {
      AuthService.token = storedToken;
    }
    
    return storedToken;
  }

  // 1. POST: Membuat Transaksi Baru
  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    final url = Uri.parse("$baseUrl/transaksi");
    
    // PERBAIKAN: Gunakan fungsi helper _getToken()
    final token = await _getToken(); 

    // Cek Debugging
    print("Token yang akan dikirim: $token");

    if (token == null) {
      print("Error: Token null. User dianggap belum login.");
      return false;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Token pasti terisi
        },
        body: jsonEncode(transactionData),
      );

      print("Status Code: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print("Gagal Create Transaksi: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error createTransaction: $e");
      return false; 
    }
  }

  // 2. GET: Mengambil Data Pesanan Masuk
  Future<List<dynamic>> fetchPesananMasuk() async {
    final url = Uri.parse("$baseUrl/transaksi/masuk"); 
    
    // PERBAIKAN: Gunakan fungsi helper _getToken()
    final token = await _getToken();

    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? []; 
      } else {
        print("Gagal ambil pesanan: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetchPesananMasuk: $e");
      return []; 
    }
  }
}