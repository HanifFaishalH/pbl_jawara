import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/log_aktivitas_filter.dart';

class LogActivityScreen extends StatelessWidget {
  const LogActivityScreen({super.key});

  // Dummy data
  final List<Map<String, String>> _logs = const [
    {"no":"1","deskripsi":"Memperbarui transfer channel: BCA","aktor":"Admin Jawara","tanggal":"20 Oktober 2025"},
    {"no":"2","deskripsi":"Menambahkan transfer channel baru: BCA","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"3","deskripsi":"Menyetujui pesan warga: titooit","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"4","deskripsi":"Menambahkan rumah baru: jalan suhat","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"5","deskripsi":"Menambahkan rumah baru: I","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"6","deskripsi":"Menambahkan pengeluaran: Kerja Bakti Rp 50.000","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"7","deskripsi":"Menambahkan pengeluaran: Kerja Bakti Rp 100.000","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"8","deskripsi":"Menolak registrasi dari: asdfghjkl","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"9","deskripsi":"Menambahkan akun: mimin sebagai community_head","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
    {"no":"10","deskripsi":"Menugaskan tagihan: Agustusan periode Januari 2025 sebesar Rp 15","aktor":"Admin Jawara","tanggal":"19 Oktober 2025"},
  ];

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter Log Aktivitas"),
        content: const LogAktivitasFilter(),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Terapkan")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log Aktivitas"),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () => _showFilterDialog(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // contoh: tambah log manual (opsional)
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
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
              DataColumn2(label: Text('Deskripsi')),
              DataColumn2(label: Text('Tanggal'), size: ColumnSize.S),
            ],
            rows: _logs.map((item) {
              return DataRow2(
                onTap: () => context.push('/detail-log-aktivitas', extra: item),
                cells: [
                  DataCell(Text(
                    item['deskripsi'] ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )),
                  DataCell(Text(item['tanggal'] ?? '-')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
