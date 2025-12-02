import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class TransaksiService {
  // Ganti IP sesuai environment (Emulator: 10.0.2.2, HP Fisik: IP Laptop)
  static const String baseUrl = AuthService.baseUrl; 

  Future<String?> _getToken() async {
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // CREATE
  Future<bool> createTransaction(Map<String, dynamic> transactionData) async {
    final url = Uri.parse("$baseUrl/transaksi");
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(transactionData),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error create: $e");
      return false; 
    }
  }

  // GET RIWAYAT (PEMBELI)
  Future<List<dynamic>> fetchRiwayatPesanan() async {
    final url = Uri.parse("$baseUrl/transaksi");
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      return [];
    } catch (e) {
      print("Error riwayat: $e");
      return [];
    }
  }

  // GET PESANAN MASUK (PENJUAL)
  Future<List<dynamic>> fetchPesananMasuk() async {
    final url = Uri.parse("$baseUrl/transaksi/masuk"); 
    final token = await _getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? []; 
      }
      return [];
    } catch (e) {
      print("Error pesanan masuk: $e");
      return []; 
    }
  }

  // UPDATE STATUS (BATAL / SELESAI)
  Future<bool> updateStatusTransaksi(int transaksiId, String statusBaru) async {
    final url = Uri.parse("$baseUrl/transaksi/$transaksiId/status");
    final token = await _getToken();
    if (token == null) return false;

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': statusBaru}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error update status: $e");
      return false;
    }
  }
}