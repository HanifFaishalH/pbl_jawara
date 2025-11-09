import 'package:flutter/material.dart';

class TambahChannelScreen extends StatefulWidget {
  const TambahChannelScreen({super.key});

  @override
  State<TambahChannelScreen> createState() => _TambahChannelScreenState();
}

class _TambahChannelScreenState extends State<TambahChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorCtrl = TextEditingController();
  final _pemilikCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  String? _tipe; // bank/ewallet/qris

  void _reset() {
    _formKey.currentState?.reset();
    _namaCtrl.clear();
    _nomorCtrl.clear();
    _pemilikCtrl.clear();
    _catatanCtrl.clear();
    setState(() => _tipe = null);
  }

  void _simpan() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Channel disimpan')),
    );
    Navigator.of(context).pop();
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _uploadPlaceholder(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade100,
          ),
          child: const Center(child: Text("Upload gambar (png/jpg) – placeholder")),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Transfer Channel")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field("Nama Channel", _namaCtrl, validator: (v)=> (v==null||v.isEmpty)?"Wajib diisi":null),
              DropdownButtonFormField<String>(
                value: _tipe,
                hint: const Text("-- Pilih Tipe --"),
                items: const [
                  DropdownMenuItem(value: 'bank', child: Text('bank')),
                  DropdownMenuItem(value: 'ewallet', child: Text('ewallet')),
                  DropdownMenuItem(value: 'qris', child: Text('qris')),
                ],
                onChanged: (v) => setState(()=> _tipe=v),
                decoration: const InputDecoration(
                  labelText: "Tipe",
                  border: OutlineInputBorder(),
                ),
                validator: (v)=> v==null ? "Pilih tipe" : null,
              ),
              const SizedBox(height: 16),
              _field("Nomor Rekening / Akun", _nomorCtrl, keyboard: TextInputType.number,
                  validator: (v)=> (v==null||v.isEmpty)?"Wajib diisi":null),
              _field("Nama Pemilik", _pemilikCtrl, validator: (v)=> (v==null||v.isEmpty)?"Wajib diisi":null),
              _uploadPlaceholder("QR"),
              _uploadPlaceholder("Thumbnail"),
              TextFormField(
                controller: _catatanCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Catatan (Opsional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: _simpan, child: const Text("Simpan")),
                  const SizedBox(width: 12),
                  OutlinedButton(onPressed: _reset, child: const Text("Reset")),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
