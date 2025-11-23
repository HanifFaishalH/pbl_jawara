import 'dart:convert';
import 'package:http/http.dart' as http;

class BarangService {
  static const String BaseURl = "http://localhost:8000/api";
  static String? token;

  static void setToken(String newToken) {
    token = newToken;
  }

  Future<List<dynamic>> fetchBarang() async {
    final url = Uri.parse("$BaseURl/barang");
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer 1|UagdVk7KaS4LFoU6H6JMAgubK843mrXH3SKT0Mdl8b7eab0b'
      }
    );
    
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];      
    } else {
      throw Exception('Failed to load barang (${response.statusCode})');
    }
  }
}