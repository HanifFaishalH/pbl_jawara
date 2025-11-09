import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PengeluaranFilter extends StatefulWidget {
  const PengeluaranFilter({super.key});

  @override
  State<PengeluaranFilter> createState() => _PengeluaranFilterState();
}

class _PengeluaranFilterState extends State<PengeluaranFilter> {
  String? selectedKategori;
  final TextEditingController _dariTanggalController = TextEditingController();
  final TextEditingController _sampaiTanggalController =
      TextEditingController();

  final List<String> kategori = [
    'Operasional RT/RW',
    'Kegiatan Sosial',
    'Pemeliharaan Fasilitas',
    'Pembangunan',
    'Kegiatan Warga',
    'Keamanan & Kebersihan',
    'Lain-lain',
  ];

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

  @override
  void dispose() {
    _dariTanggalController.dispose();
    _sampaiTanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Widget ini tidak lagi dibungkus Card, agar bisa masuk ke content dialog
    return Column(
      mainAxisSize: MainAxisSize.min, // Penting agar dialog tidak terlalu besar
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: "Nama",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedKategori,
          hint: const Text("Pilih Kategori"),
          isExpanded: true,
          decoration: InputDecoration(
            labelText: "Kategori",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: kategori
              .map(
                (String value) =>
                    DropdownMenuItem<String>(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (newValue) => setState(() => selectedKategori = newValue),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _dariTanggalController,
          decoration: InputDecoration(
            labelText: "Dari Tanggal",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, _dariTanggalController),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _sampaiTanggalController,
          decoration: InputDecoration(
            labelText: "Sampai Tanggal",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, _sampaiTanggalController),
        ),
      ],
    );
  }
}
