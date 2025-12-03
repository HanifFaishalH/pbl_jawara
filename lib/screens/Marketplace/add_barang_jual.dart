import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class AddBarangScreen extends StatefulWidget {
  const AddBarangScreen({super.key});

  @override
  State<AddBarangScreen> createState() => _AddBarangScreenState();
}

class _AddBarangScreenState extends State<AddBarangScreen> {
  // State untuk melacak langkah form (0: Ambil Gambar, 1: Isi Form)
  int _currentStep = 0;
  // Placeholder untuk status gambar
  String? _imagePath;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  // Data dummy yang akan diisi otomatis
  String _kategoriOtomatis = "Perabotan"; // Placeholder hasil ML (belum mapping ke kategori_id)
  String _alamatPengguna = "(memuat alamat...)"; // Akan diisi dari /me
  int? _kategoriId; // Jika nanti ML memetakan ke ID kategori
  bool _loadingUpload = false;

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
  }

  Future<void> _loadUserAddress() async {
    try {
      await AuthService.loadSession();
      final data = await AuthService().me();
      setState(() {
        _alamatPengguna = (data['user_alamat'] ?? 'Alamat belum diisi') as String;
      });
    } catch (e) {
      setState(() {
        _alamatPengguna = 'Gagal memuat alamat';
      });
    }
  }

  // Fungsi placeholder untuk simulasi ambil gambar
  Future<void> _takePicture() async {
    // Buka kamera dan tunggu hasil path
    final path = await context.push<String>('/camera');
    if (!mounted) return;
    if (path != null) {
      setState(() {
        _imagePath = path;
        _currentStep = 1;
      });
    }
  }

  // Fungsi untuk mengunggah barang
  Future<void> _uploadBarang() async {
    if (_loadingUpload) return;
    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field & foto harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loadingUpload = true);
    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ada, silakan login ulang');

      final uri = Uri.parse('${AuthService.baseUrl}/barang');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['barang_nama'] = _namaController.text
        ..fields['barang_harga'] = _hargaController.text
        ..fields['barang_stok'] = _stokController.text
        ..fields['barang_deskripsi'] = '';
      if (_kategoriId != null) {
        request.fields['kategori_id'] = _kategoriId.toString();
      }
      request.files.add(await http.MultipartFile.fromPath('foto', _imagePath!));

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();
      if (streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang ${_namaController.text} berhasil diunggah!"),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal upload (${streamed.statusCode}): $responseBody"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingUpload = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Tambah Barang",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _currentStep == 0
                  ? "Langkah 1: Ambil Gambar Barang"
                  : "Langkah 2: Isi Detail Barang",
              style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // --- Langkah 1: Ambil Gambar ---
            if (_currentStep == 0)
              Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 80,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Kamera Preview Placeholder",
                            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text("Ambil Foto Barang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            // --- Langkah 2: Isi Form Detail ---
            if (_currentStep == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview gambar jika ada
                  if (_imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagePath!),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.secondary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Text(
                          "Foto Barang Sudah Diambil",
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Form Input
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(
                      labelText: "Nama Barang",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Harga (Contoh: 500000)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Stok",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Kategori Otomatis
                  Text(
                    "Kategori (Identifikasi ML):",
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    _kategoriOtomatis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.green.shade700),
                  ),
                  const SizedBox(height: 10),
                  // Alamat Otomatis
                  Text(
                    "Alamat Penjual (Data Pengguna):",
                    style: theme.textTheme.bodyLarge,
                  ),
                  Text(
                    _alamatPengguna,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  // Button Upload
                  ElevatedButton.icon(
                    onPressed: _loadingUpload ? null : _uploadBarang,
                    icon: _loadingUpload
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.cloud_upload, color: Colors.white),
                    label: Text(_loadingUpload ? "Mengunggah..." : "Upload Barang"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}