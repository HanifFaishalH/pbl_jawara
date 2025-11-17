import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddBarangScreen extends StatefulWidget {
  const AddBarangScreen({super.key});

  @override
  State<AddBarangScreen> createState() => _AddBarangScreenState();
}

class _AddBarangScreenState extends State<AddBarangScreen> {
  // State untuk melacak langkah form (0: Ambil Gambar, 1: Isi Form)
  int _currentStep = 0;
  // Placeholder untuk status gambar
  bool _isImageTaken = false;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  // Data dummy yang akan diisi otomatis
  String _kategoriOtomatis = "Perabotan"; // Hasil Machine Learning
  String _alamatPengguna = "Jl. Mawar No. 5, Jakarta"; // Data Pengguna

  // Fungsi placeholder untuk simulasi ambil gambar
  void _takePicture() {
    // TODO: Implementasi Camera
    setState(() {
      _isImageTaken = true;
      _currentStep = 1; // Lanjut ke langkah isi form
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Gambar berhasil diambil (simulasi)"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Fungsi untuk mengunggah barang
  void _uploadBarang() {
    if (_namaController.text.isEmpty ||
        _hargaController.text.isEmpty ||
        _stokController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implementasi logika upload ke database

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Barang ${_namaController.text} berhasil diunggah!"),
        backgroundColor: Colors.green,
      ),
    );

    // Kembali ke Daftar Barang
    context.pop();
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
                  // Gambar yang sudah diambil (Placeholder)
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
                    onPressed: _uploadBarang,
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: const Text("Upload Barang"),
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