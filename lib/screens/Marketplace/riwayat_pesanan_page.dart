import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data dummy untuk riwayat pesanan
// Data 'Dibatalkan' telah dihapus
final List<Map<String, dynamic>> dummyRiwayatPesanan = [
  {
    "id_pesanan": "TRX001",
    "tanggal": "15 Nov 2025",
    "total_harga": "Rp 500.000",
    "status": "Selesai",
    "items": [
      {
        "nama": "Batik Tulis Parang Rusak",
        "harga": "Rp 350.000",
        "jumlah": 1,
        "penjual": "Kantor RW 05, Blok A, Malang",
      },
      {
        "nama": "Batik Cap Kawung",
        "harga": "Rp 150.000",
        "jumlah": 1,
        "penjual": "Kantor RW 05, Blok A, Malang",
      },
    ],
  },
  {
    "id_pesanan": "TRX002",
    "tanggal": "10 Nov 2025",
    "total_harga": "Rp 250.000",
    "status": "Diproses",
    "items": [
      {
        "nama": "Kemeja Batik Modern",
        "harga": "Rp 250.000",
        "jumlah": 1,
        "penjual": "Kantor RW 05, Blok A, Malang",
      },
    ],
  },
  // Data TRX003 (Dibatalkan) telah dihapus
];

class RiwayatPesananPage extends StatelessWidget {
  const RiwayatPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Pesanan Saya",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Kembali ke DaftarPembelian, atau bisa disesuaikan
          onPressed: () => context.go('/daftar-pembelian'), 
        ),
      ),
      body: dummyRiwayatPesanan.isEmpty
          ? const Center(
              child: Text("Belum ada riwayat pesanan."),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: dummyRiwayatPesanan.length,
              itemBuilder: (context, index) {
                final pesanan = dummyRiwayatPesanan[index];
                // Menggunakan fungsi _getStatusColor yang diperbarui
                final statusColor = _getStatusColor(pesanan['status'] as String);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      Icons.shopping_bag_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      "ID Pesanan: ${pesanan['id_pesanan']}",
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("Tanggal: ${pesanan['tanggal']}"),
                        Text(
                          "Total: ${pesanan['total_harga']}",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            pesanan['status'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigasi ke DetailRiwayatPesananPage dengan data pesanan
                      context.push('/detail-riwayat-pesanan', extra: pesanan);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Fungsi helper untuk menentukan warna status (Status 'Dibatalkan' dihapus)
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.orange;
      default:
        // Warna default jika ada status lain yang tidak terduga
        return Colors.grey;
    }
  }
}