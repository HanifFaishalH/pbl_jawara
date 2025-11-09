import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TambahPengeluaranForm extends StatefulWidget {
  const TambahPengeluaranForm({super.key});

  @override
  State<TambahPengeluaranForm> createState() => _TambahPengeluaranFormState();
}

class _TambahPengeluaranFormState extends State<TambahPengeluaranForm> {
  // Kunci global untuk mengidentifikasi dan memvalidasi form
  final _formKey = GlobalKey<FormState>();

  String? selectedKategori;
  File? _receiptImage;
  final TextEditingController _tanggalController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> kategori = [
    'Operasional RT/RW',
    'Kegiatan Sosial',
    'Pemeliharaan Fasilitas',
    'Pembangunan',
    'Kegiatan Warga',
    'Keamanan & Kebersihan',
    'Lain-lain',
  ];

  @override
  void dispose() {
    _tanggalController.dispose();
    super.dispose();
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
    // Jalankan validasi pada semua form field
    if (_formKey.currentState!.validate()) {
      // Jika semua valid, lanjutkan proses penyimpanan data
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Menyimpan data...')));
      // TODO: Tambahkan logika untuk mengirim data ke server/database
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
          // 1. Validasi Nama Pengeluaran
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nama Pengeluaran',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.shopping_bag_outlined),
              filled: true,
              fillColor: fillColor,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama pengeluaran tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 2. Validasi Kategori
          DropdownButtonFormField<String>(
            value: selectedKategori,
            hint: const Text("Pilih Kategori"),
            decoration: InputDecoration(
              labelText: "Kategori",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            items: kategori
                .map(
                  (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: (newValue) =>
                setState(() => selectedKategori = newValue),
            validator: (value) {
              if (value == null) {
                return 'Silakan pilih kategori';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 3. Validasi Nominal
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.monetization_on_outlined),
              prefixText: 'Rp ',
              filled: true,
              fillColor: fillColor,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nominal tidak boleh kosong';
              }
              // Cek apakah input hanya berisi angka
              if (int.tryParse(value.replaceAll('.', '')) == null) {
                return 'Nominal harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // 4. Validasi Tanggal
          TextFormField(
            controller: _tanggalController,
            decoration: InputDecoration(
              labelText: 'Tanggal Pengeluaran',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.calendar_today_outlined),
              filled: true,
              fillColor: fillColor,
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tanggal tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          Text(
            'Bukti Pengeluaran (Opsional)',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildReceiptPicker(context),
          const SizedBox(height: 40),

          ElevatedButton(
            onPressed: _submitForm, // Panggil fungsi submit saat ditekan
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPicker(BuildContext context) {
    // ... (kode ini tidak berubah) ...
    return GestureDetector(
      onTap: () => _pickImage(ImageSource.gallery),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: _receiptImage == null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 36,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('Tap untuk menambahkan foto nota'),
                  ],
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_receiptImage!, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _receiptImage = File(picked.path));
    }
  }
}
