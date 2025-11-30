import 'package:flutter/material.dart';
import 'package:jawaramobile_1/screens/Kegiatan/tambah_kegiatan_form.dart';

class EditKegiatanScreen extends StatelessWidget {
  // Halaman ini akan menerima data kegiatan yang akan diedit
  final Map<String, String> kegiatanData;

  const EditKegiatanScreen({super.key, required this.kegiatanData});

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
          "Edit Kegiatan",
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
          child: TambahKegiatanForm(initialData: kegiatanData),
        ),
      ),
    );
  }
}
