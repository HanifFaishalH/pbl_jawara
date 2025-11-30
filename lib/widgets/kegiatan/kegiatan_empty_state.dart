import 'package:flutter/material.dart';

class KegiatanEmptyState extends StatelessWidget {
  const KegiatanEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "Belum ada kegiatan",
            style: TextStyle(
              fontSize: 18, 
              color: Colors.grey[600], 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tarik ke bawah untuk memuat ulang",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}