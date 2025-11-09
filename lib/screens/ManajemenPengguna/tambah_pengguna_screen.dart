import 'package:flutter/material.dart';

class TambahPenggunaScreen extends StatefulWidget {
  const TambahPenggunaScreen({super.key});
  @override
  State<TambahPenggunaScreen> createState() => _TambahPenggunaScreenState();
}

class _TambahPenggunaScreenState extends State<TambahPenggunaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  String? _role;

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna disimpan')),
      );
      Navigator.of(context).pop();
    }
  }

  void _reset() {
    _formKey.currentState?.reset();
    _namaCtrl.clear();
    _emailCtrl.clear();
    _hpCtrl.clear();
    _pwdCtrl.clear();
    _pwd2Ctrl.clear();
    setState(() => _role = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Akun Pengguna")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field("Nama Lengkap", _namaCtrl, validator: (v) => (v==null||v.isEmpty)?"Wajib diisi":null),
              _field("Email", _emailCtrl, keyboard: TextInputType.emailAddress,
                  validator: (v) => (v==null||!v.contains('@'))?"Email tidak valid":null),
              _field("Nomor HP", _hpCtrl, keyboard: TextInputType.phone),
              _field("Password", _pwdCtrl, obscure: true,
                  validator: (v)=> (v==null||v.length<6)?"Min. 6 karakter":null),
              _field("Konfirmasi Password", _pwd2Ctrl, obscure: true,
                  validator: (v)=> v==_pwdCtrl.text ? null : "Tidak sama"),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _role,
                hint: const Text("-- Pilih Role --"),
                items: const ["Admin", "Community Head", "Warga"]
                    .map((r)=>DropdownMenuItem(value:r,child: Text(r))).toList(),
                onChanged: (v)=> setState(()=> _role=v),
                decoration: const InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
                validator: (v)=> v==null ? "Pilih role" : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(onPressed: _submit, child: const Text("Simpan")),
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

  Widget _field(String label, TextEditingController c,
      {TextInputType keyboard = TextInputType.text,
       bool obscure = false,
       String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        obscureText: obscure,
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
}
