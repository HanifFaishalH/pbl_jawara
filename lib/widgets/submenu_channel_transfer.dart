import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showSubMenuChannelTransfer(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Channel Transfer"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.view_list),
            title: const Text("Daftar Channel"),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/daftar-channel');
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add_link),
            title: const Text("Tambah Channel"),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/tambah-channel');
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Tutup"),
        ),
      ],
    ),
  );
}
