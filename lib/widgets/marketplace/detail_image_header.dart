import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class DetailImageHeader extends StatelessWidget {
  final String fotoUrl;

  const DetailImageHeader({super.key, required this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    // Logic URL Gambar
    String finalUrl = "";
    if (fotoUrl.isNotEmpty) {
      if (!fotoUrl.startsWith('http')) {
        finalUrl = "${BarangService.baseImageUrl}$fotoUrl";
      } else {
        finalUrl = fotoUrl;
      }
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1, 
          child: Container(
            color: Colors.grey[200],
            child: finalUrl.isNotEmpty
                ? Image.network(finalUrl, fit: BoxFit.cover)
                : const Center(child: Icon(Icons.image, size: 60, color: Colors.grey)),
          ),
        ),
        // Tombol Back Melayang
        Positioned(
          top: 10,
          left: 10,
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ],
    );
  }
}