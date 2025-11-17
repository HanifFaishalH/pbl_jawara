import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailRiwayatPesananPage extends StatelessWidget {
  // Data pesanan yang dilewatkan dari halaman sebelumnya
  final Map<String, dynamic> pesanan;

  const DetailRiwayatPesananPage({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Map<String, dynamic>> items = pesanan['items'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Detail Pesanan",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Kembali ke RiwayatPesananPage
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detail Pesanan
            _buildInfoCard(
              context,
              title: "Informasi Pesanan",
              children: [
                _buildDetailRow(context, "ID Pesanan:", pesanan['id_pesanan']),
                _buildDetailRow(context, "Tanggal Transaksi:", pesanan['tanggal']),
                _buildDetailRow(context, "Status:", pesanan['status'],
                    isImportant: true,
                    textColor: _getStatusColor(pesanan['status'] as String)),
              ],
            ),
            const SizedBox(height: 16),
            // Detail Item
            Text(
              "Daftar Item (${items.length} Barang)",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...items.map((item) => _buildItemTile(context, item)).toList(),
            const SizedBox(height: 16),
            // Total Pembayaran
            _buildTotalCard(
              context,
              total: pesanan['total_harga'],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan baris detail
  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isImportant = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item di pesanan
  Widget _buildItemTile(BuildContext context, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['nama'] as String,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              _buildDetailRow(context, "Harga Satuan:", item['harga'] as String),
              _buildDetailRow(context, "Jumlah:", "x${item['jumlah']}"),
              _buildDetailRow(context, "Penjual:", item['penjual'] as String),
            ],
          ),
        ),
      ),
    );
  }

  // Widget card umum
  Widget _buildInfoCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  // Widget card total
  Widget _buildTotalCard(BuildContext context, {required String total}) {
    return _buildInfoCard(
      context,
      title: "Ringkasan Pembayaran",
      children: [
        _buildDetailRow(context, "Total Pembayaran:", total,
            isImportant: true,
            textColor: Theme.of(context).colorScheme.primary),
      ],
    );
  }

  // Fungsi helper untuk menentukan warna status (sama seperti di RiwayatPesananPage)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.orange;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}