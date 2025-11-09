import 'package:flutter/material.dart';

class DetailTagihan extends StatelessWidget {
  // Data Pemasukan diterima melalui constructor
  final Map<String, String> kategoriData;

  const DetailTagihan({super.key, required this.kategoriData});

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[900]),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isNominal
                  ? Colors.green[700]
                  : theme.colorScheme.onSurface,
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
          "Detail Tagihan",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
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
                        "Nama Iuran",
                        kategoriData['namaKeluarga'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Status Keluarga",
                        kategoriData['statusKeluarga'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Jenis Iuran",
                        kategoriData['jenis'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Kode Tagihan",
                        kategoriData['kodeTagihan'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Nominal",
                        kategoriData['nominal'] ?? 'Rp 0',
                        isNominal: true,
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Periode",
                        kategoriData['periode'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "status",
                        kategoriData['status'] ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Bukti Tagihan', style: theme.textTheme.titleMedium),
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
