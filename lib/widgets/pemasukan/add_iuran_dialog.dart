import 'package:flutter/material.dart';

class AddIuranDialog extends StatefulWidget {
  final Function(Map<String, String>) onIuranAdded;

  const AddIuranDialog({super.key, required this.onIuranAdded});

  @override
  State<AddIuranDialog> createState() => _AddIuranDialogState();
}

class _AddIuranDialogState extends State<AddIuranDialog> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nominalController = TextEditingController();
  String? _selectedCategory;

  void _submitForm() {
    if (_namaController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap isi semua field"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newIuran = {
      'nama': _namaController.text,
      'jenis': _selectedCategory!,
      'nominal': _nominalController.text.isNotEmpty
          ? 'Rp ${_nominalController.text}'
          : 'Rp 0',
    };

    widget.onIuranAdded(newIuran);
    _resetForm();
    Navigator.of(context).pop();
  }

  void _resetForm() {
    _namaController.clear();
    _nominalController.clear();
    _selectedCategory = null;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Buat Iuran Baru",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Masukkan data iuran baru dengan lengkap.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildNamaField(),
            const SizedBox(height: 16),
            _buildJumlahSection(),
          ],
        ),
      ),
      actions: [_buildCancelButton(), _buildSaveButton()],
    );
  }

  Widget _buildNamaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Nama Iuran",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _namaController,
          decoration: InputDecoration(
            hintText: "Masukkan nama iuran",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJumlahSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jumlah",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Kategori Iuran",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 4),
        _buildCategoryDropdown(),
        const SizedBox(height: 12),
        Text(
          "Nominal Iuran",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _nominalController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Masukkan nominal",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text("Pilih Kategori")),
        DropdownMenuItem(value: "Iuran Bulanan", child: Text("Iuran Bulanan")),
        DropdownMenuItem(value: "Iuran Khusus", child: Text("Iuran Khusus")),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        _resetForm();
      },
      child: Text("Batal", style: TextStyle(color: Colors.grey[600])),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Simpan", style: TextStyle(color: Colors.white)),
    );
  }
}
