import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class BarangService {
  // 🌐 Base URL API (ubah sesuai jaringan kamu)
  static String get baseUrl => "http://127.0.0.1:8000/api";
  static String get baseImageUrl => "http://127.0.0.1:8000/storage/";

  // 🧾 Logger instance (gunakan pretty printer untuk console)
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // sembunyikan trace pendek
      errorMethodCount: 5, // tampilkan stack saat error
      lineLength: 90, // panjang maksimum baris
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // 🔑 Ambil token login (dari AuthService atau SharedPreferences)
  Future<String?> _getToken() async {
    if (AuthService.token != null && AuthService.token!.isNotEmpty) {
      return AuthService.token;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) AuthService.token = token;
    return token;
  }

  // 🛰️ Logger untuk Request
  void _logRequest(String method, Uri url, Map<String, String>? headers, [dynamic body]) {
    if (!kDebugMode) return;
    _logger.i('''
🌐 [REQUEST] $method $url
📩 Headers : ${jsonEncode(headers)}
📦 Body    : ${body ?? '-'}
''');
  }

  // 📦 Logger untuk Response
  void _logResponse(http.Response res) {
    if (!kDebugMode) return;
    final shortBody = res.body.length > 400
        ? res.body.substring(0, 400) + '... [truncated]'
        : res.body;
    final color = (res.statusCode >= 200 && res.statusCode < 300)
        ? Level.info
        : Level.warning;

    _logger.log(
      color,
      '''
📦 [RESPONSE] ${res.request?.url}
📊 Status: ${res.statusCode}
🧾 Body  : $shortBody
''',
    );
  }

  // ❌ Logger untuk Error
  void _logError(Object e, [StackTrace? s]) {
    if (!kDebugMode) return;
    _logger.e('API Error: $e', stackTrace: s);
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
      _logRequest('GET', url, headers);
      final res = await http.get(url, headers: headers);
      _logResponse(res);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat barang (${res.statusCode})');
      }
    } catch (e, s) {
      _logError(e, s);
      throw Exception('Tidak dapat terhubung ke server');
    }
  }

  // ============================================================
  // 🚀 FETCH BARANG MILIK USER
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
      _logRequest('GET', url, headers);
      final res = await http.get(url, headers: headers);
      _logResponse(res);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat barang saya (${res.statusCode})');
      }
    } catch (e, s) {
      _logError(e, s);
      throw Exception('Gagal menghubungkan ke server');
    }
  }
}
