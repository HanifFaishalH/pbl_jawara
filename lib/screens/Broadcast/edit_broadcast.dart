import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/broadcast/tambah_broadcast_form.dart';

class EditBroadcastScreen extends StatelessWidget {
  // Halaman ini akan menerima data kegiatan yang akan diedit
  final Map<String, String> broadcastData;

  const EditBroadcastScreen({super.key, required this.broadcastData});

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
          "Edit Broadcast",
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
          // Gunakan form yang sama, tetapi kirimkan data awal
          // agar semua field terisi secara otomatis.
          child: TambahBroadcastForm(initialData: broadcastData),
        ),
      ),
    );
  }
}
