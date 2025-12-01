import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class TambahBroadcastForm extends StatefulWidget {
  final Map<String, dynamic>? initialData; // null kalau tambah, ada data kalau edit
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

  File? _photo;
  PlatformFile? _document;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final data = widget.initialData ?? {};

    _judulController =
        TextEditingController(text: data['judul']?.toString() ?? '');
    _pengirimController =
        TextEditingController(text: data['pengirim']?.toString() ?? '');
    _tanggalController =
        TextEditingController(text: data['tanggal']?.toString() ?? '');
    _isiController =
        TextEditingController(text: data['isi_pesan']?.toString() ?? '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengirimController.dispose();
    _tanggalController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _photo = File(image.path));
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) setState(() => _document = result.files.first);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      _tanggalController.text = DateFormat('dd MMM yyyy').format(picked);
      setState(() {});
    }
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'judul': _judulController.text.trim(),
      'pengirim': _pengirimController.text.trim(),
      'tanggal': _tanggalController.text.trim(),
      'isi_pesan': _isiController.text.trim(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data broadcast disimpan (dummy)')),
    );

    // TODO: panggil service API di sini
    print('📤 Data Broadcast: $data');
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final fillColor = color.primary.withOpacity(0.05);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(_judulController, 'Judul Broadcast', fillColor),
          const SizedBox(height: 16),
          _buildTextField(_pengirimController, 'Pengirim', fillColor),
          const SizedBox(height: 16),
          _buildDateField(context, fillColor),
          const SizedBox(height: 16),
          _buildTextField(_isiController, 'Isi Broadcast', fillColor, maxLines: 4),
          const SizedBox(height: 24),
          _buildImagePicker(context),
          const SizedBox(height: 16),
          _buildDocumentPicker(context),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _submitForm,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: color.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      Color fillColor,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: fillColor,
      ),
      validator: (value) =>
      value == null || value.trim().isEmpty ? '$label tidak boleh kosong' : null,
    );
  }

  Widget _buildDateField(BuildContext context, Color fillColor) {
    return TextFormField(
      controller: _tanggalController,
      decoration: InputDecoration(
        labelText: 'Tanggal Broadcast',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        filled: true,
        fillColor: fillColor,
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
      validator: (value) =>
      value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _photo == null
            ? const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_a_photo_outlined),
              Text('Tap untuk tambah foto'),
            ],
          ),
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
        ),
      ),
    );
  }

  Widget _buildDocumentPicker(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.attach_file),
      label: Text(_document == null
          ? 'Pilih Dokumen (PDF/DOC)'
          : _document!.name),
      onPressed: _pickDocument,
    );
  }
}
