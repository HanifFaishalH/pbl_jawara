import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class IuranService {
  static IuranService? _instance;
  static IuranService get instance => _instance ??= IuranService._();
  
  IuranService._();

  static String get baseUrl => AuthService.baseUrl;

  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
      };

  // 1. Tarik Iuran (Admin/Bendahara)
  Future<bool> tarikIuran({
    required int kategoriId,
    required int nominal,
    required String jatuhTempo,
    required String targetType, // 'all', 'rt', 'keluarga', 'warga'
    List<int>? targetIds,
    String? keterangan,
  }) async {
    try {
      final body = jsonEncode({
        'kategori_id': kategoriId,
        'nominal': nominal,
        'jatuh_tempo': jatuhTempo,
        'target_type': targetType,
        if (targetIds != null) 'target_ids': targetIds,
        if (keterangan != null) 'keterangan': keterangan,
      });

      print('Tarik Iuran Request: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/iuran/tarik'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error Tarik Iuran: $e");
      return false;
    }
  }

  // 2. List Tagihan (Admin/Bendahara)
  Future<Map<String, dynamic>> listTagihan({
    String? status,
    int? kategoriId,
    String? dariTanggal,
    String? sampaiTanggal,
    String? q,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (kategoriId != null) queryParams['kategori_id'] = kategoriId.toString();
      if (dariTanggal != null) queryParams['dari_tanggal'] = dariTanggal;
      if (sampaiTanggal != null) queryParams['sampai_tanggal'] = sampaiTanggal;
      if (q != null) queryParams['q'] = q;

      final uri = Uri.parse('$baseUrl/tagihan').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Gagal memuat tagihan (${response.statusCode})');
    } catch (e) {
      print("Error List Tagihan: $e");
      throw Exception('Error: $e');
    }
  }

  // 3. List Tagihan Saya (Warga)
  Future<Map<String, dynamic>> tagihanSaya({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('$baseUrl/tagihan/saya').replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      print('Tagihan Saya Response: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Gagal memuat tagihan (${response.statusCode})');
    } catch (e) {
      print("Error Tagihan Saya: $e");
      throw Exception('Error: $e');
    }
  }

  // 4. Bayar Tagihan (Upload Bukti - Warga)
  Future<bool> bayarTagihan({
    required int tagihanId,
    required File buktiTransfer,
    required int jumlahDibayar,
    required String tanggalBayar,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/tagihan/$tagihanId/bayar');
      
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Accept': 'application/json',
        if (AuthService.token != null) 'Authorization': 'Bearer ${AuthService.token}',
      });

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'bukti_transfer',
        buktiTransfer.path,
      ));

      // Add fields
      request.fields['jumlah_dibayar'] = jumlahDibayar.toString();
      request.fields['tanggal_bayar'] = tanggalBayar;

      print('Bayar Tagihan - ID: $tagihanId, Jumlah: $jumlahDibayar');

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error Bayar Tagihan: $e");
      return false;
    }
  }

  // 5. List Pembayaran Pending (Bendahara)
  Future<Map<String, dynamic>> listPembayaranPending() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pembayaran/pending'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Gagal memuat pembayaran (${response.statusCode})');
    } catch (e) {
      print("Error List Pembayaran Pending: $e");
      throw Exception('Error: $e');
    }
  }

  // 6. Verifikasi Pembayaran (Bendahara)
  Future<bool> verifikasiPembayaran({
    required int pembayaranId,
    required String statusVerifikasi, // 'Diterima' atau 'Ditolak'
    String? catatanVerifikasi,
  }) async {
    try {
      final body = jsonEncode({
        'status_verifikasi': statusVerifikasi,
        if (catatanVerifikasi != null) 'catatan_verifikasi': catatanVerifikasi,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/pembayaran/$pembayaranId/verifikasi'),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 15));

      print('Verifikasi Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['success'] == true;
      }
      return false;
    } catch (e) {
      print("Error Verifikasi Pembayaran: $e");
      return false;
    }
  }
}
