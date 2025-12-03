import 'package:flutter/material.dart';
import '../../models/pengguna_model.dart';
import '../../services/man_pengguna_service.dart';

class DetailPenggunaScreen extends StatefulWidget {
  final PenggunaModel user;

  const DetailPenggunaScreen({super.key, required this.user});

  @override
  State<DetailPenggunaScreen> createState() => _DetailPenggunaScreenState();
}

class _DetailPenggunaScreenState extends State<DetailPenggunaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PenggunaService();

  late TextEditingController _namaDepanCtrl;
  late TextEditingController _namaBelakangCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _tglLahirCtrl;
  late TextEditingController _alamatCtrl;
  late TextEditingController _pwdCtrl; 

  late String _status;
  late int _roleId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Data Awal
    _namaDepanCtrl = TextEditingController(text: widget.user.namaDepan);
    _namaBelakangCtrl = TextEditingController(text: widget.user.namaBelakang);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _tglLahirCtrl = TextEditingController(text: widget.user.tglLahir);
    _alamatCtrl = TextEditingController(text: widget.user.alamat);
    _pwdCtrl = TextEditingController(); 

    _status = widget.user.status;
    _roleId = widget.user.roleId == 0 ? 6 : widget.user.roleId; 
  }

  // --- HELPER: POP-UP SUKSES ---
  // Fungsi ini dipanggil saat Edit Sukses atau Hapus Sukses
  Future<void> _showSuccessDialog(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // User wajib tekan tombol OK
      builder: (ctx) => AlertDialog(
        title: const Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 10),
            Text("Berhasil"),
          ],
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // 1. Tutup Dialog
              Navigator.pop(context, true); // 2. Kembali ke List & Refresh
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // --- LOGIKA SIMPAN (EDIT) ---
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      final body = {
        'user_nama_depan': _namaDepanCtrl.text,
        'user_nama_belakang': _namaBelakangCtrl.text,
        'email': _emailCtrl.text,
        'role_id': _roleId,
        'status': _status,
        'user_tanggal_lahir': _tglLahirCtrl.text,
        'user_alamat': _alamatCtrl.text,
      };

      if (_pwdCtrl.text.isNotEmpty) {
        body['password'] = _pwdCtrl.text;
      }

      final success = await _service.updatePengguna(widget.user.userId, body);

      setState(() => _isSubmitting = false);

      if (success && mounted) {
        // UPDATE: Sekarang pakai Pop-up juga
        await _showSuccessDialog("Data pengguna berhasil diperbarui.");
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal update data. Cek koneksi atau email duplikat.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- LOGIKA HAPUS (DELETE) ---
  Future<void> _confirmDelete() async {
    // 1. Dialog Konfirmasi Awal (Yakin?)
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pengguna?"),
        content: Text("Anda yakin ingin menghapus '${widget.user.namaDepan}'? Data tidak bisa dikembalikan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    // 2. Jika User Pilih YA
    if (confirm == true) {
      setState(() => _isSubmitting = true);
      final success = await _service.hapusPengguna(widget.user.userId);
      setState(() => _isSubmitting = false);

      if (success && mounted) {
        // Panggil Pop-up Sukses Hapus
        await _showSuccessDialog("Data pengguna berhasil dihapus dari sistem.");
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus. Data mungkin terkait dengan transaksi lain.'), 
            backgroundColor: Colors.red
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formatted = "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      setState(() => _tglLahirCtrl.text = formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail & Edit Pengguna"),
        actions: [
          // TOMBOL HAPUS (SAMPAH)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isSubmitting ? null : _confirmDelete,
            tooltip: 'Hapus Pengguna',
          ),
        ],
      ),
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
                validator: (v) => v!.isEmpty ? "Wajib" : null,
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
                onTap: _selectDate,
                decoration: const InputDecoration(labelText: "Tgl Lahir", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _alamatCtrl,
                decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
                maxLines: 2,
                validator: (v) => v!.isEmpty ? "Wajib" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                validator: (v) => v!.contains('@') ? null : "Email tidak valid",
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pwdCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru (Opsional)", 
                  border: OutlineInputBorder(),
                  helperText: "Biarkan kosong jika tidak ingin ganti password"
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder()),
                items: ['Pending', 'Diterima', 'Ditolak'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
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
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN PERUBAHAN"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}