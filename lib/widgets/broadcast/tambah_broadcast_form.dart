import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

class TambahBroadcastForm extends StatefulWidget {
  // Tambahkan parameter opsional untuk menerima data awal (untuk mode edit)
  final Map<String, String>? initialData;

  const TambahBroadcastForm({super.key, this.initialData});

  @override
  State<TambahBroadcastForm> createState() => _TambahBroadcastFormState();
}

class _TambahBroadcastFormState extends State<TambahBroadcastForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers untuk setiap field
  late TextEditingController _judulBroadcast;
  late TextEditingController _isiBroadcast;
  late TextEditingController _tanggalController;
  late TextEditingController _pengirim;
  File? _photo;
  PlatformFile? _document; // file_picker uses PlatformFile

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data awal jika ada (mode edit)
    final data = widget.initialData;
    _judulBroadcast = TextEditingController(text: data?['judul']);
    _isiBroadcast = TextEditingController(text: data?['isi']);
    _tanggalController = TextEditingController(text: data?['tanggal']);
    _pengirim = TextEditingController(text: data?['pengirim']);
  }

  @override
  void dispose() {
    _judulBroadcast.dispose();
    _tanggalController.dispose();
    _pengirim.dispose();
    _isiBroadcast.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _photo = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
      ], // Allow specific document types
    );
    if (result != null) {
      setState(() {
        _document = result.files.first;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        _tanggalController.text = formattedDate;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menyimpan data broadcast...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = theme.colorScheme.primary.withOpacity(0.05);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _judulBroadcast,
            decoration: InputDecoration(
              labelText: 'Judul Broadcast',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Nama broadcast tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _isiBroadcast,
            decoration: InputDecoration(
              labelText: 'Pengirim',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Pengirim tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _tanggalController,
            decoration: InputDecoration(
              labelText: 'Tanggal Pelaksanaan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: const Icon(Icons.calendar_today_outlined),
              filled: true,
              fillColor: fillColor,
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) =>
                value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _isiBroadcast,
            decoration: InputDecoration(
              labelText: 'Isi Broadcast',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            maxLines: 4,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Isi broadcast tidak boleh kosong'
                : null,
          ),
          const SizedBox(height: 20),
          Text('Upload Foto (Opsional)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildImagePicker(context),
          const SizedBox(height: 20),

          Text('Upload Dokumen (Opsional)', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _buildDocumentPicker(context),
          const SizedBox(height: 40),

          ElevatedButton(onPressed: _submitForm, child: const Text('Simpan')),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          /* ... styling ... */ color: Colors.grey.shade100,
        ),
        child: _photo == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.add_a_photo_outlined),
                    Text('Tap untuk tambah foto'),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _photo!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
      ),
    );
  }

  Widget _buildDocumentPicker(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.attach_file),
      label: Text(
        _document == null ? 'Pilih Dokumen (PDF/DOC)' : _document!.name,
      ),
      onPressed: _pickDocument,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
