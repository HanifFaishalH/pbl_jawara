import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/broadcast_service.dart';

class DetailBroadcastScreen extends StatefulWidget {
  final Map<String, dynamic> broadcastData;
  const DetailBroadcastScreen({super.key, required this.broadcastData});

  @override
  State<DetailBroadcastScreen> createState() => _DetailBroadcastScreenState();
}

class _DetailBroadcastScreenState extends State<DetailBroadcastScreen> {
  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Yakin ingin menghapus broadcast ini?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Hapus"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = widget.broadcastData['broadcast_id'] ?? widget.broadcastData['id'];
      final success = await BroadcastService().deleteBroadcast(int.parse(id.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Berhasil dihapus' : 'Gagal menghapus')),
      );
      if (success) context.pop();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.broadcastData;
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: const Text("Detail Broadcast", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: color.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDetailRow("Judul", data['judul'] ?? '-'),
            _buildDetailRow("Pengirim", data['admin']?['user_nama_depan'] ?? '-'),
            _buildDetailRow("Tanggal", data['tanggal'] ?? '-'),
            const SizedBox(height: 20),
            Text(data['isi_pesan'] ?? '-', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Hapus"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color.error,
                      side: BorderSide(color: color.error),
                    ),
                    onPressed: () => _confirmDelete(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text("Edit"),
                    onPressed: () =>
                        context.push('/edit-broadcast', extra: data),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
