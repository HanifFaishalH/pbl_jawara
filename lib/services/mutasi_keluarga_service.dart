import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class MutasiKeluargaService {
  final String baseUrl = AuthService.baseUrl;

  Future<List<dynamic>> getMutasi() async {
    final response = await http.get(
      Uri.parse("$baseUrl/mutasi-keluarga"),
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

  Future<Map<String, dynamic>> getMutasiById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/mutasi-keluarga/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal load data');
  }

  Future<bool> saveMutasi({
    required Map<String, String> fields,
    XFile? dokumenFile,
    int? id,
  }) async {
    final url = id == null
        ? Uri.parse("$baseUrl/mutasi-keluarga")
        : Uri.parse("$baseUrl/mutasi-keluarga/$id");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    request.headers['Accept'] = 'application/json';

    if (id != null) request.fields['_method'] = 'PUT';

    request.fields.addAll(fields);

    if (dokumenFile != null) {
      final bytes = await dokumenFile.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'dokumen',
        bytes,
        filename: dokumenFile.name,
      );
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 201) {
        final respStr = await response.stream.bytesToString();
        print("Server Error: $respStr");
      }
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    }
  }

  Future<bool> deleteMutasi(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/mutasi-keluarga/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    return response.statusCode == 200;
  }

  Future<bool> updateStatus(int id, String status) async {
    final response = await http.put(
      Uri.parse("$baseUrl/mutasi-keluarga/$id/status"),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'mutasi_status': status}),
    );
    return response.statusCode == 200;
  }

  Future<bool> createMutasi(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse("$baseUrl/mutasi-keluarga"),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> updateMutasi(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse("$baseUrl/mutasi-keluarga/$id"),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }
}
