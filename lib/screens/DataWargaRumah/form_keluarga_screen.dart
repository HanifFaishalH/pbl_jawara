import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/keluarga_service.dart';
import 'package:jawaramobile_1/services/rumah_service.dart';

class FormKeluargaScreen extends StatefulWidget {
  final int? keluargaId;
  const FormKeluargaScreen({super.key, this.keluargaId});

  @override
  State<FormKeluargaScreen> createState() => _FormKeluargaScreenState();
}

class _FormKeluargaScreenState extends State<FormKeluargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = KeluargaService();
  final _rumahService = RumahService();

  final _noKKCtrl = TextEditingController();
  final _namaKepalaCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();

  String _status = 'aktif';
  int? _rumahId;
  bool _loading = false;
  bool _isEdit = false;
  List<dynamic> _rumahList = [];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.keluargaId != null;
    _loadRumahList();
    if (_isEdit) _loadData();
  }

  Future<void> _loadRumahList() async {
    try {
      final rumah = await _rumahService.getRumah();
      if (mounted) {
        setState(() => _rumahList = rumah);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data rumah: $e')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getKeluargaById(widget.keluargaId!);
      if (mounted) {
        setState(() {
          _noKKCtrl.text = data['keluarga_no_kk'] ?? '';
          _namaKepalaCtrl.text = data['keluarga_nama_kepala'] ?? '';
          _alamatCtrl.text = data['keluarga_alamat'] ?? '';
          _status = data['keluarga_status'] ?? 'aktif';
          _rumahId = data['rumah_id'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final data = {
      'keluarga_no_kk': _noKKCtrl.text,
      'keluarga_nama_kepala': _namaKepalaCtrl.text,
      'keluarga_alamat': _alamatCtrl.text,
      'rumah_id': _rumahId,
      'keluarga_status': _status,
    };

    final success =
        await _service.saveKeluarga(data: data, id: widget.keluargaId);

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              success ? 'Data berhasil disimpan' : 'Gagal menyimpan data'),
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Data Keluarga' : 'Tambah Data Keluarga'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _noKKCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nomor KK *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _namaKepalaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Kepala Keluarga *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alamat *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _rumahId,
                      decoration: const InputDecoration(
                        labelText: 'Rumah',
                        border: OutlineInputBorder(),
                      ),
                      items: _rumahList.map((r) {
                        return DropdownMenuItem<int>(
                          value: r['rumah_id'],
                          child: Text(r['rumah_alamat']),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _rumahId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                        DropdownMenuItem(
                            value: 'nonaktif', child: Text('Non-Aktif')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _simpan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(_isEdit ? 'Update' : 'Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _noKKCtrl.dispose();
    _namaKepalaCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }
}
