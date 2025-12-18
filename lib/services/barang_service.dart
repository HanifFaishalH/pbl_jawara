import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class BarangService {
  // 🌐 Base URL API Laravel
  static String baseUrl = AuthService.baseUrl;
  static String baseImageUrl = '${AuthService.baseUrl}/storage/';

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
  Future<Map<String, dynamic>?> predictKategori(String imagePath) async {
    final url = Uri.parse("${baseUrl}/predict-batik");
    logger.i("📤 [PREDICT] Upload foto ke Laravel...");

    try {
      final request = http.MultipartRequest("POST", url)
        ..files.add(await http.MultipartFile.fromPath("foto", imagePath));

      final streamedResponse = await request.send();
      final resBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(resBody);

        logger.i("✅ [SUCCESS] Prediksi: ${data['kategori_prediksi']}");
        logger.i("🖼 IMAGE URL: ${data['image_url']}");

        return data; // ⬅️ JANGAN DIUBAH
      } else {
        throw Exception("Gagal prediksi (${streamedResponse.statusCode})");
      }
    } catch (e, s) {
      logger.e("❌ [ERROR] Prediksi gagal", error: e, stackTrace: s);
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

  // 🔍 Cek apakah barang milik user yang login
  Future<bool> isBarangOwner(int barangId) async {
    try {
      await AuthService.loadSession();
      final token = await _getToken();
      if (token == null || token.isEmpty) return false;
      
      final url = Uri.parse('$baseUrl/barang/$barangId/is-owner');
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      logger.i("🌐 [REQUEST] GET ${url.toString()}");
      final res = await http.get(url, headers: headers);
      logger.i("📥 [RESPONSE] ${res.statusCode}");
      
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['is_owner'] ?? false;
      }
      return false;
    } catch (e, s) {
      logger.e("❌ [ERROR] isBarangOwner gagal", error: e, stackTrace: s);
      return false;
    }
  }
}
