import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class BarangService {
  // 🌐 Base URL API Laravel
  static String get baseUrl => "http://127.0.0.1:8000/api";
  static String get baseImageUrl => "http://127.0.0.1:8000/storage/";

  // 🧾 Logger instance
  static final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 90,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  Future<String?> _getToken() async {
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) AuthService.token = token;
    return token;
  }

  // ============================================================
  // 🚀 PREDIKSI KATEGORI (KIRIM GAMBAR KE LARAVEL)
  // ============================================================
  Future<String?> predictKategori(String imagePath) async {
    final url = Uri.parse("${BarangService.baseUrl}/predict-batik");
    logger.i("📤 [PREDICT] Mengirim gambar ke API ML");
    logger.i("🖼️ Path gambar lokal: $imagePath");
    logger.i("🌍 Endpoint: $url");

    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        logger.w("⚠️ File tidak ditemukan di path: $imagePath");
        throw Exception("File tidak ditemukan");
      }

      final request = http.MultipartRequest("POST", url)
        ..files.add(await http.MultipartFile.fromPath("foto", imagePath));

      logger.i("📦 [REQUEST] File siap dikirim (${await file.length()} bytes)");

      final streamedResponse = await request.send();
      final resBody = await streamedResponse.stream.bytesToString();

      logger.i("📥 [RESPONSE] Status: ${streamedResponse.statusCode}");
      logger.i("🧾 Body: ${resBody.length > 400 ? resBody.substring(0, 400) + '...' : resBody}");

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(resBody);
        final kategori = data["kategori_prediksi"];
        final akurasi = data["akurasi"] ?? "-";
        logger.i("✅ [SUCCESS] Prediksi: $kategori | Akurasi: $akurasi");
        return kategori;
      } else {
        logger.w("⚠️ [FAILED] Status: ${streamedResponse.statusCode} | Body: $resBody");
        throw Exception("Gagal prediksi (${streamedResponse.statusCode})");
      }
    } catch (e, s) {
      logger.e("❌ [ERROR] Terjadi kesalahan saat prediksi", error: e, stackTrace: s);
      return null;
    }
  }

  // ============================================================
  // 🚀 FETCH SEMUA BARANG
  // ============================================================
  Future<List<dynamic>> fetchBarang() async {
    final url = Uri.parse("$baseUrl/barang");
    final token = await _getToken();

    final headers = {'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';

    try {
      logger.i("🌐 [REQUEST] GET $url");
      final res = await http.get(url, headers: headers);
      logger.i("📥 [RESPONSE] ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat barang (${res.statusCode})');
      }
    } catch (e, s) {
      logger.e("❌ [ERROR] fetchBarang gagal", error: e, stackTrace: s);
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  // ============================================================
  // 🚀 FETCH BARANG USER
  // ============================================================
  Future<List<dynamic>> fetchUserBarang() async {
    final url = Uri.parse("$baseUrl/barang/user");
    final token = await _getToken();

    if (token == null) throw Exception('Sesi login habis. Silakan login ulang.');

    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      logger.i("🌐 [REQUEST] GET $url");
      final res = await http.get(url, headers: headers);
      logger.i("📥 [RESPONSE] ${res.statusCode}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat barang saya (${res.statusCode})');
      }
    } catch (e, s) {
      logger.e("❌ [ERROR] fetchUserBarang gagal", error: e, stackTrace: s);
      throw Exception('Gagal menghubungkan ke server');
    }
  }
}
