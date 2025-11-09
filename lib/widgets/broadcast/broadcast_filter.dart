import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BroadcastFilter extends StatefulWidget {
  const BroadcastFilter({super.key});

  @override
  State<BroadcastFilter> createState() => _BroadcastFilterState();
}

class _BroadcastFilterState extends State<BroadcastFilter> {
  String? selectedKategori;
  final TextEditingController _tanggalController = TextEditingController();

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
            labelText: "Nama Broadcast",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _tanggalController,
          decoration: InputDecoration(
            labelText: "Tanggal Dibuat",
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
