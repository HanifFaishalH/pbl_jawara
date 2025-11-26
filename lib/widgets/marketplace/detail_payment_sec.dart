import 'package:flutter/material.dart';
import 'detail_helpers.dart';

class DetailPaymentSection extends StatelessWidget {
  final int totalHarga;
  final String kodeTransaksi;
  final String tanggal;

  const DetailPaymentSection({
    super.key,
    required this.totalHarga,
    required this.kodeTransaksi,
    required this.tanggal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // RINCIAN PEMBAYARAN
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rincian Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),
              _buildPaymentRow("Metode Pembayaran", "Tunai"),
              _buildPaymentRow("Total Harga Barang", DetailHelpers.formatRupiah(totalHarga)),
              _buildPaymentRow("Biaya Layanan", "Rp 0"),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Belanja", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(DetailHelpers.formatRupiah(totalHarga), 
                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: DetailHelpers.jawaraColor)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // INFO FAKTUR
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              _buildInfoRow("No. Pesanan", kodeTransaksi, context, canCopy: true),
              const SizedBox(height: 8),
              _buildInfoRow("Waktu Pemesanan", DetailHelpers.formatTanggal(tanggal), context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          Text(value, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context, {bool canCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Row(
          children: [
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
            if (canCopy)
              InkWell(
                onTap: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disalin"), duration: Duration(seconds: 1)));
                },
                child: const Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Text("SALIN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DetailHelpers.jawaraColor)),
                ),
              )
          ],
        )
      ],
    );
  }
}