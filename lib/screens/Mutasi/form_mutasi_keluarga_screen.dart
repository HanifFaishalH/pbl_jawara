import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/mutasi_keluarga_service.dart';
import 'package:jawaramobile_1/services/keluarga_service.dart';
import 'package:intl/intl.dart';

class FormMutasiKeluargaScreen extends StatefulWidget {
  final int? mutasiId;

  const FormMutasiKeluargaScreen({super.key, this.mutasiId});

  @override
  State<FormMutasiKeluargaScreen> createState() =>
      _FormMutasiKeluargaScreenState();
}

class _FormMutasiKeluargaScreenState extends State<FormMutasiKeluargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MutasiKeluargaService();
  final _keluargaService = KeluargaService();

  bool _loading = false;
  bool _loadingKeluarga = true;
  List<dynamic> _keluargaList = [];

  int? _selectedKeluargaId;
  String _selectedJenis = 'pindah_rumah';
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'pending';

  final _alamatLamaController = TextEditingController();
  final _alamatBaruController = TextEditingController();
  final _rtLamaController = TextEditingController();
  final _rwLamaController = TextEditingController();
  final _rtBaruController = TextEditingController();
  final _rwBaruController = TextEditingController();
  final _alasanController = TextEditingController();
  final _keteranganController = TextEditingController();

  bool get isEdit => widget.mutasiId != null;

  @override
  void initState() {
    super.initState();
    _loadKeluarga();
    if (isEdit) _loadMutasi();
  }

  @override
  void dispose() {
    _alamatLamaController.dispose();
    _alamatBaruController.dispose();
    _rtLamaController.dispose();
    _rwLamaController.dispose();
    _rtBaruController.dispose();
    _rwBaruController.dispose();
    _alasanController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadKeluarga() async {
    try {
      final data = await _keluargaService.getKeluarga();
      if (mounted) {
        setState(() {
          _keluargaList = data;
          _loadingKeluarga = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingKeluarga = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data keluarga: $e')),
        );
      }
    }
  }

  Future<void> _loadMutasi() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getMutasiById(widget.mutasiId!);
      if (mounted) {
        setState(() {
          _selectedKeluargaId = data['keluarga_id'];
          _selectedJenis = data['mutasi_jenis'] ?? 'pindah_rumah';
          _selectedDate = DateTime.parse(data['mutasi_tanggal']);
          _selectedStatus = data['mutasi_status'] ?? 'pending';
          _alamatLamaController.text = data['mutasi_alamat_lama'] ?? '';
          _alamatBaruController.text = data['mutasi_alamat_baru'] ?? '';
          _rtLamaController.text = data['mutasi_rt_lama'] ?? '';
          _rwLamaController.text = data['mutasi_rw_lama'] ?? '';
          _rtBaruController.text = data['mutasi_rt_baru'] ?? '';
          _rwBaruController.text = data['mutasi_rw_baru'] ?? '';
          _alasanController.text = data['mutasi_alasan'] ?? '';
          _keteranganController.text = data['mutasi_keterangan'] ?? '';
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final data = {
      'keluarga_id': _selectedKeluargaId,
      'mutasi_jenis': _selectedJenis,
      'mutasi_tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'mutasi_alamat_lama': _alamatLamaController.text,
      'mutasi_alamat_baru': _alamatBaruController.text,
      'mutasi_rt_lama': _rtLamaController.text,
      'mutasi_rw_lama': _rwLamaController.text,
      'mutasi_rt_baru': _rtBaruController.text,
      'mutasi_rw_baru': _rwBaruController.text,
      'mutasi_alasan': _alasanController.text,
      'mutasi_keterangan': _keteranganController.text,
      'mutasi_status': _selectedStatus,
    };

    try {
      final success = isEdit
          ? await _service.updateMutasi(widget.mutasiId!, data)
          : await _service.createMutasi(data);

      if (mounted) {
        setState(() => _loading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit
                  ? 'Data berhasil diperbarui'
                  : 'Data berhasil ditambahkan'),
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan data')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Mutasi Keluarga' : 'Tambah Mutasi Keluarga',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: _loading || _loadingKeluarga
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Informasi Keluarga',
                      children: [
                        _buildDropdown(
                          label: 'Keluarga',
                          value: _selectedKeluargaId,
                          items: _keluargaList
                              .map((k) => DropdownMenuItem<int>(
                                    value: k['keluarga_id'],
                                    child: Text(k['keluarga_nama_kepala'] ?? '-'),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedKeluargaId = value),
                          validator: (value) =>
                              value == null ? 'Pilih keluarga' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildCard(
                      title: 'Detail Mutasi',
                      children: [
                        _buildDropdown(
                          label: 'Jenis Mutasi',
                          value: _selectedJenis,
                          items: const [
                            DropdownMenuItem(
                                value: 'pindah_rumah', child: Text('Pindah Rumah')),
                            DropdownMenuItem(
                                value: 'keluar_wilayah',
                                child: Text('Keluar Wilayah')),
                            DropdownMenuItem(
                                value: 'masuk_wilayah',
                                child: Text('Masuk Wilayah')),
                            DropdownMenuItem(
                                value: 'pindah_rt_rw', child: Text('Pindah RT/RW')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedJenis = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _alamatLamaController,
                          label: 'Alamat Lama',
                          maxLines: 2,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _alamatBaruController,
                          label: 'Alamat Baru',
                          maxLines: 2,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _rtLamaController,
                                label: 'RT Lama',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _rwLamaController,
                                label: 'RW Lama',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _rtBaruController,
                                label: 'RT Baru',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _rwBaruController,
                                label: 'RW Baru',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _alasanController,
                          label: 'Alasan',
                          maxLines: 3,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _keteranganController,
                          label: 'Keterangan (Opsional)',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildDropdown(
                          label: 'Status',
                          value: _selectedStatus,
                          items: const [
                            DropdownMenuItem(
                                value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(
                                value: 'disetujui', child: Text('Disetujui')),
                            DropdownMenuItem(
                                value: 'ditolak', child: Text('Ditolak')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEdit ? 'Perbarui' : 'Simpan',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date != null) {
          setState(() => _selectedDate = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Tanggal Mutasi',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
      ),
    );
  }
}
