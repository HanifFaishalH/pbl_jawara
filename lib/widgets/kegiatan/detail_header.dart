import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart'; // 

class DetailHeader extends StatelessWidget {
  final String? fotoPath;

  const DetailHeader({super.key, this.fotoPath});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Base URL otomatis dari AuthService (sama kayak BarangService)
    // Logika: Ambil AuthService.baseUrl (misal .../api) lalu ganti '/api' jadi '/storage/'
    final String baseImageUrl = AuthService.baseUrl.replaceAll('/api', '/storage/');
    
    // 2. Cek apakah fotoPath kosong, URL internet, atau path lokal server
    String finalUrl = "";
    if (fotoPath != null && fotoPath!.isNotEmpty) {
      if (fotoPath!.startsWith('http')) {
        finalUrl = fotoPath!; // Jika sudah http (misal dari Google)
      } else {
        // Jika path dari server (misal "kegiatan/foto1.jpg")
        // Hapus slash di depan jika ada, biar rapi
        String cleanPath = fotoPath!.startsWith('/') ? fotoPath!.substring(1) : fotoPath!;
        finalUrl = "$baseImageUrl$cleanPath";
      }
    }

    return SliverAppBar(
      // ... (Kode UI SliverAppBar ke bawah tetap sama persis) ...
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
             // Logika tampilan gambar
             finalUrl.isNotEmpty
              ? Image.network(
                  finalUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                )
              : Container(
                  color: Colors.grey[300], 
                  child: const Icon(Icons.image, size: 50, color: Colors.grey)
                ),
            // Gradient Overlay (Pemanis)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black45, Colors.transparent],
                  stops: [0.0, 0.3],
                ),
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => context.pop(),
      ),
    );
  }
}