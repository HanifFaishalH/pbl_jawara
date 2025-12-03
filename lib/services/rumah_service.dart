import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class RumahService {
  final String baseUrl = AuthService.baseUrl;

  Future<List<dynamic>> getRumah() async {
    final response = await http.get(
      Uri.parse("$baseUrl/rumah"),
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

  Future<Map<String, dynamic>> getRumahById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/rumah/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal load data');
  }

  Future<bool> saveRumah({
    required Map<String, dynamic> data,
    int? id,
  }) async {
    final url = id == null
        ? Uri.parse("$baseUrl/rumah")
        : Uri.parse("$baseUrl/rumah/$id");

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

  Future<bool> deleteRumah(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/rumah/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    return response.statusCode == 200;
  }
}
