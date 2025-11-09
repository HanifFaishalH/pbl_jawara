import 'package:flutter/material.dart';

class JenisIuranSection extends StatelessWidget {
  final List<Map<String, String>> availableIuran;
  final String? selectedIuran;
  final Map<String, String>? selectedIuranData;
  final Function(String?) onIuranChanged;
  final VoidCallback onIuranCleared;

  const JenisIuranSection({
    super.key,
    required this.availableIuran,
    required this.selectedIuran,
    required this.selectedIuranData,
    required this.onIuranChanged,
    required this.onIuranCleared,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Jenis Iuran",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selectedIuran == null
              ? _buildIuranDropdown()
              : _buildSelectedIuranCard(),
        ),
      ],
    );
  }

  Widget _buildIuranDropdown() {
    return DropdownButton<String>(
      value: selectedIuran,
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text(
        "Pilih Jenis Iuran",
        style: TextStyle(color: Colors.grey[500]),
      ),
      items: availableIuran.map((iuran) {
        return DropdownMenuItem<String>(
          value: iuran['no'],
          child: Text(iuran['nama']!),
        );
      }).toList(),
      onChanged: onIuranChanged,
    );
  }

  Widget _buildSelectedIuranCard() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedIuranData!['nama']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${selectedIuranData!['jenis']} • ${selectedIuranData!['nominal']}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onIuranCleared,
            ),
            Container(height: 20, width: 1, color: Colors.grey[300]),
            IconButton(
              icon: Icon(Icons.check, size: 20, color: Colors.green[700]),
              onPressed: () {
                // Konfirmasi pilihan iuran
              },
            ),
          ],
        ),
      ],
    );
  }
}
