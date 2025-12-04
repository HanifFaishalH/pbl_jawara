import 'package:flutter/material.dart';
import '../../services/man_pengguna_service.dart';

class TambahPenggunaScreen extends StatefulWidget {
  const TambahPenggunaScreen({super.key});
  @override
  State<TambahPenggunaScreen> createState() => _TambahPenggunaScreenState();
}

class _TambahPenggunaScreenState extends State<TambahPenggunaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PenggunaService();
  
  final _namaDepanCtrl = TextEditingController();
  final _namaBelakangCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController(); 
  final _alamatCtrl = TextEditingController();      
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  
  // Default values
  String _status = 'Pending';
  int _roleId = 6; // Default Warga
  
  // 1. Tambahan Variabel Jenis Kelamin
  String? _jenisKelamin; 

  bool _isSubmitting = false;

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _tglLahirCtrl.text = formattedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final body = {
        'user_nama_depan': _namaDepanCtrl.text,
        'user_nama_belakang': _namaBelakangCtrl.text,
        'user_tanggal_lahir': _tglLahirCtrl.text, 
        // 2. Kirim data ke backend
        'user_jenis_kelamin': _jenisKelamin, 
        'user_alamat': _alamatCtrl.text,          
        'email': _emailCtrl.text,
        'password': _pwdCtrl.text,
        'role_id': _roleId,
        'status': _status
      };

      try {
        // print("Sending Data: $body"); 
        final success = await _service.tambahPengguna(body);

        setState(() => _isSubmitting = false);

        if (success && mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false, 
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 10),
                  Text("Berhasil", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: const Text(
                "Data pengguna berhasil ditambahkan ke sistem.",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(); 
                    Navigator.of(context).pop(); 
                  },
                  child: const Text("OK, KEMBALI"),
                ),
              ],
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menambah pengguna. Cek validasi backend / email duplikat.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() => _isSubmitting = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } 
    }
  }

  @override
  void dispose() {
    _namaDepanCtrl.dispose();
    _namaBelakangCtrl.dispose();
    _tglLahirCtrl.dispose();
    _alamatCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaDepanCtrl,
                decoration: const InputDecoration(labelText: "Nama Depan", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _namaBelakangCtrl,
                decoration: const InputDecoration(labelText: "Nama Belakang", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tglLahirCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Tanggal Lahir", 
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selectDate,
                validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // 3. Widget Dropdown Jenis Kelamin
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: const InputDecoration(labelText: "Jenis Kelamin", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text("Laki-laki")),
                  DropdownMenuItem(value: 'P', child: Text("Perempuan")),
                ],
                onChanged: (v) => setState(() => _jenisKelamin = v),
                validator: (v) => v == null ? "Wajib dipilih" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _alamatCtrl,
                decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (v) => (v != null && v.contains('@')) ? null : "Email tidak valid",
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                validator: (v) => (v != null && v.length >= 6) ? null : "Min. 6 karakter",
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                items: ['Pending', 'Diterima', 'Ditolak']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _roleId,
                decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Admin")),
                  DropdownMenuItem(value: 2, child: Text("Ketua RW")),
                  DropdownMenuItem(value: 3, child: Text("Ketua RT")),
                  DropdownMenuItem(value: 4, child: Text("Sekretaris")),
                  DropdownMenuItem(value: 5, child: Text("Bendahara")),
                  DropdownMenuItem(value: 6, child: Text("Warga")),
                ],
                onChanged: (v) => setState(() => _roleId = v!),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("SIMPAN DATA"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}