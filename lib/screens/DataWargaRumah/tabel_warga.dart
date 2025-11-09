import 'package:flutter/material.dart';

class TabelWarga extends StatelessWidget {
  const TabelWarga({super.key});

  final List<Map<String, dynamic>> warga = const [
    {"nama": "Hanif", "nik": "1234567890123456", "umur": 22, "pekerjaan": "Mahasiswa"},
    {"nama": "Siti", "nik": "1234567890123457", "umur": 25, "pekerjaan": "Guru"},
    {"nama": "Budi", "nik": "1234567890123458", "umur": 30, "pekerjaan": "Wiraswasta"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tabel Data Warga",
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // ✅ scroll horizontal untuk HP
              child: DataTable(
                columnSpacing: 16,
                headingRowColor:
                MaterialStateProperty.all(colorScheme.primaryContainer),
                headingTextStyle: theme.textTheme.titleSmall
                    ?.copyWith(color: colorScheme.onPrimaryContainer),
                columns: const [
                  DataColumn(label: Text("Nama")),
                  DataColumn(label: Text("NIK")),
                  DataColumn(label: Text("Umur")),
                  DataColumn(label: Text("Pekerjaan")),
                ],
                rows: warga.map((w) {
                  return DataRow(
                    cells: [
                      DataCell(Text(w["nama"], style: theme.textTheme.bodyMedium)),
                      DataCell(Text(w["nik"], style: theme.textTheme.bodyMedium)),
                      DataCell(Text("${w["umur"]}", style: theme.textTheme.bodyMedium)),
                      DataCell(Text(w["pekerjaan"], style: theme.textTheme.bodyMedium)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
