import 'package:flutter/material.dart';

class DetailPengeluaranScreen extends StatelessWidget {
  // Data pengeluaran akan diterima melalui constructor
  final Map<String, String> pengeluaranData;

  const DetailPengeluaranScreen({super.key, required this.pengeluaranData});

  // Widget helper untuk membuat baris detail (Label: Value)
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isNominal = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNominal
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
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
          "Detail Pengeluaran",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        "Nama Pengeluaran",
                        pengeluaranData['nama'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Jenis Pengeluaran",
                        pengeluaranData['kategori'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Nominal",
                        pengeluaranData['nominal'] ?? 'Rp 0',
                        isNominal: true,
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Tanggal",
                        pengeluaranData['tanggal'] ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Bukti Pengeluaran', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // Placeholder untuk gambar bukti
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
