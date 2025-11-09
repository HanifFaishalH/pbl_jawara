import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailBroadcastScreen extends StatelessWidget {
  // Data broadcast diterima dari halaman daftar melalui constructor
  final Map<String, String> broadcastData;

  const DetailBroadcastScreen({super.key, required this.broadcastData});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text(
            "Apakah Anda yakin ingin menghapus broadcast ini? Aksi ini tidak dapat dibatalkan.",
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text("Hapus"),
              onPressed: () {
                // TODO: Implementasikan logika untuk menghapus data dari database/server
                Navigator.of(dialogContext).pop(); // Tutup dialog
                context.pop(); // Kembali ke halaman daftar broadcast
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Broadcast berhasil dihapus')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // Widget helper untuk membuat baris detail yang rapi (Label: Value)
  Widget _buildDetailRow(BuildContext context, String label, String value) {
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
          "Detail Broadcast",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card untuk menampilkan detail utama
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
                        "Judul Broadcast",
                        broadcastData['judul'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Pengirim",
                        broadcastData['pengirim'] ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Tanggal Publikasi",
                        broadcastData['tanggal'] ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bagian untuk menampilkan deskripsi
              Text(
                'Isi Broadcast',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                broadcastData['isi'] ?? 'Tidak ada deskripsi.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lampiran Foto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // TODO: Replace with actual image loading (e.g., Image.network)
                    child: Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: const Center(child: Icon(Icons.image)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lampiran Dokumen',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(
                      broadcastData['namaDokumen'] ?? 'Dokumen',
                    ), // Use actual key name
                    trailing: const Icon(Icons.download_for_offline_outlined),
                    onTap: () {
                      // TODO: Implement document download/view logic
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),

              // Tombol Aksi (Edit dan Hapus)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                      onPressed: () => _showDeleteConfirmation(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit'),
                      onPressed: () {
                        // Navigasi ke halaman edit sambil mengirim data broadcast
                        context.push('/edit-broadcast', extra: broadcastData);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
