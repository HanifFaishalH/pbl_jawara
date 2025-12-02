import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../services/auth_service.dart'; // pastikan path benar

class BroadcastService {
  final String baseUrl = AuthService.baseUrl;
  final Logger logger = Logger();

  // === Get All Broadcast ===
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
              "Authorization": "Bearer $token",
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
          throw Exception("Response tidak success: ${decoded["message"]}");
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

  // === Create Broadcast ===
  Future<String> createBroadcast({
    required Map<String, dynamic> data,
    File? photo,
    PlatformFile? document,
  }) async {
    final token = AuthService.token;
    if (token == null) throw Exception("Belum login");

    final url = Uri.parse("$baseUrl/pesan-broadcast");
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll({
        'judul': data['judul'] ?? '',
        'pengirim': data['pengirim'] ?? '',
        'tanggal': data['tanggal'] ?? '',
        'isi_pesan': data['isi_pesan'] ?? '',
      });

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('foto', photo.path));
    }
    if (document != null && document.path != null) {
      request.files.add(await http.MultipartFile.fromPath('dokumen', document.path!));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final decoded = json.decode(responseBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return "Broadcast berhasil disimpan!";
    } else if (response.statusCode == 403) {
      return decoded['message'] ?? "Hanya admin yang dapat mengirim broadcast.";
    } else {
      return decoded['message'] ?? "Terjadi kesalahan saat menyimpan broadcast.";
    }
  }



  // === Update Broadcast ===
  Future<bool> updateBroadcast({
    required int id,
    required Map<String, dynamic> data,
    File? photo,
    PlatformFile? document,
  }) async {
    final token = AuthService.token;
    if (token == null) throw Exception("Belum login");

    final url = Uri.parse("$baseUrl/pesan-broadcast/$id");
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['_method'] = 'PUT'
      ..fields.addAll({
        'judul': data['judul'] ?? '',
        'pengirim': data['pengirim'] ?? '',
        'tanggal': data['tanggal'] ?? '',
        'isi_pesan': data['isi_pesan'] ?? '',
      });

    if (photo != null) {
      logger.i("🖼️ Update dengan foto baru: ${photo.path}");
      request.files.add(await http.MultipartFile.fromPath('foto', photo.path));
    }

    if (document != null && document.path != null) {
      logger.i("📎 Update dengan dokumen baru: ${document.name}");
      request.files.add(await http.MultipartFile.fromPath('dokumen', document.path!));
    }

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();
      logger.i("📤 Update status: ${response.statusCode}, Body: $body");

      if (response.statusCode == 200) {
        return true;
      } else {
        logger.e("❌ Gagal update broadcast: $body");
        return false;
      }
    } catch (e) {
      logger.e("❌ Error saat update broadcast: $e");
      throw Exception("Gagal memperbarui broadcast");
    }
  }

  // === Delete Broadcast ===
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
