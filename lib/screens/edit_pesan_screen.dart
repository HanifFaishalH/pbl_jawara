import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';

class EditPesanScreen extends StatefulWidget {
  const EditPesanScreen({super.key});

  @override
  State<EditPesanScreen> createState() => _EditPesanScreenState();
}

class _EditPesanScreenState extends State<EditPesanScreen> {
  String? _selectedStatus = 'Diterima';
  final List<String> _statuses = ['Diterima', 'Pending', 'Ditolak'];
  final TextEditingController _judulController =
  TextEditingController(text: 'titootit');
  final TextEditingController _deskripsiController =
  TextEditingController(text: 'mobile igmana bang');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Edit Aspirasi Warga',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Informasi Aspirasi Warga',
                style: theme.textTheme.titleLarge!.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Judul Pesan
              Text(
                'Judul Pesan',
                style: theme.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _judulController,
                style: const TextStyle(color: AppTheme.primary),
                decoration: InputDecoration(
                  hintText: 'Masukkan judul pesan...',
                  filled: true,
                  fillColor: AppTheme.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.fourth, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.third, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Deskripsi Pesan
              Text(
                'Deskripsi Pesan',
                style: theme.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _deskripsiController,
                maxLines: 5,
                style: const TextStyle(color: AppTheme.primary),
                decoration: InputDecoration(
                  hintText: 'Tuliskan deskripsi pesan...',
                  filled: true,
                  fillColor: AppTheme.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.fourth, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.third, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Status Dropdown
              Text(
                'Status',
                style: theme.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.background,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.fourth, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                    const BorderSide(color: AppTheme.third, width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ),
              const SizedBox(height: 30),

              // Update Button
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 150,
                  height: 45,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save, color: Colors.white),
                    onPressed: () {
                      print('Judul: ${_judulController.text}');
                      print('Deskripsi: ${_deskripsiController.text}');
                      print('Status: $_selectedStatus');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perubahan berhasil disimpan!'),
                          backgroundColor: AppTheme.third,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.third,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    label: const Text(
                      'Update',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
}
