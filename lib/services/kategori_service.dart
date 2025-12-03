import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/services/auth_service.dart';

class KategoriService {
  /// Ambil daftar kategori untuk dropdown
  static Future<List<Map<String, dynamic>>> fetchKategori({String? search}) async {
    final uri = Uri.parse('${AuthService.baseUrl}/kategori').replace(
      queryParameters: search != null && search.isNotEmpty ? {'search': search} : null,
    );

    final resp = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (resp.statusCode == 200) {
      final body = jsonDecode(resp.body);
      final List data = body['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Gagal memuat kategori (${resp.statusCode})');
  }
}
