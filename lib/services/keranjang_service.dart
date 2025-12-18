import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart'; // Import AuthService

class KeranjangService {
  // ------------------------------------------------------------------------
  // 🔧 KONFIGURASI URL
  // ------------------------------------------------------------------------
  // Gunakan 10.0.2.2 jika menggunakan Android Emulator
  // Gunakan 127.0.0.1 jika menggunakan Web
  // Gunakan IP Laptop (misal 192.168.1.x) jika menggunakan HP Fisik
  
  // static const String baseUrl = "http://10.0.2.2:8000/api/keranjang"; 
  String get baseUrl => '${AuthService.baseUrl}/keranjang';

  // ------------------------------------------------------------------------
  // 🔑 HELPER: AMBIL TOKEN
  // ------------------------------------------------------------------------
  Future<String?> _getToken() async {
    // 1. Cek variabel static di AuthService dulu (Prioritas Utama)
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }

    // 2. Jika kosong, ambil dari SharedPreferences dengan key yang BENAR ('auth_token')
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // 🔥 FIXED: Menggunakan 'auth_token'
  }

  // ------------------------------------------------------------------------
  // 1. TAMBAH KE KERANJANG (POST)
  // ------------------------------------------------------------------------
  Future<Map<String, dynamic>> addToCart(int barangId, int jumlah) async {
    try {
      String? token = await _getToken();
      
      // Debugging Logs
      print("--- ADD TO CART ---");
      print("Token: $token");
      print("Barang ID: $barangId, Jumlah: $jumlah");

      if (token == null) {
        print("❌ Gagal: Token tidak ditemukan (Null)");
        return {'success': false, 'message': 'Token tidak ditemukan'};
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'barang_id': barangId,
          'jumlah': jumlah,
        }),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message'] ?? 'Sukses', 'data': data['data']};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Gagal menambah ke keranjang'};
      }
    } catch (e) {
      print("❌ Error add cart: $e");
      return {'success': false, 'message': e.toString()};
    }
  }

  // ------------------------------------------------------------------------
  // 2. AMBIL DATA KERANJANG (GET)
  // ------------------------------------------------------------------------
  Future<List<dynamic>> getKeranjang() async {
    try {
      String? token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];

        // 🔥 FIX URL GAMBAR DI SINI
        final String baseHost = AuthService.baseUrl.replaceAll('/api', '');

        for (var item in data) {
          if (item['barang'] != null &&
              item['barang']['barang_foto'] != null &&
              item['barang']['barang_foto'].toString().isNotEmpty) {
            
            final rawFoto = item['barang']['barang_foto'];

            if (!rawFoto.startsWith('http')) {
              item['barang']['barang_foto'] =
                  "$baseHost/storage/$rawFoto";
            }
          }
        }

        return data;
      }

      return [];
    } catch (e) {
      print("❌ Error get cart: $e");
      return [];
    }
  }


  // ------------------------------------------------------------------------
  // 3. UPDATE JUMLAH ITEM (PUT)
  // ------------------------------------------------------------------------
  Future<bool> updateQuantity(int keranjangId, int jumlahBaru) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse("$baseUrl/$keranjangId"), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'jumlah': jumlahBaru}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error update cart: $e");
      return false;
    }
  }

  // ------------------------------------------------------------------------
  // 4. HAPUS ITEM (DELETE)
  // ------------------------------------------------------------------------
  Future<bool> deleteItem(int keranjangId) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("$baseUrl/$keranjangId"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error delete cart: $e");
      return false;
    }
  }
}