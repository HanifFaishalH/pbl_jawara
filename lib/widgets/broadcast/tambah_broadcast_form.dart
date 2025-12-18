import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/broadcast_service.dart';

class TambahBroadcastForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const TambahBroadcastForm({super.key, this.initialData});

  @override
  State<TambahBroadcastForm> createState() => _TambahBroadcastFormState();
}

class _TambahBroadcastFormState extends State<TambahBroadcastForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _pengirimController;
  late TextEditingController _tanggalController;
  late TextEditingController _isiController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    _judulController = TextEditingController(text: data['judul'] ?? '');
    _pengirimController = TextEditingController(text: data['pengirim'] ?? '');
    _tanggalController = TextEditingController(text: data['tanggal'] ?? '');
    _isiController = TextEditingController(text: data['isi_pesan'] ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengirimController.dispose();
    _tanggalController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _tanggalController.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'judul': _judulController.text.trim(),
      'pengirim': _pengirimController.text.trim(),
      'tanggal': _tanggalController.text.trim(),
      'isi_pesan': _isiController.text.trim(),
    };

    try {
      final message = await BroadcastService().createBroadcast(data: data);

      if (!mounted) return;

      if (message.contains('berhasil')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.pop(context, true);
      } else {
        _showAlertDialog('Gagal', message);
      }
    } catch (_) {
      _showAlertDialog('Kesalahan', 'Gagal menyimpan broadcast.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final fillColor = color.primary.withOpacity(0.05);

    return AbsorbPointer(
      absorbing: _isLoading,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildField(_judulController, 'Judul Broadcast', fillColor),
            const SizedBox(height: 16),
            _buildField(_pengirimController, 'Pengirim', fillColor),
            const SizedBox(height: 16),
            _buildDateField(context, fillColor),
            const SizedBox(height: 16),
            _buildField(_isiController, 'Isi Broadcast', fillColor, maxLines: 4),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_isLoading ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    Color fillColor, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
      ),
      validator: (v) => v == null || v.isEmpty ? '$label wajib diisi' : null,
    );
  }

  Widget _buildDateField(BuildContext context, Color fillColor) {
    return TextFormField(
      controller: _tanggalController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Tanggal',
        suffixIcon: const Icon(Icons.calendar_today),
        filled: true,
        fillColor: fillColor,
      ),
      onTap: () => _selectDate(context),
      validator: (v) => v == null || v.isEmpty ? 'Tanggal wajib diisi' : null,
    );
  }
}
