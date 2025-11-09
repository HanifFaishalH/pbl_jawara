import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/manajemen_pengguna_filter.dart';
import 'package:go_router/go_router.dart';

class DaftarPenggunaScreen extends StatefulWidget {
  const DaftarPenggunaScreen({super.key});
  @override
  State<DaftarPenggunaScreen> createState() => _DaftarPenggunaScreenState();
}

class _DaftarPenggunaScreenState extends State<DaftarPenggunaScreen> {
  final List<Map<String, String>> _users = [
    {"nama":"mimin","email":"mimin@gmail.com","status":"Diterima"},
    {"nama":"Farhan","email":"farhan@gmail.com","status":"Diterima"},
    {"nama":"dewqedwddw","email":"admiwewen1@gmail.com","status":"Pending"},
    {"nama":"Rendha Putra Rahmadya","email":"rendhazuper@gmail.com","status":"Diterima"},
    {"nama":"bla","email":"y@gmail.com","status":"Ditolak"},
    {"nama":"Anti Micin","email":"antimicin3@gmail.com","status":"Diterima"},
  ];

  String? _queryNama;
  String? _queryStatus;

  List<Map<String, String>> get _filtered {
    return _users.where((u) {
      final okNama = _queryNama == null || _queryNama!.isEmpty
          ? true
          : (u['nama']!.toLowerCase().contains(_queryNama!.toLowerCase()));
      final okStatus = _queryStatus == null || _queryStatus!.isEmpty
          ? true
          : (u['status'] == _queryStatus);
      return okNama && okStatus;
    }).toList();
  }

  void _openFilter() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter Manajemen Pengguna"),
        content: const ManajemenPenggunaFilter(),
        actions: [
          OutlinedButton(
            onPressed: () {
              setState(() {
                _queryNama = null;
                _queryStatus = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text("Reset Filter"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Terapkan"),
          ),
        ],
      ),
    );
  }

  Color statusBg(String s) {
    switch (s) {
      case 'Diterima': return Colors.green.withOpacity(.12);
      case 'Pending':  return Colors.orange.withOpacity(.12);
      case 'Ditolak':  return Colors.red.withOpacity(.12);
      default: return Colors.grey.withOpacity(.12);
    }
  }
  Color statusFg(String s) {
    switch (s) {
      case 'Diterima': return Colors.green.shade800;
      case 'Pending':  return Colors.orange.shade800;
      case 'Ditolak':  return Colors.red.shade800;
      default: return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pengguna"),
        actions: [ IconButton(icon: const Icon(Icons.filter_list), onPressed: _openFilter) ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tambah-pengguna'),
        child: const Icon(Icons.person_add_alt_1),
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
            // 2 kolom sederhana: Nama, Status
            columns: const [
              DataColumn2(label: Text('Nama')),
              DataColumn2(label: Text('Status'), size: ColumnSize.S),
            ],
            rows: rows.map((u) {
              return DataRow2(
                onTap: () {
                  // TODO: route detail pengguna kalau ada
                  // context.push('/detail-pengguna', extra: u);
                },
                cells: [
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          u['nama']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          u['email']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg(u['status']!),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        u['status']!,
                        style: TextStyle(fontWeight: FontWeight.w600, color: statusFg(u['status']!)),
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
