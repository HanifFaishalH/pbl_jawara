import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/warga_service.dart';
import 'package:jawaramobile_1/services/keluarga_service.dart';
import 'package:jawaramobile_1/services/rumah_service.dart';

class FormWargaScreen extends StatefulWidget {
  final int? wargaId;
  const FormWargaScreen({super.key, this.wargaId});

  @override
  State<FormWargaScreen> createState() => _FormWargaScreenState();
}

class _FormWargaScreenState extends State<FormWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = WargaService();
  final _keluargaService = KeluargaService();
  final _rumahService = RumahService();

  final _namaCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _tempatLahirCtrl = TextEditingController();
  final _tanggalLahirCtrl = TextEditingController();
  final _agamaCtrl = TextEditingController();
  final _pendidikanCtrl = TextEditingController();
  final _pekerjaanCtrl = TextEditingController();
  final _statusPerkawinanCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String? _jenisKelamin;
  String _status = 'aktif';
  int? _keluargaId;
  int? _rumahId;
  bool _loading = false;
  bool _isEdit = false;

  List<dynamic> _keluargaList = [];
  List<dynamic> _rumahList = [];

  @override
  void initState() {
    super.initState();
    _isEdit = widget.wargaId != null;
    _loadDropdownData();
    if (_isEdit) _loadData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final keluarga = await _keluargaService.getKeluarga();
      final rumah = await _rumahService.getRumah();
      if (mounted) {
        setState(() {
          _keluargaList = keluarga;
          _rumahList = rumah;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getWargaById(widget.wargaId!);
      if (mounted) {
        setState(() {
          _namaCtrl.text = data['warga_nama'] ?? '';
          _nikCtrl.text = data['warga_nik'] ?? '';
          _tempatLahirCtrl.text = data['warga_tempat_lahir'] ?? '';
          _tanggalLahirCtrl.text = data['warga_tanggal_lahir'] ?? '';
          _agamaCtrl.text = data['warga_agama'] ?? '';
          _pendidikanCtrl.text = data['warga_pendidikan'] ?? '';
          _pekerjaanCtrl.text = data['warga_pekerjaan'] ?? '';
          _statusPerkawinanCtrl.text = data['warga_status_perkawinan'] ?? '';
          _teleponCtrl.text = data['warga_telepon'] ?? '';
          _emailCtrl.text = data['warga_email'] ?? '';
          _jenisKelamin = data['warga_jenis_kelamin'];
          _status = data['warga_status'] ?? 'aktif';
          _keluargaId = data['keluarga_id'];
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirCtrl.text = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final data = {
      'warga_nama': _namaCtrl.text,
      'warga_nik': _nikCtrl.text,
      'warga_tempat_lahir': _tempatLahirCtrl.text,
      'warga_tanggal_lahir': _tanggalLahirCtrl.text,
      'warga_jenis_kelamin': _jenisKelamin,
      'warga_agama': _agamaCtrl.text,
      'warga_pendidikan': _pendidikanCtrl.text,
      'warga_pekerjaan': _pekerjaanCtrl.text,
      'warga_status_perkawinan': _statusPerkawinanCtrl.text,
      'warga_telepon': _teleponCtrl.text,
      'warga_email': _emailCtrl.text,
      'keluarga_id': _keluargaId,
      'rumah_id': _rumahId,
      'warga_status': _status,
    };

    final success = await _service.saveWarga(data: data, id: widget.wargaId);

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
        title: Text(_isEdit ? 'Edit Data Warga' : 'Tambah Data Warga'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _namaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nikCtrl,
                      decoration: const InputDecoration(
                        labelText: 'NIK (16 digit) *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib diisi';
                        if (v.length != 16) return 'NIK harus 16 digit';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tempatLahirCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tempat Lahir',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tanggalLahirCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Lahir',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                      readOnly: true,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _jenisKelamin,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                        DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                      ],
                      onChanged: (v) => setState(() => _jenisKelamin = v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _agamaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Agama',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pendidikanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Pendidikan Terakhir',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pekerjaanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Pekerjaan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _statusPerkawinanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Status Perkawinan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teleponCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _keluargaId,
                      decoration: const InputDecoration(
                        labelText: 'Keluarga',
                        border: OutlineInputBorder(),
                      ),
                      items: _keluargaList.map((k) {
                        return DropdownMenuItem<int>(
                          value: k['keluarga_id'],
                          child: Text(k['keluarga_nama_kepala']),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _keluargaId = v),
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
                        DropdownMenuItem(value: 'pindah', child: Text('Pindah')),
                        DropdownMenuItem(
                            value: 'meninggal', child: Text('Meninggal')),
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
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tanggalLahirCtrl.dispose();
    _agamaCtrl.dispose();
    _pendidikanCtrl.dispose();
    _pekerjaanCtrl.dispose();
    _statusPerkawinanCtrl.dispose();
    _teleponCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }
}
