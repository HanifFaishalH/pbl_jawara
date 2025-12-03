import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/rumah_service.dart';

class FormRumahScreen extends StatefulWidget {
  final int? rumahId;
  const FormRumahScreen({super.key, this.rumahId});

  @override
  State<FormRumahScreen> createState() => _FormRumahScreenState();
}

class _FormRumahScreenState extends State<FormRumahScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = RumahService();

  final _alamatCtrl = TextEditingController();
  final _rtCtrl = TextEditingController();
  final _rwCtrl = TextEditingController();
  final _kelurahanCtrl = TextEditingController();
  final _kecamatanCtrl = TextEditingController();
  final _kotaCtrl = TextEditingController();
  final _provinsiCtrl = TextEditingController();
  final _kodePosCtrl = TextEditingController();
  final _luasTanahCtrl = TextEditingController();
  final _luasBangunanCtrl = TextEditingController();
  final _jumlahPenghuniCtrl = TextEditingController();

  String _statusKepemilikan = 'milik_sendiri';
  String _status = 'aktif';
  bool _loading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.rumahId != null;
    if (_isEdit) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getRumahById(widget.rumahId!);
      if (mounted) {
        setState(() {
          _alamatCtrl.text = data['rumah_alamat'] ?? '';
          _rtCtrl.text = data['rumah_rt'] ?? '';
          _rwCtrl.text = data['rumah_rw'] ?? '';
          _kelurahanCtrl.text = data['rumah_kelurahan'] ?? '';
          _kecamatanCtrl.text = data['rumah_kecamatan'] ?? '';
          _kotaCtrl.text = data['rumah_kota'] ?? '';
          _provinsiCtrl.text = data['rumah_provinsi'] ?? '';
          _kodePosCtrl.text = data['rumah_kode_pos'] ?? '';
          _luasTanahCtrl.text = data['rumah_luas_tanah'] ?? '';
          _luasBangunanCtrl.text = data['rumah_luas_bangunan'] ?? '';
          _jumlahPenghuniCtrl.text = data['rumah_jumlah_penghuni']?.toString() ?? '0';
          _statusKepemilikan = data['rumah_status_kepemilikan'] ?? 'milik_sendiri';
          _status = data['rumah_status'] ?? 'aktif';
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
      'rumah_alamat': _alamatCtrl.text,
      'rumah_rt': _rtCtrl.text,
      'rumah_rw': _rwCtrl.text,
      'rumah_kelurahan': _kelurahanCtrl.text,
      'rumah_kecamatan': _kecamatanCtrl.text,
      'rumah_kota': _kotaCtrl.text,
      'rumah_provinsi': _provinsiCtrl.text,
      'rumah_kode_pos': _kodePosCtrl.text,
      'rumah_luas_tanah': _luasTanahCtrl.text,
      'rumah_luas_bangunan': _luasBangunanCtrl.text,
      'rumah_jumlah_penghuni': int.tryParse(_jumlahPenghuniCtrl.text) ?? 0,
      'rumah_status_kepemilikan': _statusKepemilikan,
      'rumah_status': _status,
    };

    final success = await _service.saveRumah(data: data, id: widget.rumahId);

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Data berhasil disimpan' : 'Gagal menyimpan data'),
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Data Rumah' : 'Tambah Data Rumah'),
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
                      controller: _alamatCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap *',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _rtCtrl,
                            decoration: const InputDecoration(
                              labelText: 'RT',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _rwCtrl,
                            decoration: const InputDecoration(
                              labelText: 'RW',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kelurahanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kelurahan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kecamatanCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kecamatan',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kotaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kota/Kabupaten',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _provinsiCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Provinsi',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _kodePosCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kode Pos',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _luasTanahCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Luas Tanah (m²)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _luasBangunanCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Luas Bangunan (m²)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _statusKepemilikan,
                      decoration: const InputDecoration(
                        labelText: 'Status Kepemilikan',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'milik_sendiri', child: Text('Milik Sendiri')),
                        DropdownMenuItem(value: 'kontrak', child: Text('Kontrak')),
                        DropdownMenuItem(value: 'sewa', child: Text('Sewa')),
                        DropdownMenuItem(value: 'lainnya', child: Text('Lainnya')),
                      ],
                      onChanged: (v) => setState(() => _statusKepemilikan = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _jumlahPenghuniCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Jumlah Penghuni',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
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
                        DropdownMenuItem(value: 'nonaktif', child: Text('Non-Aktif')),
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
    _alamatCtrl.dispose();
    _rtCtrl.dispose();
    _rwCtrl.dispose();
    _kelurahanCtrl.dispose();
    _kecamatanCtrl.dispose();
    _kotaCtrl.dispose();
    _provinsiCtrl.dispose();
    _kodePosCtrl.dispose();
    _luasTanahCtrl.dispose();
    _luasBangunanCtrl.dispose();
    _jumlahPenghuniCtrl.dispose();
    super.dispose();
  }
}
