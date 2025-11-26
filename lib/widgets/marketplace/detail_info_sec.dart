import 'package:flutter/material.dart';

// 1. INFO UTAMA (Harga, Nama, Rating)
class MainInfoSection extends StatelessWidget {
  final String nama;
  final String hargaFmt;
  final Color jawaraColor;

  const MainInfoSection({
    super.key,
    required this.nama,
    required this.hargaFmt,
    required this.jawaraColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hargaFmt, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: jawaraColor)),
          const SizedBox(height: 8),
          Text(nama, style: const TextStyle(fontSize: 16, height: 1.3, color: Colors.black87)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.star, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 4),
              const Text("4.8", style: TextStyle(fontSize: 12)),
              const SizedBox(width: 8),
              Container(height: 12, width: 1, color: Colors.grey),
              const SizedBox(width: 8),
              Text("Terjual 100+", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}

// 2. INFO PENJUAL
class SellerInfoSection extends StatelessWidget {
  final String penjual;
  final String alamat;
  final Color jawaraColor;

  const SellerInfoSection({
    super.key,
    required this.penjual,
    required this.alamat,
    required this.jawaraColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informasi Penjual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                radius: 12, backgroundColor: Colors.grey,
                child: Icon(Icons.store, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  penjual,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Colors.grey),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Dikirim dari", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 2),
                    Text(alamat, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. SPESIFIKASI PRODUK
class ProductSpecsSection extends StatelessWidget {
  final String kategori;
  final String stok;

  const ProductSpecsSection({super.key, required this.kategori, required this.stok});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Detail Produk", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          _buildDetailRow("Kategori", kategori),
          _buildDetailRow("Stok", stok),
          _buildDetailRow("Kondisi", "Baru"),
        ],
      ),
    );
  }
}