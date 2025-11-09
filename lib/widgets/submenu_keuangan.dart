import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showSubMenuKeuangan(BuildContext context) {
  showDialog(
    context: context,
    // Gunakan 'dialogContext' untuk menutup dialog, dan 'context' untuk navigasi
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Pilih Laporan Keuangan"),
        contentPadding: const EdgeInsets.only(top: 20.0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text("Semua Pemasukan"),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                context.push(
                  '/semua-pemasukan',
                ); // Navigasi ke halaman pemasukan
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on_outlined),
              title: const Text("Semua Pengeluaran"),
              onTap: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                context.push(
                  '/semua-pengeluaran',
                ); // Navigasi ke halaman pengeluaran
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text("Cetak Laporan"),
              onTap: () {
                Navigator.of(dialogContext).pop();
                context.push('/cetak-laporan');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Tombol untuk menutup dialog
            },
          ),
        ],
      );
    },
  );
}
