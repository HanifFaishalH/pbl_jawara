import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/models/pesan_warga.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PesanWargaService {
  static const String baseUrl = AuthService.baseUrl;
  final Logger logger = Logger();

  /// =============================
  /// LIST USER UNTUK CHAT
  /// =============================
  Future<List<Map<String, dynamic>>> getUserList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/pengguna/chat-list');
    logger.i("👥 GET User Chat List → $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      logger.i("📡 Status: ${response.statusCode}");
      logger.d("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        logger.i("✅ User loaded: ${data.length}");
        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.e("❌ Gagal load user: ${response.body}");
        throw Exception('Gagal memuat daftar pengguna');
      }
    } on TimeoutException {
      logger.e("⏱ Timeout saat load user chat");
      throw Exception('Timeout server');
    } catch (e, s) {
      logger.e("🔥 Error getUserList", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// =============================
  /// GET CHAT DENGAN USER
  /// =============================
  Future<List<Map<String, dynamic>>> getChatWith(int penerimaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse("$baseUrl/pesan-warga/chat/$penerimaId");
    logger.i("💬 GET Chat → $url");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      logger.i("📡 Status: ${response.statusCode}");
      logger.d("📦 Body: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(body['data'] ?? []);
      } else {
        throw Exception('Gagal memuat chat');
      }
    } catch (e, s) {
      logger.e("🔥 Error getChatWith", error: e, stackTrace: s);
      rethrow;
    }
  }

  /// =============================
  /// KIRIM PESAN
  /// =============================
  Future<bool> kirimPesan(String isiPesan, int penerimaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse("$baseUrl/pesan-warga");
    logger.i("📤 Kirim pesan ke $penerimaId");

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

      logger.i("📡 Status: ${response.statusCode}");
      logger.d("📦 Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, s) {
      logger.e("🔥 Error kirimPesan", error: e, stackTrace: s);
      return false;
    }
  }

  Future<List<PesanWarga>> getPesanWarga() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final url = Uri.parse("$baseUrl/pesan-warga");
    logger.i("📨 GET Semua Pesan Warga → $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return (body['data'] as List)
          .map((e) => PesanWarga.fromJson(e))
          .toList();
    } else {
      throw Exception('Gagal memuat pesan warga');
    }
  }

}
