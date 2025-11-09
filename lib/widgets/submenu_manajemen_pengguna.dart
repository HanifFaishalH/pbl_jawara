import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showSubMenuManajemenPengguna(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Manajemen Pengguna"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text("Daftar Pengguna"),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/daftar-pengguna');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text("Tambah Pengguna"),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/tambah-pengguna');
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Tutup"),
        )
      ],
    ),
  );
}
