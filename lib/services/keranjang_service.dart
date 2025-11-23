import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class KeranjangService {
  final String baseUrl = "http://localhost:8000/api/keranjang"; 

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); 
  }

  // 1. TAMBAH KE KERANJANG
  Future<bool> addToCart(int barangId, int jumlah) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'barang_id': barangId,
          'jumlah': jumlah,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error add cart: $e");
      return false;
    }
  }

  // 2. AMBIL DATA KERANJANG
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
        return jsonResponse['data'] ?? []; 
      }
      return [];
    } catch (e) {
      print("Error get cart: $e");
      return [];
    }
  }

  // 3. UPDATE JUMLAH (PUT)
  Future<bool> updateQuantity(int keranjangId, int jumlahBaru) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse("$baseUrl/$keranjangId"), 
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'jumlah': jumlahBaru}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update cart: $e");
      return false;
    }
  }

  // 4. HAPUS ITEM (DELETE)
  Future<bool> deleteItem(int keranjangId) async {
    try {
      String? token = await _getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse("$baseUrl/$keranjangId"),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error delete cart: $e");
      return false;
    }
  }
}