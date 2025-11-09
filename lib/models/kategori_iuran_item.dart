import 'package:flutter/material.dart';

class PemasukanListItem extends StatelessWidget {
  final String nama;
  final String jenis;
  final String nominal;

  const PemasukanListItem({
    super.key,
    required this.nama,
    required this.jenis,
    required this.nominal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildTextInfo(String label, String value, {Color? valueColor}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Kolom kiri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTextInfo("Nama Pemasukan", nama),
                  const SizedBox(height: 12),
                  buildTextInfo("Jenis Pemasukan", jenis),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Kolom kanan (hanya nominal)
            buildTextInfo(
              "Nominal",
              nominal,
              valueColor: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}
