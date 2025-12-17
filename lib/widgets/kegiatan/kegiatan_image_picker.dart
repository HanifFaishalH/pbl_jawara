import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart'; // ⚠️ Pastikan path ini sesuai dengan struktur folder kamu

class KegiatanImagePicker extends StatelessWidget {
  final String? initialUrl;      // URL foto dari database (untuk mode edit)
  final XFile? newImageFile;     // File foto baru yang dipilih dari galeri
  final VoidCallback onPickImage; // Fungsi saat diklik

  const KegiatanImagePicker({
    super.key,
    this.initialUrl,
    this.newImageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    // 🛠️ LOGIKA URL DINAMIS (Mengikuti IP dari AuthService)
    // Mengubah ".../api" menjadi ".../storage/"
    final String baseImageUrl = AuthService.baseUrl.replaceAll('/api', '/storage/');
    
    String finalOldUrl = "";
    if (initialUrl != null && initialUrl!.isNotEmpty) {
      if (initialUrl!.startsWith('http')) {
        finalOldUrl = initialUrl!;
      } else {
        // Membersihkan slash di depan jika ada, misal "/kegiatan/foto.jpg" jadi "kegiatan/foto.jpg"
        String cleanPath = initialUrl!.startsWith('/') ? initialUrl!.substring(1) : initialUrl!;
        finalOldUrl = "$baseImageUrl$cleanPath";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dokumentasi / Banner", 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
        ),
        const SizedBox(height: 8),
        
        InkWell(
          onTap: onPickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: _buildImageContent(finalOldUrl),
          ),
        ),
        
        // Indikator jika ada foto baru yang dipilih tapi belum disave
        if (newImageFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  "Foto baru siap diupload", 
                  style: TextStyle(color: Colors.green[700], fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImageContent(String finalOldUrl) {
    // PRIORITAS 1: Tampilkan Foto Baru (Lokal) jika user baru saja memilih foto
    if (newImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: kIsWeb
            ? Image.network(newImageFile!.path, fit: BoxFit.cover) // Khusus Web
            : Image.file(File(newImageFile!.path), fit: BoxFit.cover), // Android/iOS
      );
    }

    // PRIORITAS 2: Tampilkan Foto Lama (Server) jika ada datanya
    if (finalOldUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              finalOldUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    const SizedBox(height: 4),
                    Text("Gagal memuat gambar", style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                  ],
                );
              },
            ),
            // Tombol edit kecil di pojok kanan atas
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }

    // PRIORITAS 3: Tampilkan Placeholder (Jika belum ada foto sama sekali)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text("Tap untuk upload foto", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}