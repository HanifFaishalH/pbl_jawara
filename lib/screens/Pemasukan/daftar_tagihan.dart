import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'tagihan_table.dart';

class DaftarTagihan extends StatefulWidget {
  const DaftarTagihan({super.key});

  @override
  State<DaftarTagihan> createState() => _DaftarTagihanState();
}

class _DaftarTagihanState extends State<DaftarTagihan> {
  // Data dummy tanpa tanggal
  final List<Map<String, String>> _daftarTagihan = [
    {
      "no": "1",
      "namaKeluarga": "Keluarga Aziz",
      "statusKeluarga": "Aktif",
      "jenis": "Bulanan",
      "kodeTagihan": "IR12345",
      "nominal": "Rp 10.000",
      "periode": "2 Januari 2023",
      "status": "Belum Lunas",
    },
    {
      "no": "2",
      "namaKeluarga": "Keluarga Hilmi",
      "statusKeluarga": "Aktif",
      "jenis": "Bulanan",
      "kodeTagihan": "IR12346",
      "nominal": "Rp 10.000",
      "periode": "2 Januari 2023",
      "status": "Belum Lunas",
    },
    {
      "no": "3",
      "namaKeluarga": "Keluarga Dio",
      "statusKeluarga": "Aktif",
      "jenis": "Bulanan",
      "kodeTagihan": "IR12347",
      "nominal": "Rp 10.000",
      "periode": "2 Januari 2023",
      "status": "Belum Lunas",
    },
  ];

  // void _showAddIuranDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AddIuranDialog(
  //         onIuranAdded: (newIuran) {
  //           _addNewIuran(newIuran);
  //         },
  //       );
  //     },
  //   );
  // }

  // void _addNewIuran(Map<String, String> newIuran) {
  //   setState(() {
  //     _daftarTagihan.add({
  //       "no": (_daftarTagihan.length + 1).toString(),
  //       "nama": newIuran['nama']!,
  //       "jenis": newIuran['jenis']!,
  //       "nominal": newIuran['nominal'] ?? "Rp 0",
  //     });
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Iuran ${newIuran['nama']} berhasil ditambahkan"),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  // }

  // void _deleteIuran(Map<String, String> item) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Hapus Iuran"),
  //         content: Text("Yakin ingin menghapus iuran ${item['nama']}?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(),
  //             child: const Text("Batal"),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               setState(() {
  //                 _daftarTagihan.remove(item);
  //               });
  //               Navigator.of(context).pop();
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 SnackBar(
  //                   content: Text("Iuran ${item['nama']} berhasil dihapus"),
  //                   backgroundColor: Colors.green,
  //                 ),
  //               );
  //             },
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //             child: const Text("Hapus", style: TextStyle(color: Colors.white)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
          "Tagihan Iuran",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/menu-pemasukan'),
        ),
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
          child: TagihanTable(
            daftarTagihan: _daftarTagihan,
            // onAddPressed: _showAddIuranDialog,
            // onDeletePressed: _deleteIuran,
            onViewPressed: (item) {
              context.push('/detail-tagihan', extra: item);
            },
          ),
        ),
      ),
    );
  }
}
