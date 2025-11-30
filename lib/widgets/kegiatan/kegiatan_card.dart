import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KegiatanCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onRefreshNeeded;

  const KegiatanCard({
    super.key,
    required this.item,
    required this.onRefreshNeeded,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final String nama = item['kegiatan_nama'] ?? 'Tanpa Nama';
    final String tanggal = item['kegiatan_tanggal'] ?? '-';
    final String lokasi = item['kegiatan_lokasi'] ?? '-';
    final String kategori = item['kegiatan_kategori'] ?? 'Umum';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          // Navigasi ke detail dan tunggu hasil
          final result = await context.push<bool>('/detail-kegiatan', extra: item);
          
          // Jika result true (misal ada penghapusan), panggil callback refresh
          if (result == true) {
            onRefreshNeeded();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      kategori,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        tanggal,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold,
                  height: 1.3, color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lokasi,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}