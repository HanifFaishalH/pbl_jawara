import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/pengeluaran_filter.dart';
import '../../widgets/bottom_navbar.dart';

class PengeluaranScreen extends StatelessWidget {
  const PengeluaranScreen({super.key});

  // Data dummy
  final List<Map<String, String>> _pengeluaranData = const [
    {
      "nama": "Beli Sapu",
      "kategori": "Keamanan & Kebersihan",
      "tanggal": "22 Oktober 2025",
      "nominal": "Rp 25.000",
    },
    {
      "nama": "Perbaikan Lampu Jalan",
      "kategori": "Pemeliharaan Fasilitas",
      "tanggal": "17 Oktober 2025",
      "nominal": "Rp 150.000",
    },
    {
      "nama": "Santunan anak Yatim",
      "kategori": "Kegiatan Sosial",
      "tanggal": "15 Oktober 2025",
      "nominal": "Rp 50.000",
    },
    {
      "nama": "Pembangunan Pos RW",
      "kategori": "Pembangunan",
      "tanggal": "11 September 2025",
      "nominal": "Rp 320.000",
    },
    {
      "nama": "Lomba 17an",
      "kategori": "Kegiatan Warga",
      "tanggal": "10 Agustus 2025",
      "nominal": "Rp 500.000",
    },
  ];

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Pengeluaran"),
          content: SingleChildScrollView(child: const PengeluaranFilter()),
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
          "Laporan Pengeluaran",
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
        onPressed: () => context.push('/tambah-pengeluaran'),
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
        // Body sekarang hanya berisi tabel
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
              DataColumn2(label: Text('Nama')),
              DataColumn2(label: Text('Nominal'), numeric: true),
            ],
            rows: _pengeluaranData.map((item) {
              return DataRow2(
                onTap: () {
                  context.push('/detail-pengeluaran', extra: item);
                },
                cells: [
                  DataCell(Text(item['nama']!)),
                  DataCell(
                    Text(
                      item['nominal']!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
