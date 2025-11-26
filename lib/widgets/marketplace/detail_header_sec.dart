import 'package:flutter/material.dart';
import 'detail_helpers.dart';

class DetailHeaderSection extends StatelessWidget {
  final String status;
  final String namaPenjual;
  final String alamatPenjual;

  const DetailHeaderSection({
    super.key,
    required this.status,
    required this.namaPenjual,
    required this.alamatPenjual,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. STATUS HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          color: DetailHelpers.getStatusColor(status),
          child: Row(
            children: [
              Icon(DetailHelpers.getStatusIcon(status), color: Colors.white, size: 30),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pesanan ${status[0].toUpperCase()}${status.substring(1).replaceAll('_', ' ')}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text("Terima kasih telah berbelanja", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),

        // 2. INFO PENJUAL & ALAMAT
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade200, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, color: Colors.black87, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(namaPenjual, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(height: 1)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Lokasi Pengambilan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text(alamatPenjual, style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.3)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}