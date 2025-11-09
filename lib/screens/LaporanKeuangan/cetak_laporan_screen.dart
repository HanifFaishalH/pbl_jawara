import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/cetak_laporan_form.dart';

class CetakLaporanScreen extends StatelessWidget {
  const CetakLaporanScreen({super.key});

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
          "Cetak Laporan",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: CetakLaporanForm(),
        ),
      ),
    );
  }
}
