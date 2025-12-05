import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/mutasi_warga_service.dart';
import 'package:jawaramobile_1/services/warga_service.dart';
import 'package:intl/intl.dart';

class FormMutasiWargaScreen extends StatefulWidget {
  final int? mutasiId;

  const FormMutasiWargaScreen({super.key, this.mutasiId});

  @override
  State<FormMutasiWargaScreen> createState() => _FormMutasiWargaScreenState();
}

class _FormMutasiWargaScreenState extends State<FormMutasiWargaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = MutasiWargaService();
  final _wargaService = WargaService();

  bool _loading = false;
  bool _loadingWarga = true;
  List<dynamic> _wargaList = [];

  int? _selectedWargaId;
  String _selectedJenis = 'kelahiran';
  DateTime _selectedDate = DateTime.now();
  String _selectedStatus = 'pending';

  final _keteranganController = TextEditingController();
  final _alamatAsalController = TextEditingController();
  final _alamatTujuanController = TextEditingController();

  bool get isEdit => widget.mutasiId != null;

  @override
  void initState() {
    super.initState();
    _loadWarga();
    if (isEdit) _loadMutasi();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    _alamatAsalController.dispose();
    _alamatTujuanController.dispose();
    super.dispose();
  }

  Future<void> _loadWarga() async {
    try {
      final data = await _wargaService.getWarga();
      if (mounted) {
        setState(() {
          _wargaList = data;
          _loadingWarga = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingWarga = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data warga: $e')),
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
          _selectedWargaId = data['warga_id'];
          _selectedJenis = data['mutasi_jenis'] ?? 'kelahiran';
          _selectedDate = DateTime.parse(data['mutasi_tanggal']);
          _selectedStatus = data['mutasi_status'] ?? 'pending';
          _keteranganController.text = data['mutasi_keterangan'] ?? '';
          _alamatAsalController.text = data['mutasi_alamat_asal'] ?? '';
          _alamatTujuanController.text = data['mutasi_alamat_tujuan'] ?? '';
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
      'warga_id': _selectedWargaId,
      'mutasi_jenis': _selectedJenis,
      'mutasi_tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'mutasi_keterangan': _keteranganController.text,
      'mutasi_alamat_asal': _alamatAsalController.text,
      'mutasi_alamat_tujuan': _alamatTujuanController.text,
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

  bool _needsAlamat() {
    return ['pindah_masuk', 'pindah_keluar'].contains(_selectedJenis);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Mutasi Warga' : 'Tambah Mutasi Warga',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading || _loadingWarga
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Informasi Warga',
                      children: [
                        _buildDropdown(
                          label: 'Warga',
                          value: _selectedWargaId,
                          items: _wargaList
                              .map((w) => DropdownMenuItem<int>(
                                    value: w['warga_id'],
                                    child: Text(w['warga_nama'] ?? '-'),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedWargaId = value),
                          validator: (value) =>
                              value == null ? 'Pilih warga' : null,
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
                                value: 'kelahiran', child: Text('Kelahiran')),
                            DropdownMenuItem(
                                value: 'kematian', child: Text('Kematian')),
                            DropdownMenuItem(
                                value: 'pindah_masuk', child: Text('Pindah Masuk')),
                            DropdownMenuItem(
                                value: 'pindah_keluar',
                                child: Text('Pindah Keluar')),
                            DropdownMenuItem(
                                value: 'perubahan_status',
                                child: Text('Perubahan Status')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedJenis = value!),
                        ),
                        const SizedBox(height: 16),
                        _buildDateField(),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _keteranganController,
                          label: 'Keterangan',
                          maxLines: 3,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Wajib diisi' : null,
                        ),
                        if (_needsAlamat()) ...[
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _alamatAsalController,
                            label: 'Alamat Asal',
                            maxLines: 2,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _alamatTujuanController,
                            label: 'Alamat Tujuan',
                            maxLines: 2,
                            validator: (value) =>
                                value?.isEmpty ?? true ? 'Wajib diisi' : null,
                          ),
                        ],
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
                          backgroundColor: theme.colorScheme.tertiary,
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
