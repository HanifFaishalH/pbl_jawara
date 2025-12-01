import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'auth_service.dart';

class ChannelTransferService {
  final String baseUrl = AuthService.baseUrl;

  Future<List<dynamic>> getChannels() async {
    final response = await http.get(
      Uri.parse("$baseUrl/channel-transfer"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    }
    throw Exception('Gagal load data');
  }

  Future<Map<String, dynamic>> getChannelById(int id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/channel-transfer/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal load data');
  }

  Future<bool> saveChannel({
    required Map<String, String> fields,
    XFile? qrFile,
    XFile? thumbnailFile,
    int? id,
  }) async {
    final url = id == null
        ? Uri.parse("$baseUrl/channel-transfer")
        : Uri.parse("$baseUrl/channel-transfer/$id");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer ${AuthService.token}';
    request.headers['Accept'] = 'application/json';

    if (id != null) request.fields['_method'] = 'PUT';

    request.fields.addAll(fields);

    // Upload QR jika ada
    if (qrFile != null) {
      final bytes = await qrFile.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'qr',
        bytes,
        filename: qrFile.name,
      );
      request.files.add(multipartFile);
    }

    // Upload Thumbnail jika ada
    if (thumbnailFile != null) {
      final bytes = await thumbnailFile.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'thumbnail',
        bytes,
        filename: thumbnailFile.name,
      );
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 201) {
        final respStr = await response.stream.bytesToString();
        print("Server Error: $respStr");
      }
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    }
  }

  Future<bool> deleteChannel(int id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/channel-transfer/$id"),
      headers: {'Authorization': 'Bearer ${AuthService.token}'},
    );
    return response.statusCode == 200;
  }
}
