import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/services/auth_service.dart';

class ActivityLogService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<dynamic>> getLogs({
    String? type,
    String? action,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = <String, String>{};
      if (type != null && type != 'semua') queryParams['type'] = type;
      if (action != null && action != 'semua') queryParams['action'] = action;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse('$baseUrl/activity-logs')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('Fetching logs from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat log activity: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getLogs: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLogDetail(int id) async {
    await AuthService.loadSession();
    final token = AuthService.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/activity-logs/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail log');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    await AuthService.loadSession();
    final token = AuthService.token;
    if (token == null) throw Exception('Token tidak ditemukan');

    final response = await http.get(
      Uri.parse('$baseUrl/activity-logs/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat statistik');
    }
  }
}
