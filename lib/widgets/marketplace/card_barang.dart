import 'package:flutter/material.dart';

class BarangCard extends StatelessWidget {
  final String nama;
  final String kategori;
  final double harga;
  final String? foto;

  const BarangCard({
    super.key, 
    required this.nama, 
    required this.kategori, 
    required this.harga, 
    this.foto,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                foto ?? "https://www.freepik.com/icon/no-camera_4640752#fromView=keyword&page=1&position=1&uuid=b018820d-027c-4c5b-97ed-c11b3cf4fcd0",
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(kategori, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text("Rp $harga", style: const TextStyle(color: Colors.green)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}