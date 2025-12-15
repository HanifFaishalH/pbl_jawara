import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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
  String? _serverImageUrl;
  String? _serverImagePath;

  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  String _kategoriOtomatis = "-";
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

  // ============================================================
  // 🔹 Load alamat user dari AuthService
  // ============================================================
  Future<void> _loadUserAddress() async {
    try {
      await AuthService.loadSession();
      final data = await AuthService().me();
      final user = data['user'] ?? {};
      final alamat = user['user_alamat'] ?? 'Alamat belum diisi';
      setState(() => _alamatPengguna = alamat.toString());
    } catch (e) {
      setState(() => _alamatPengguna = 'Gagal memuat alamat');
    }
  }

  // ============================================================
  // 🔹 Ambil daftar kategori dari API
  // ============================================================
  Future<void> _loadKategori() async {
    setState(() => _loadingKategori = true);
    try {
      final items = await KategoriService.fetchKategori();
      setState(() => _kategoriList = items);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loadingKategori = false);
    }
  }

  // ============================================================
  // 📸 Ambil foto dan kirim ke API prediksi (Laravel + FastAPI)
  // ============================================================
  Future<void> _takePicture() async {
    final path = await context.push<String>('/camera');
    if (!mounted || path == null) return;

    setState(() {
      _imagePath = path;
      _currentStep = 1;
      _kategoriOtomatis = "Menganalisis gambar...";
    });

    try {
      final data = await BarangService().predictKategori(path);
      if (data == null) throw Exception("Tidak ada hasil dari server");

      final kategori = data["kategori_prediksi"] ?? "Tidak terdeteksi";
      final imageUrl = data["image_url"];
      final storagePath = data["path"];

      setState(() {
        _kategoriOtomatis = kategori;
        _serverImageUrl = imageUrl;
        _serverImagePath = storagePath;

        // 🔹 Cocokkan kategori otomatis dengan dropdown
        final match = _kategoriList.firstWhere(
          (k) =>
              k['kategori_nama']?.toString().toLowerCase() ==
              kategori.toLowerCase(),
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

  // ============================================================
  // �️ Ambil gambar dari galeri HP
  // ============================================================
  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile == null) return;

      setState(() {
        _imagePath = pickedFile.path;
        _currentStep = 1;
        _kategoriOtomatis = "Menganalisis gambar...";
      });

      try {
        final data = await BarangService().predictKategori(pickedFile.path);
        if (data == null) throw Exception("Tidak ada hasil dari server");

        final kategori = data["kategori_prediksi"] ?? "Tidak terdeteksi";
        final imageUrl = data["image_url"];
        final storagePath = data["path"];

        setState(() {
          _kategoriOtomatis = kategori;
          _serverImageUrl = imageUrl;
          _serverImagePath = storagePath;

          // 🔹 Cocokkan kategori otomatis dengan dropdown
          final match = _kategoriList.firstWhere(
            (k) =>
                k['kategori_nama']?.toString().toLowerCase() ==
                kategori.toLowerCase(),
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka galeri: $e')),
      );
    }
  }

  // ============================================================
  // �🚀 Upload data barang ke Laravel
  // ============================================================
  Future<void> _uploadBarang() async {
    if (_loadingUpload) return;

    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty ||
        _serverImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi semua field dan ambil foto dulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loadingUpload = true);

    try {
      await AuthService.loadSession();
      final token = AuthService.token;
      if (token == null) throw Exception('Token tidak ada');

      final uri = Uri.parse('${AuthService.baseUrl}/barang');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Accept'] = 'application/json'
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['barang_nama'] = _namaController.text
        ..fields['barang_harga'] = _hargaController.text
        ..fields['barang_stok'] = _stokController.text
        ..fields['barang_deskripsi'] =
            'Prediksi kategori: $_kategoriOtomatis'
        ..fields['foto_path'] = _serverImagePath!; // 🔥 gunakan path server

      if (_kategoriId != null) {
        request.fields['kategori_id'] = _kategoriId.toString();
      }

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang berhasil diunggah"),
            backgroundColor: Colors.green,
          ),
        );
        if (mounted) context.pop();
      } else {
        throw Exception("Gagal upload: $body");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _loadingUpload = false);
    }
  }

  // ============================================================
  // 🧱 UI: Struktur halaman
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          "Tambah Barang",
          style: TextStyle(color: Colors.white),
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
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
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

  // ============================================================
  // 📸 Step 1: Ambil Gambar
  // ============================================================
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
                Icon(Icons.camera_alt_outlined,
                    size: 80, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text(
                  "Kamera Preview Placeholder",
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text("Ambil Foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.image_outlined, color: Colors.white),
                label: const Text("Dari Galeri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // 🧾 Step 2: Isi Form Barang
  // ============================================================
  Widget _buildStepIsiForm(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_imagePath!),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        const SizedBox(height: 20),

        // Nama Barang
        TextFormField(
          controller: _namaController,
          decoration: const InputDecoration(
            labelText: "Nama Barang",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Harga
        TextFormField(
          controller: _hargaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Harga (Contoh: 500000)",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Stok
        TextFormField(
          controller: _stokController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Stok",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // 🔹 Hasil prediksi ML
        Text("Kategori (Identifikasi ML):", style: theme.textTheme.bodyLarge),
        Text(
          _kategoriOtomatis,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 20),

        // Alamat Penjual
        Text("Alamat Penjual:", style: theme.textTheme.bodyLarge),
        Text(_alamatPengguna, style: theme.textTheme.titleMedium),
        const SizedBox(height: 30),

        // Tombol Upload Barang
        ElevatedButton.icon(
          onPressed: _loadingUpload ? null : _uploadBarang,
          icon: _loadingUpload
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.cloud_upload, color: Colors.white),
          label:
              Text(_loadingUpload ? "Mengunggah..." : "Upload Barang"),
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
    );
  }
}
