import 'package:flutter/material.dart';
import 'card_barang.dart';

class SectionCard extends StatelessWidget {
  final List barangList;

  const SectionCard({
    super.key,
    required this.barangList,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: barangList.length,
      itemBuilder: (context, index) {
        final barang = barangList[index];
        return BarangCard(
          nama: barang['barang_nama'],
          kategori: barang['barang_kategori'],
          harga: barang['barang_harga'],
          foto: barang['barang_foto'],
        );
      },
    );
  }
}