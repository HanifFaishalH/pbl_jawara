// lib/screens/ChannelTransfer/daftar_channel_screen.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DaftarChannelScreen extends StatelessWidget {
  const DaftarChannelScreen({super.key});

  // Data dummy
  final List<Map<String, String>> _rows = const [
    {"nama": "QRIS Resmi RT 08", "tipe": "qris", "an": "RW 08 Karangploso"},
    {"nama": "BCA", "tipe": "bank", "an": "Jose"},
    {"nama": "OVO", "tipe": "ewallet", "an": "23234"},
    {"nama": "Transfer via BCA", "tipe": "bank", "an": "RT Jawara Karangploso"},
  ];

  Widget _typeChip(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    // warna mengikuti theme
    Color bg;
    Color fg;
    switch (t) {
      case 'bank':
        bg = cs.primary.withOpacity(.12);
        fg = cs.primary;
        break;
      case 'ewallet':
        bg = cs.secondary.withOpacity(.35);
        fg = cs.onSecondary;
        break;
      case 'qris':
        bg = Colors.white;
        fg = cs.primary;
        break;
      default:
        bg = cs.surfaceVariant;
        fg = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        t,
        style: TextStyle(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          "Channel Transfer",
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: filter (opsional)
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/tambah-channel'),
        child: const Icon(Icons.add_link),
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
          // TABLE SEDERHANA: 2 kolom saja agar tidak perlu scroll horizontal
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
              DataColumn2(label: Text('Nama Channel')),
              DataColumn2(label: Text('Tipe')),
            ],
            rows: _rows.map((r) {
              return DataRow2(
                // Klik baris untuk menuju halaman detail (sementara arahkan ke tambah/edit jika detail belum ada)
                onTap: () {
                  // TODO: ganti ke '/detail-channel' jika nanti halaman detail tersedia
                  // context.push('/detail-channel', extra: r);
                  context.push('/tambah-channel');
                },
                cells: [
                  // Nama Channel + A/N sebagai informasi tambahan singkat
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          r['nama']!,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "A/N ${r['an']!}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  DataCell(_typeChip(context, r['tipe']!)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
