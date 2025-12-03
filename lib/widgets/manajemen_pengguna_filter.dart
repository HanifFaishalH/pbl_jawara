import 'package:flutter/material.dart';

class ManajemenPenggunaFilter extends StatefulWidget {
  // Terima data awal agar filter tidak kosong saat dibuka kembali
  final String? initialNama;
  final String? initialStatus;

  const ManajemenPenggunaFilter({
    super.key,
    this.initialNama,
    this.initialStatus,
  });

  @override
  State<ManajemenPenggunaFilter> createState() => _ManajemenPenggunaFilterState();
}

class _ManajemenPenggunaFilterState extends State<ManajemenPenggunaFilter> {
  late TextEditingController _namaCtrl;
  String? _status;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data dari parent (jika ada)
    _namaCtrl = TextEditingController(text: widget.initialNama ?? '');
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  void _onApply() {
    // Kirim data kembali ke screen utama dalam bentuk Map
    Navigator.pop(context, {
      'nama': _namaCtrl.text.trim(),
      'status': _status,
    });
  }

  void _onReset() {
    setState(() {
      _namaCtrl.clear();
      _status = null;
    });
  }

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
          items: const ['Diterima', 'Pending', 'Ditolak']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _status = v),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 24),
        // Tombol kita pindah ke sini agar bisa akses _namaCtrl dan _status
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: _onReset,
              child: const Text("Reset Form"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _onApply,
              child: const Text("Terapkan"),
            ),
          ],
        )
      ],
    );
  }
}