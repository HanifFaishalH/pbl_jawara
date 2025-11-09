import 'package:flutter/material.dart';

class TagihIuranHeader extends StatelessWidget {
  const TagihIuranHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Tagih Iuran ke Semua Keluarga Aktif",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tagihan akan dikirim ke semua keluarga yang aktif dalam sistem",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
