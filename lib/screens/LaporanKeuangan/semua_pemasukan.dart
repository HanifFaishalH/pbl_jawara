import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/finance_service.dart';
import 'package:jawaramobile_1/widgets/Pemasukan_filter.dart';

class Pemasukan extends StatefulWidget {
  const Pemasukan({super.key});

  @override
  State<Pemasukan> createState() => _PemasukanState();
}

class _PemasukanState extends State<Pemasukan> {
  List<dynamic> _rows = [];
  bool _loading = true;
  String? _q;
  String? _from;
  String? _to;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await FinanceService.listPemasukan(q: _q, from: _from, to: _to);
      setState(() {
        _rows = (res['data'] as List<dynamic>);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pemasukan: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filter Pemasukan"),
          content: SingleChildScrollView(child: const PemasukanFilter()),
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
          "Semua Pemasukan",
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : DataTable2(
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
                  rows: _rows.map((item) {
                    final judul = (item['judul'] ?? '').toString();
                    final jumlah = int.tryParse(item['jumlah'].toString()) ?? 0;
                    final nominal = 'Rp ${NumberFormat.decimalPattern('id').format(jumlah)}';
                    return DataRow2(
                      onTap: () {
                        context.push('/detail-pemasukan-all', extra: {
                          'nama': judul,
                          'nominal': nominal,
                        });
                      },
                      cells: [
                        DataCell(Text(judul)),
                        DataCell(
                          Text(
                            nominal,
                            style: TextStyle(
                              color: Colors.green[700],
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
