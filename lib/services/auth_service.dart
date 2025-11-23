import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:8000/api";
  static String? token;

  static void setToken(String newToken) {
    token = newToken;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      setToken(data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  Future<void> logout() async {
    final url = Uri.parse("$baseUrl/logout");

    await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    token = null;
  }

  Future<Map<String, dynamic>> me() async {
    final url = Uri.parse("$baseUrl/me");

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data user');
    }
  }
}
