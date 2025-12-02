import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pengguna_model.dart';
import 'auth_service.dart'; 

class PenggunaService {
  final String baseUrl = AuthService.baseUrl; 

  Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${AuthService.token}', 
    };
  }

  // 1. GET DATA
  Future<List<PenggunaModel>> getPengguna() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pengguna'), headers: headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          return (json['data'] as List).map((e) => PenggunaModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error Get: $e");
      return [];
    }
  }

  // 2. TAMBAH PENGGUNA
  Future<bool> tambahPengguna(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pengguna'), 
        headers: headers, 
        body: jsonEncode(data)
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Tambah: $e");
      return false;
    }
  }

  // 3. UPDATE PENGGUNA (PERBAIKAN: Pakai PUT)
  Future<bool> updatePengguna(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pengguna/$id'),
        headers: headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update: $e");
      return false;
    }
  }

  // 4. HAPUS PENGGUNA (BARU)
  Future<bool> hapusPengguna(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pengguna/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Hapus: $e");
      return false;
    }
  }

  // 5. UPDATE STATUS
  Future<bool> updateStatus(int id, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pengguna/$id/status'),
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}