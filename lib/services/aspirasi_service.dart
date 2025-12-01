import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../../models/aspirasi_models.dart';

class AspirasiService {
  // Mengambil Base URL dari AuthService agar konsisten
  final String baseUrl = AuthService.baseUrl;

  // GET: Ambil List Aspirasi
  Future<List<AspirasiModel>> getAspirasi() async {
    final token = AuthService.token;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/aspirasi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => AspirasiModel.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data aspirasi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // POST: Buat Aspirasi Baru (Khusus Warga)
  Future<bool> createAspirasi(String judul, String deskripsi) async {
    final token = AuthService.token;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aspirasi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'judul': judul, 
          'deskripsi': deskripsi
        }),
      );

      // 201 Created
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // POST: Update Status & Tanggapan (Khusus Pejabat)
  Future<bool> updateStatus(int id, String status, String tanggapan) async {
    final token = AuthService.token;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/aspirasi/$id/konfirmasi'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'status': status, 
          'tanggapan': tanggapan
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}