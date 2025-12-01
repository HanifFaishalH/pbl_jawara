import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/models/pesan_warga.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesanWargaService {
  static const String baseUrl = "http://10.0.2.2:8000/api";
  final logger = Logger();

  /// Ambil semua chat antara user login dengan penerimaId
  Future<List<Map<String, dynamic>>> getChatWith(int penerimaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Belum login');

    final url = Uri.parse("$baseUrl/pesan-warga/chat/$penerimaId");
    logger.i("📨 Fetching chat with user ID: $penerimaId");

    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json'
            },
          )
          .timeout(const Duration(seconds: 10));

      logger.i("📡 Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List data = decoded['data'] ?? [];
        logger.i("💬 ${data.length} messages loaded");
        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.e("❌ Gagal memuat chat (${response.statusCode})");
        throw Exception('Gagal memuat chat');
      }
    } on TimeoutException {
      throw Exception('Timeout — server tidak merespons.');
    } catch (e) {
      logger.e("⛔ Error getChatWith: $e");
      rethrow;
    }
  }

  /// Kirim pesan ke user lain
  Future<bool> kirimPesan(String isiPesan, int penerimaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('Belum login');

    final url = Uri.parse("$baseUrl/pesan-warga");
    logger.i("💌 Mengirim pesan ke user ID: $penerimaId");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: {
          'isi_pesan': isiPesan,
          'penerima_id': penerimaId.toString(),
        },
      );

      logger.d("📡 Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i("✅ Pesan berhasil dikirim");
        return true;
      } else {
        logger.w("⚠️ Gagal mengirim pesan: ${response.body}");
        return false;
      }
    } catch (e, s) {
      logger.e("❌ Error kirimPesan: $e", stackTrace: s);
      return false;
    }
  }

  Future<List<PesanWarga>> getPesanWarga() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) throw Exception('Belum login');

  final url = Uri.parse("$baseUrl/pesan-warga");
  logger.i("📨 Mengambil daftar pesan warga dari $url");

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    logger.d("Status Code: ${response.statusCode}");
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'] ?? [];
      logger.i("✅ ${data.length} pesan warga berhasil diambil");

      // konversi ke model
      return data.map((e) => PesanWarga.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat pesan warga (${response.statusCode})');
    }
  } catch (e, s) {
    logger.e("❌ Error getPesanWarga: $e", stackTrace: s);
    rethrow;
  }
}

}
