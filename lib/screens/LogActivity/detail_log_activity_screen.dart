import 'package:flutter/material.dart';

class DetailLogActivityScreen extends StatelessWidget {
  final Map<String, String> logData;
  const DetailLogActivityScreen({super.key, required this.logData});

  Widget _buildRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(.6),
              )),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Log Aktivitas")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              children: [
                _buildRow(context, "No", logData['no'] ?? '-'),
                const Divider(height: 1),
                _buildRow(context, "Deskripsi", logData['deskripsi'] ?? '-'),
                const Divider(height: 1),
                _buildRow(context, "Aktor", logData['aktor'] ?? '-'),
                const Divider(height: 1),
                _buildRow(context, "Tanggal", logData['tanggal'] ?? '-'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
