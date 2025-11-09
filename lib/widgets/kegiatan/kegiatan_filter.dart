import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class KegiatanFilter extends StatefulWidget {
  const KegiatanFilter({super.key});

  @override
  State<KegiatanFilter> createState() => _KegiatanFilterState();
}

class _KegiatanFilterState extends State<KegiatanFilter> {
  String? selectedKategori;
  final TextEditingController _tanggalController = TextEditingController();

  final List<String> kategori = [
    'Komunitas & Sosial',
    'Kebersihan & Keamanan',
    'Keagamaan',
    'Pendidikan',
    'Kesehatan & Olahraga',
    'Lainnya',
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
    _tanggalController.dispose();
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
            labelText: "Nama Kegiatan",
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
          controller: _tanggalController,
          decoration: InputDecoration(
            labelText: "Tanggal Pelaksanaan",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          readOnly: true,
          onTap: () => _selectDate(context, _tanggalController),
        ),
      ],
    );
  }
}
