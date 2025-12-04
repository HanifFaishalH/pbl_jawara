import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color primaryColor;

  const ProductCard({
    super.key, 
    required this.item, 
    required this.primaryColor
  });

  // Helper untuk format rupiah
  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Parsing Data Dasar
    final String nama = item['barang_nama']?.toString() ?? '-';
    final String hargaRaw = item['barang_harga']?.toString() ?? '0';
    final String hargaFormat = _formatRupiah(hargaRaw);
    final String stok = item['barang_stok']?.toString() ?? '0';
    final String idBarang = item['barang_id']?.toString() ?? '0';

    // 2. Parsing Foto
    String rawFoto = item['barang_foto']?.toString() ?? "";
    String finalFotoUrl = "";
    if (rawFoto.isNotEmpty) {
      if (!rawFoto.startsWith('http')) {
        finalFotoUrl = "${BarangService.baseImageUrl}$rawFoto";
      } else {
        finalFotoUrl = rawFoto;
      }
    }

    // 3. Parsing Nested Object: USER (Penjual)
    String namaPenjual = 'Penjual Jawara';
    String alamatPenjual = 'Kota Malang';

    if (item['user'] != null && item['user'] is Map) {
      String d = item['user']['user_nama_depan'] ?? '';
      String b = item['user']['user_nama_belakang'] ?? '';
      namaPenjual = "$d $b".trim();
      alamatPenjual = item['user']['user_alamat'] ?? 'Indonesia';
    }

    // 4. Parsing Nested Object: KATEGORI
    String kategoriBersih = '-';
    if (item['kategori'] != null && item['kategori'] is Map) {
        kategoriBersih = item['kategori']['kategori_nama'] ?? '-';
    } else if (item['kategori'] is String) {
        kategoriBersih = item['kategori'];
    }

    return InkWell(
      onTap: () {
        // PERSIAPAN DATA FLAT UNTUK DETAIL SCREEN
        // Detail screen mengharapkan Map<String, String> tanpa object bersarang
        final Map<String, String> dataDetail = {
          'id': idBarang,
          'nama': nama,
          'kategori': kategoriBersih,
          'harga': hargaRaw,
          'stok': stok,
          'deskripsi': item['barang_deskripsi']?.toString() ?? '-',
          'foto': finalFotoUrl,
          
          // Data Penjual yang sudah di-extract
          'nama_penjual': namaPenjual,
          'alamat_penjual': alamatPenjual,
        };
        
        context.push('/detail-barang-beli', extra: dataDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN GAMBAR
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: finalFotoUrl.isNotEmpty
                          ? Image.network(
                              finalFotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, _) => Container(
                                color: Colors.grey[100],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            )
                          : Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                        ),
                        child: const Text("Terlaris", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            
            // BAGIAN INFO TEKS
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hargaFormat,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                alamatPenjual, // Menggunakan alamat yang sudah diparsing
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber[700]),
                            const Text(" 4.8 ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Container(width: 1, height: 10, color: Colors.grey),
                            const Text(" Terjual 100+", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}