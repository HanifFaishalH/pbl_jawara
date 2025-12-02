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
  
  // Controller untuk semua field yang ada di usersModel
  final _namaDepanCtrl = TextEditingController();
  final _namaBelakangCtrl = TextEditingController();
  final _tglLahirCtrl = TextEditingController(); // Untuk user_tanggal_lahir
  final _alamatCtrl = TextEditingController();   // Untuk user_alamat
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  
  // Default values
  String _status = 'Pending';
  int _roleId = 6; // Default Warga
  bool _isSubmitting = false;

  // Fungsi Date Picker
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default tahun
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Format YYYY-MM-DD sesuai format MySQL Date
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _tglLahirCtrl.text = formattedDate;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      // KUNCI JSON DISESUAIKAN PERSIS DENGAN usersModel
      final body = {
        'user_nama_depan': _namaDepanCtrl.text,
        'user_nama_belakang': _namaBelakangCtrl.text,
        'user_tanggal_lahir': _tglLahirCtrl.text, 
        'user_alamat': _alamatCtrl.text,          
        'email': _emailCtrl.text,
        'password': _pwdCtrl.text,
        'role_id': _roleId,
        'status': _status
      };

      try {
        print("Sending Data: $body"); 
        final success = await _service.tambahPengguna(body);

        setState(() => _isSubmitting = false); // Stop loading sebelum tampil dialog

        if (success && mounted) {
          // --- UBAH DISINI: TAMPILKAN POP-UP (DIALOG) ---
          await showDialog(
            context: context,
            barrierDismissible: false, // User harus tekan tombol OK
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
                    Navigator.of(ctx).pop(); // Tutup Dialog
                    Navigator.of(context).pop(); // Kembali ke halaman List
                  },
                  child: const Text("OK, KEMBALI"),
                ),
              ],
            ),
          );
        } else if (mounted) {
          // Jika gagal, tetap pakai SnackBar merah agar user bisa coba lagi tanpa menutup layar
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
              // 1. Nama Depan
              TextFormField(
                controller: _namaDepanCtrl,
                decoration: const InputDecoration(labelText: "Nama Depan", border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),
              
              // 2. Nama Belakang
              TextFormField(
                controller: _namaBelakangCtrl,
                decoration: const InputDecoration(labelText: "Nama Belakang", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),

              // 3. Tanggal Lahir
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

              // 4. Alamat
              TextFormField(
                controller: _alamatCtrl,
                decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // 5. Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (v) => (v != null && v.contains('@')) ? null : "Email tidak valid",
              ),
              const SizedBox(height: 16),

              // 6. Password
              TextFormField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                validator: (v) => (v != null && v.length >= 6) ? null : "Min. 6 karakter",
              ),
              const SizedBox(height: 16),

              // 7. Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                items: ['Pending', 'Diterima', 'Ditolak']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              // 8. Role (Sesuai Seeder)
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