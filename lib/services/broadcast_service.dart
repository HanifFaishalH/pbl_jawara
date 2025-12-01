import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../services/auth_service.dart'; // pastikan import ini

class BroadcastService {
  final String baseUrl = "http://10.0.2.2:8000/api";
  final Logger logger = Logger();

  Future<List<Map<String, dynamic>>> getBroadcastList() async {
    logger.i("🔄 Fetching broadcast list from $baseUrl/pesan-broadcast");

    try {
      final token = AuthService.token;
      if (token == null) throw Exception("Belum login (token null)");

      final response = await http
          .get(
            Uri.parse("$baseUrl/pesan-broadcast"),
            headers: {
              "Accept": "application/json",
              "Authorization": "Bearer $token", // ✅ tambahkan ini
            },
          )
          .timeout(const Duration(seconds: 10));

      logger.i("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["status"] == "success") {
          final List data = decoded["data"];
          logger.i("💡 ✅ ${data.length} broadcast loaded");
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception("Response tidak success");
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } on TimeoutException {
      logger.e("❌ Timeout saat memuat data broadcast");
      throw Exception("Server tidak merespons, coba lagi nanti.");
    } catch (e) {
      logger.e("⛔ ❌ Gagal memuat broadcast: $e");
      throw Exception("Gagal memuat data broadcast");
    }
  }

  Future<bool> deleteBroadcast(int id) async {
    final token = AuthService.token;
    if (token == null) {
      logger.e("Token belum ada, user belum login");
      return false;
    }

    final url = Uri.parse("$baseUrl/pesan-broadcast/$id");
    logger.i("🗑️ Menghapus broadcast ID: $id");

    try {
      final response = await http
          .delete(
            url,
            headers: {
              "Accept": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 10));

      logger.i("📡 Delete Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final success = body["status"] == "success";
        logger.i(success
            ? "✅ Broadcast berhasil dihapus"
            : "⚠️ Gagal menghapus broadcast: ${body['message']}");
        return success;
      } else {
        logger.e("❌ Server error: ${response.statusCode}");
        return false;
      }
    } on TimeoutException {
      logger.e("❌ Timeout saat menghapus broadcast");
      return false;
    } catch (e) {
      logger.e("❌ Gagal menghapus broadcast: $e");
      return false;
    }
  }
}
