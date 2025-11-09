import 'package:flutter/material.dart';

class TabelRumah extends StatelessWidget {
  const TabelRumah({super.key});

  final List<Map<String, dynamic>> rumah = const [
    {"alamat": "Jl. Melati No.10", "luas": "120 m²", "status": "Milik Sendiri"},
    {"alamat": "Jl. Mawar No.7", "luas": "90 m²", "status": "Kontrak"},
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
            "Tabel Data Rumah",
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
              scrollDirection: Axis.horizontal, // ✅ biar bisa geser di HP
              child: DataTable(
                columnSpacing: 16,
                headingRowColor:
                MaterialStateProperty.all(colorScheme.primaryContainer),
                headingTextStyle: theme.textTheme.titleSmall
                    ?.copyWith(color: colorScheme.onPrimaryContainer),
                columns: const [
                  DataColumn(label: Text("Alamat")),
                  DataColumn(label: Text("Luas")),
                  DataColumn(label: Text("Status")),
                ],
                rows: rumah.map((r) {
                  final isMilikSendiri = r["status"] == "Milik Sendiri";
                  return DataRow(
                    cells: [
                      DataCell(Text(r["alamat"], style: theme.textTheme.bodyMedium)),
                      DataCell(Text(r["luas"], style: theme.textTheme.bodyMedium)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isMilikSendiri
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            r["status"],
                            style: TextStyle(
                              color: isMilikSendiri
                                  ? Colors.green.shade800
                                  : Colors.orange.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
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
