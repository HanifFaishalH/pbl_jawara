import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/kegiatan_service.dart';

class DetailAdminActions extends StatelessWidget {
  final Map<String, dynamic> kegiatanData;

  const DetailAdminActions({super.key, required this.kegiatanData});

  Future<void> _handleDelete(BuildContext context) async {
    final rawId = kegiatanData['kegiatan_id'] ?? kegiatanData['id'];
    if (rawId == null) return;

    // 1. Konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => ctx.pop(true),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    // 2. Loading & Process
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final service = KegiatanService();
    final success = await service.deleteKegiatan(rawId);

    if (context.mounted) Navigator.of(context).pop(); // Tutup loading

    if (success && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Column(children: [
            Icon(Icons.check_circle, color: Colors.green, size: 60),
            SizedBox(height: 10),
            Text("Berhasil Dihapus"),
          ]),
          content: const Text("Data telah dihapus permanen.", textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop(); // Tutup Dialog Sukses
                context.pop(true); // Tutup Detail & Kirim sinyal refresh ke List
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus data'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text("Edit Kegiatan", style: TextStyle(fontWeight: FontWeight.bold)),
            // --- BAGIAN INI YANG DIPERBAIKI ---
            onPressed: () async {
              // 1. Tunggu hasil dari halaman Edit (apakah true?)
              final result = await context.push<bool>('/edit-kegiatan', extra: kegiatanData);
              
              // 2. Jika user menekan tombol SIMPAN (result == true)
              if (result == true && context.mounted) {
                // 3. Tutup halaman Detail ini juga, dan kirim 'true' ke Halaman List
                // Ini akan memicu fungsi _refresh() di KegiatanScreen
                context.pop(true);
              }
            },
            // ----------------------------------
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[400],
              side: BorderSide(color: Colors.red.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text("Hapus Kegiatan", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _handleDelete(context),
          ),
        ),
      ],
    );
  }
}