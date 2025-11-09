import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/broadcast/broadcast_filter.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  // Data dummy
  final List<Map<String, String>> _broadcastData = const [
    {
      "pengirim": "Ahmad Suhendra",
      "judul": "Pemberitahuan Kerja Bakti",
      "isi":
          "Halo warga RT 05, pada Sabtu mendatang akan diadakan kerja bakti membersihkan lingkungan. Mohon partisipasinya ya!",
      "tanggal": "18 Okt 2025",
    },
    {
      "pengirim": "Siti Aminah",
      "judul": "Undangan Rapat Warga",
      "isi":
          "Yth. Warga RT 05, kami mengundang Anda untuk hadir dalam rapat warga yang akan dilaksanakan pada Minggu, 20 Oktober 2025 di Balai Warga pukul 10.00 WIB.",
      "tanggal": "18 Okt 2025",
    },
  ];

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Broadcast"),
          content: SingleChildScrollView(child: const BroadcastFilter()),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Cari"),
              onPressed: () {
                // TODO: Tambahkan logika filter
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus Broadcast ini? Aksi ini tidak dapat dibatalkan.",
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Hapus"),
              onPressed: () {
                // TODO: Implementasikan logika untuk menghapus data dari database/server
                Navigator.of(dialogContext).pop();
                context.pop(); // Kembali ke halaman daftar Broadcast
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast berhasil dihapus')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          "Broadcast",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        // Tambahkan tombol filter di sini
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tambah-broadcast'),
        child: const Icon(Icons.add),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            headingRowColor: MaterialStateProperty.all(
              theme.colorScheme.primary.withOpacity(0.1),
            ),
            headingTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
            columns: const [
              DataColumn2(label: Text('Judul')),
              DataColumn2(label: Text('Pengirim')),
            ],
            rows: _broadcastData.map((item) {
              return DataRow2(
                onTap: () {
                  context.push('/detail-broadcast', extra: item);
                },
                cells: [
                  DataCell(Text(item['judul']!)),
                  DataCell(Text(item['pengirim']!)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
