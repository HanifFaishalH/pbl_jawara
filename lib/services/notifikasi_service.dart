import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jawaramobile_1/services/auth_service.dart';

class NotifikasiService {
  final String baseUrl = AuthService.baseUrl;

  Future<List<dynamic>> getNotifikasi({bool? isRead}) async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final queryParams = <String, String>{};
      if (isRead != null) queryParams['is_read'] = isRead ? '1' : '0';

      final uri = Uri.parse('$baseUrl/notifikasi')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Gagal memuat notifikasi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getNotifikasi: $e');
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.get(
        Uri.parse('$baseUrl/notifikasi/unread-count'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['unread_count'] ?? 0;
      } else {
        throw Exception('Gagal memuat jumlah notifikasi');
      }
    } catch (e) {
      print('Error in getUnreadCount: $e');
      return 0;
    }
  }

  Future<bool> markAsRead(int notifikasiId) async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/$notifikasiId/mark-as-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error in markAsRead: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.post(
        Uri.parse('$baseUrl/notifikasi/mark-all-as-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error in markAllAsRead: $e');
      return false;
    }
  }

  Future<bool> deleteNotifikasi(int notifikasiId) async {
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ditemukan');

      final response = await http.delete(
        Uri.parse('$baseUrl/notifikasi/$notifikasiId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error in deleteNotifikasi: $e');
      return false;
    }
  }
}
