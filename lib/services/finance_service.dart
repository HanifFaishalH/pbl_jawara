import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/services/auth_service.dart';

class FinanceService {
  static Map<String, String> _authHeaders() => {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${AuthService.token}',
      };

  static Future<Map<String, dynamic>> listPemasukan({
    int page = 1,
    String? q,
    String? from,
    String? to,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pemasukan').replace(
      queryParameters: {
        'page': '$page',
        if (q != null && q.isNotEmpty) 'q': q,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
    );
    final res = await http.get(uri, headers: _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat pemasukan (${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> listPengeluaran({
    int page = 1,
    String? q,
    String? from,
    String? to,
  }) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pengeluaran').replace(
      queryParameters: {
        'page': '$page',
        if (q != null && q.isNotEmpty) 'q': q,
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
    );
    final res = await http.get(uri, headers: _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat pengeluaran (${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> ringkasan({String? from, String? to}) async {
    final uri = Uri.parse('${AuthService.baseUrl}/laporan/ringkasan').replace(
      queryParameters: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
      },
    );
    final res = await http.get(uri, headers: _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat ringkasan (${res.statusCode})');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<void> createPemasukan(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pemasukan');
    final res = await http.post(uri, headers: _authHeaders(), body: payload);
    if (res.statusCode != 201) {
      throw Exception('Gagal menambah pemasukan');
    }
  }

  static Future<void> createPengeluaran(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pengeluaran');
    final res = await http.post(uri, headers: _authHeaders(), body: payload);
    if (res.statusCode != 201) {
      throw Exception('Gagal menambah pengeluaran');
    }
  }

  static Future<void> updatePemasukan(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pemasukan/$id');
    final res = await http.put(uri, headers: _authHeaders(), body: payload);
    if (res.statusCode != 200) {
      throw Exception('Gagal mengubah pemasukan');
    }
  }

  static Future<void> updatePengeluaran(int id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pengeluaran/$id');
    final res = await http.put(uri, headers: _authHeaders(), body: payload);
    if (res.statusCode != 200) {
      throw Exception('Gagal mengubah pengeluaran');
    }
  }

  static Future<void> deletePemasukan(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pemasukan/$id');
    final res = await http.delete(uri, headers: _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus pemasukan');
    }
  }

  static Future<void> deletePengeluaran(int id) async {
    final uri = Uri.parse('${AuthService.baseUrl}/pengeluaran/$id');
    final res = await http.delete(uri, headers: _authHeaders());
    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus pengeluaran');
    }
  }
}
