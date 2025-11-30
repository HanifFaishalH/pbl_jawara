import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/kegiatan_service.dart';
import 'package:jawaramobile_1/widgets/kegiatan/custom_text_field.dart';
import 'package:jawaramobile_1/widgets/kegiatan/kegiatan_image_picker.dart';

class TambahKegiatanForm extends StatefulWidget {
  final dynamic initialData;
  const TambahKegiatanForm({super.key, this.initialData});

  @override
  State<TambahKegiatanForm> createState() => _TambahKegiatanFormState();
}

class _TambahKegiatanFormState extends State<TambahKegiatanForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = KegiatanService();
  bool _isSaving = false;
  late TextEditingController _namaCtrl, _pjCtrl, _tglCtrl, _lokasiCtrl, _descCtrl;
  String? _selectedKategori;
  XFile? _newPhoto;

  final List<String> _kategoriOpts = [
    'Komunitas & Sosial', 'Kebersihan & Keamanan', 'Keagamaan',
    'Pendidikan', 'Kesehatan & Olahraga', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _namaCtrl = TextEditingController(text: d?['kegiatan_nama'] ?? d?['nama']);
    _pjCtrl = TextEditingController(text: d?['kegiatan_pj'] ?? d?['pj']);
    _tglCtrl = TextEditingController(text: d?['kegiatan_tanggal'] ?? d?['tanggal']);
    _lokasiCtrl = TextEditingController(text: d?['kegiatan_lokasi'] ?? d?['lokasi']);
    _descCtrl = TextEditingController(text: d?['kegiatan_deskripsi'] ?? d?['deskripsi']);
    
    String? rawKategori = d?['kegiatan_kategori'] ?? d?['kategori'];
    if (rawKategori != null && _kategoriOpts.contains(rawKategori)) {
      _selectedKategori = rawKategori;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose(); _pjCtrl.dispose(); _tglCtrl.dispose();
    _lokasiCtrl.dispose(); _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi data wajib')));
      return;
    }
    setState(() => _isSaving = true);
    
    final fields = {
      'kegiatan_nama': _namaCtrl.text, 'kegiatan_pj': _pjCtrl.text,
      'kegiatan_tanggal': _tglCtrl.text, 'kegiatan_lokasi': _lokasiCtrl.text,
      'kegiatan_deskripsi': _descCtrl.text, 'kegiatan_kategori': _selectedKategori ?? 'Lainnya',
    };
    
    final success = await _service.saveKegiatan(
      fields: fields, imageFile: _newPhoto, 
      id: widget.initialData?['kegiatan_id'] ?? widget.initialData?['id'],
    );
    
    setState(() => _isSaving = false);
    
    if (success && mounted) {
      // --- UPDATE: MENGGUNAKAN POP UP DIALOG ---
      showDialog(
        context: context,
        barrierDismissible: false, // User harus klik tombol OK
        builder: (BuildContext ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text("Berhasil"),
              ],
            ),
            content: const Text("Data kegiatan telah berhasil disimpan."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Tutup Dialog
                  context.pop(true);       // Kembali ke layar sebelumnya & refresh
                },
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          );
        },
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KegiatanImagePicker(
            initialUrl: widget.initialData?['kegiatan_foto'] ?? widget.initialData?['foto'],
            newImageFile: _newPhoto,
            onPickImage: () async {
              final img = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (img != null) setState(() => _newPhoto = img);
            },
          ),
          const SizedBox(height: 24),
          const Text("Informasi Utama", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(controller: _namaCtrl, label: 'Nama Kegiatan', icon: Icons.event),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: DropdownButtonFormField<String>(
              value: _selectedKategori,
              items: _kategoriOpts.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => _selectedKategori = v),
              validator: (v) => v == null ? 'Pilih kategori dulu' : null,
              decoration: InputDecoration(
                labelText: 'Kategori', prefixIcon: Icon(Icons.category, color: Theme.of(context).primaryColor),
                filled: true, fillColor: Colors.grey[50],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          CustomTextField(
            controller: _tglCtrl, label: 'Tanggal Pelaksanaan', icon: Icons.calendar_today, readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context, initialDate: DateTime.now(),
                firstDate: DateTime(2020), lastDate: DateTime(2030),
              );
              if (picked != null) _tglCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
            },
          ),
          const Divider(height: 30),
          const Text("Detail Lengkap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(controller: _pjCtrl, label: 'Penanggung Jawab', icon: Icons.person),
          CustomTextField(controller: _lokasiCtrl, label: 'Lokasi Kegiatan', icon: Icons.location_on),
          CustomTextField(controller: _descCtrl, label: 'Deskripsi Singkat', icon: Icons.description, maxLines: 4, keyboardType: TextInputType.multiline),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('SIMPAN DATA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}