import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CetakLaporanForm extends StatefulWidget {
  const CetakLaporanForm({super.key});

  @override
  State<CetakLaporanForm> createState() => _CetakLaporanFormState();
}

class _CetakLaporanFormState extends State<CetakLaporanForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedJenisLaporan;
  final _dariTanggalController = TextEditingController();
  final _sampaiTanggalController = TextEditingController();

  final List<String> _jenisLaporan = ['Pemasukan', 'Pengeluaran', 'Semua'];

  @override
  void dispose() {
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formattedDate = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _submitCetak() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementasikan logika untuk generate dan mencetak laporan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mempersiapkan laporan untuk dicetak...')),
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
          // 1. Dropdown Jenis Laporan
          DropdownButtonFormField<String>(
            value: _selectedJenisLaporan,
            hint: const Text("Pilih Jenis Laporan"),
            decoration: InputDecoration(
              labelText: "Jenis Laporan",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            items: _jenisLaporan.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (newValue) =>
                setState(() => _selectedJenisLaporan = newValue),
            validator: (value) =>
                value == null ? 'Silakan pilih jenis laporan' : null,
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _dariTanggalController,
            decoration: InputDecoration(
              labelText: "Dari Tanggal",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor: fillColor,
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _dariTanggalController),
            validator: (value) =>
                value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
          ),

          const SizedBox(height: 20),
          TextFormField(
            controller: _sampaiTanggalController,
            decoration: InputDecoration(
              labelText: "Sampai Tanggal",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
              filled: true,
              fillColor: fillColor,
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _sampaiTanggalController),
            validator: (value) =>
                value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
          ),
          const SizedBox(height: 30),

          ElevatedButton(onPressed: _submitCetak, child: const Text("Cetak")),
        ],
      ),
    );
  }
}
