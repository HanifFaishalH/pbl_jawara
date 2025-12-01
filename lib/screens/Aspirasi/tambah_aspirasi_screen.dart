import 'package:flutter/material.dart';
import '../../theme/AppTheme.dart';
import '../../services/aspirasi_service.dart';

class TambahAspirasiScreen extends StatefulWidget {
  const TambahAspirasiScreen({super.key});

  @override
  State<TambahAspirasiScreen> createState() => _TambahAspirasiScreenState();
}

class _TambahAspirasiScreenState extends State<TambahAspirasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  bool _isSubmitting = false;

  // --- FUNGSI BARU UNTUK MENAMPILKAN POPUP ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User wajib tekan OK
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Berhasil!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Aspirasi Anda telah terkirim.", textAlign: TextAlign.center),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Tutup Dialog
                  Navigator.of(context).pop(true); // Kembali ke Dashboard & Reload
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final success = await AspirasiService().createAspirasi(
        _judulController.text, 
        _descController.text
      );
      
      if (!mounted) return;

      if (success) {
        // PANGGIL POPUP SUKSES
        _showSuccessDialog(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim aspirasi.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ... (Sisa kode build method sama seperti sebelumnya)
  @override
  Widget build(BuildContext context) {
    // ... Copy paste bagian build dari kode sebelumnya ...
    // ... Agar tidak terlalu panjang, saya tidak menulis ulang UI build ...
    // ... Pastikan form dan tombol memanggil _submit ...
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tulis Aspirasi'),
        backgroundColor: AppTheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
               // ... Input Judul & Deskripsi (Sama seperti kode sebelumnya) ...
               
               TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(labelText: 'Judul Aspirasi', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Judul wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Isi Aspirasi', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 24),

               // Tombol Simpan
               SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Kirim Aspirasi', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}