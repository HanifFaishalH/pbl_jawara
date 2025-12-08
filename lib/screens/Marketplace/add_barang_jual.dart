import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/kategori_service.dart';
import '../../services/barang_service.dart';

class AddBarangScreen extends StatefulWidget {
  const AddBarangScreen({super.key});

  @override
  State<AddBarangScreen> createState() => _AddBarangScreenState();
}

class _AddBarangScreenState extends State<AddBarangScreen> {
  int _currentStep = 0;
  String? _imagePath;

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  String _kategoriOtomatis = "-"; // hasil ML
  String _alamatPengguna = "(memuat alamat...)";
  int? _kategoriId;
  bool _loadingUpload = false;
  bool _loadingKategori = false;
  List<Map<String, dynamic>> _kategoriList = [];

  @override
  void initState() {
    super.initState();
    _loadUserAddress();
    _loadKategori();
  }

  Future<void> _loadUserAddress() async {
    try {
      await AuthService.loadSession();
      final data = await AuthService().me();
      final user = data['user'] ?? data;
      final alamat = user['user_alamat'] ?? user['alamat'] ?? 'Alamat belum diisi';
      setState(() => _alamatPengguna = alamat.toString());
    } catch (e) {
      setState(() => _alamatPengguna = 'Gagal memuat alamat');
    }
  }

  Future<void> _loadKategori() async {
    setState(() => _loadingKategori = true);
    try {
      final items = await KategoriService.fetchKategori();
      setState(() => _kategoriList = items);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat kategori: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loadingKategori = false);
    }
  }

  // 🔹 Ambil foto barang dan kirim ke API prediksi
  Future<void> _takePicture() async {
    final path = await context.push<String>('/camera');
    if (!mounted) return;

    if (path != null) {
      setState(() {
        _imagePath = path;
        _currentStep = 1;
        _kategoriOtomatis = "Menganalisis gambar...";
      });

      try {
        final predictedKategori = await BarangService().predictKategori(path);
        if (!mounted) return;

        setState(() {
          _kategoriOtomatis = predictedKategori ?? "Tidak terdeteksi";
          // Opsional: Mapping nama kategori ke kategori_id di dropdown
          final match = _kategoriList.firstWhere(
            (k) => k['kategori_nama']?.toString().toLowerCase() ==
                   predictedKategori?.toLowerCase(),
            orElse: () => {},
          );
          if (match.isNotEmpty) _kategoriId = match['kategori_id'] as int?;
        });
      } catch (e) {
        setState(() => _kategoriOtomatis = "Gagal memprediksi");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prediksi gagal: $e')),
        );
      }
    }
  }

  // 🔹 Upload data barang
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
        ..fields['barang_deskripsi'] = ''
        ..files.add(await http.MultipartFile.fromPath('foto', _imagePath!));

      if (_kategoriId != null) {
        request.fields['kategori_id'] = _kategoriId.toString();
      }

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
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loadingUpload = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text("Tambah Barang", style: TextStyle(color: Colors.white)),
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
            if (_currentStep == 0)
              _buildStepAmbilGambar(theme, colorScheme)
            else
              _buildStepIsiForm(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildStepAmbilGambar(ThemeData theme, ColorScheme colorScheme) {
    return Column(
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
                Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text("Kamera Preview Placeholder",
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
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
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIsiForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_imagePath!), height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _namaController,
          decoration: const InputDecoration(labelText: "Nama Barang", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hargaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Harga (Contoh: 500000)", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _stokController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Stok", border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),

        // 🔹 Tampilkan hasil prediksi ML
        Text("Kategori (Identifikasi ML):", style: theme.textTheme.bodyLarge),
        Text(
          _kategoriOtomatis,
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.green.shade700),
        ),
        const SizedBox(height: 16),

        InputDecorator(
          decoration: const InputDecoration(labelText: 'Kategori Manual', border: OutlineInputBorder()),
          child: _loadingKategori
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: _kategoriId,
                    hint: const Text('Pilih kategori'),
                    items: _kategoriList.map((k) {
                      return DropdownMenuItem<int?>(
                        value: k['kategori_id'] as int?,
                        child: Text(k['kategori_nama']?.toString() ?? 'Tidak diketahui'),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _kategoriId = val),
                  ),
                ),
        ),
        const SizedBox(height: 20),

        Text("Alamat Penjual:", style: theme.textTheme.bodyLarge),
        Text(_alamatPengguna, style: theme.textTheme.titleMedium),
        const SizedBox(height: 30),

        ElevatedButton.icon(
          onPressed: _loadingUpload ? null : _uploadBarang,
          icon: _loadingUpload
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.cloud_upload, color: Colors.white),
          label: Text(_loadingUpload ? "Mengunggah..." : "Upload Barang"),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
