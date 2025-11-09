import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/kegiatan/kegiatan_filter.dart';

class KegiatanScreen extends StatelessWidget {
  const KegiatanScreen({super.key});

  // Data dummy
  final List<Map<String, String>> _kegiatanData = const [
    {
      "nama": "Kerja Bakti Bulanan",
      "kategori": "Kebersihan & Keamanan",
      "pj": "Pak RT",
      "tanggal": "21 Oktober 2025",
      "lokasi": "Lingkungan RT 05",
      "deskripsi": "Membersihkan selokan dan area umum.",
    },
    {
      "nama": "Rapat Karang Taruna",
      "kategori": "Komunitas & Sosial",
      "pj": "Ketua Karang Taruna",
      "tanggal": "10 Oktober 2025",
      "lokasi": "Balai Desa Kidal",
      "deskripsi":
          "Pembubaran panitia PHBN sekaligus membahas rencana kegiatan akhir tahun.",
    },
    {
      "nama": "Jalan Sehat",
      "kategori": "Kesehatan & Olahraga",
      "pj": "Karang Taruna",
      "tanggal": "30 September 2025",
      "lokasi": "Lapangan SD Negeri Kidal",
      "deskripsi": "Jalan sehat, senam, dan pembagian doorprize.",
    },
    {
      "nama": "Upacara 17 Agustus",
      "kategori": "Komunitas & Sosial",
      "pj": "Karang Taruna",
      "tanggal": "17 Agustus 2025",
      "lokasi": "Candi Kidal",
      "deskripsi":
          "Upacara peringatan detik-detik proklamasi kemerdekaan Republik Indonesia.",
    },
    {
      "nama": "Seminar Warga",
      "kategori": "Pendidikan",
      "pj": "Kepala Desa",
      "tanggal": "17 Juli 2025",
      "lokasi": "Balai Desa Kidal",
      "deskripsi": "Seminar tentang bahaya judi online.",
    },
  ];

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Kegiatan"),
          content: SingleChildScrollView(child: const KegiatanFilter()),
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
            "Apakah Anda yakin ingin menghapus kegiatan ini? Aksi ini tidak dapat dibatalkan.",
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
                context.pop(); // Kembali ke halaman daftar kegiatan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kegiatan berhasil dihapus')),
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
          "Kegiatan",
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
        onPressed: () => context.push('/tambah-kegiatan'),
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
              DataColumn2(label: Text('Nama Kegiatan')),
              DataColumn2(label: Text('Tanggal')),
            ],
            rows: _kegiatanData.map((item) {
              return DataRow2(
                onTap: () {
                  context.push('/detail-kegiatan', extra: item);
                },
                cells: [
                  DataCell(Text(item['nama']!)),
                  DataCell(Text(item['tanggal']!)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
