import 'package:flutter/material.dart';

class ManajemenPenggunaFilter extends StatefulWidget {
  const ManajemenPenggunaFilter({super.key});
  @override
  State<ManajemenPenggunaFilter> createState() => _ManajemenPenggunaFilterState();
}

class _ManajemenPenggunaFilterState extends State<ManajemenPenggunaFilter> {
  final _namaCtrl = TextEditingController();
  String? _status; // Diterima / Pending / Ditolak

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nama'),
        const SizedBox(height: 8),
        TextField(
          controller: _namaCtrl,
          decoration: const InputDecoration(
            hintText: 'Cari nama...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Status'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _status,
          hint: const Text('-- Pilih Status --'),
          items: const ['Diterima','Pending','Ditolak']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _status = v),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Text(
          "Catatan: tombol Terapkan di dialog akan memanggil logika filter di screen.",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
