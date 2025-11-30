import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // WAJIB IMPORT INI
import 'auth_service.dart';

class KegiatanService {
  final String baseUrl = AuthService.baseUrl; 

  Future<List<dynamic>> getKegiatan() async {
    final response = await http.get(
      Uri.parse("$baseUrl/kegiatan"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      // Pastikan format data benar (List atau Object 'data')
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    throw Exception('Gagal load data');
  }

  // --- BAGIAN YANG DIPERBAIKI UNTUK WEB & MOBILE ---
  Future<bool> saveKegiatan({
    required Map<String, String> fields,
    XFile? imageFile, // GANTI: Terima XFile, bukan String path
    int? id,
  }) async {
    final url = id == null 
        ? Uri.parse("$baseUrl/kegiatan") 
        : Uri.parse("$baseUrl/kegiatan/$id");
    
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    request.headers['Accept'] = 'application/json';

    if (id != null) request.fields['_method'] = 'PUT';

    request.fields.addAll(fields);

    // LOGIKA UPLOAD UNIVERSAL (WEB + ANDROID + IOS)
    if (imageFile != null) {
      // 1. Baca file menjadi bytes (Uint8List)
      final bytes = await imageFile.readAsBytes();
      
      // 2. Buat MultipartFile dari bytes (Bukan dari path)
      var multipartFile = http.MultipartFile.fromBytes(
        'foto', // Nama key di Laravel ($request->file('foto'))
        bytes,
        filename: imageFile.name, // Penting! Kirim nama file asli
      );

      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      // Debugging jika error
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

  Future<bool> deleteKegiatan(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/kegiatan/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    return response.statusCode == 200;
  }
}