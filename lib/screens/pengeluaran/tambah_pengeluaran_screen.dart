import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/tambah_pengeluaran_form.dart';

class TambahPengeluaranScreen extends StatelessWidget {
  const TambahPengeluaranScreen({super.key});

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
          "Tambah Pengeluaran",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
        // Body menjadi jauh lebih simpel
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: TambahPengeluaranForm(), // Cukup panggil widget form di sini
        ),
      ),
    );
  }
}
