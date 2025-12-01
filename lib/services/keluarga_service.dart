import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class KeluargaService {
  final String baseUrl = AuthService.baseUrl;

  Future<List<dynamic>> getKeluarga() async {
    final response = await http.get(
      Uri.parse("$baseUrl/keluarga"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    throw Exception('Gagal load data');
  }

  Future<Map<String, dynamic>> getKeluargaById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/keluarga/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal load data');
  }

  Future<bool> saveKeluarga({
    required Map<String, dynamic> data,
    int? id,
  }) async {
    final url = id == null
        ? Uri.parse("$baseUrl/keluarga")
        : Uri.parse("$baseUrl/keluarga/$id");

    final response = id == null
        ? await http.post(
            url,
            headers: {
              'Authorization': 'Bearer ${AuthService.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
        : await http.put(
            url,
            headers: {
              'Authorization': 'Bearer ${AuthService.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          );

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> deleteKeluarga(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/keluarga/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    return response.statusCode == 200;
  }
}
