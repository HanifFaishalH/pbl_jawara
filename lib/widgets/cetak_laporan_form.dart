import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/finance_service.dart';

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
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _loading = false;

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
    bool isFrom,
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
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  Future<void> _submitCetak() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final from = _fromDate != null ? DateFormat('yyyy-MM-dd').format(_fromDate!) : null;
      final to = _toDate != null ? DateFormat('yyyy-MM-dd').format(_toDate!) : null;

      List<dynamic> dataPemasukan = [];
      List<dynamic> dataPengeluaran = [];
      Map<String, dynamic>? ringkasan;

      if (_selectedJenisLaporan == 'Pemasukan' || _selectedJenisLaporan == 'Semua') {
        final resPemasukan = await FinanceService.listPemasukan(from: from, to: to);
        dataPemasukan = resPemasukan['data'] as List<dynamic>;
      }
      if (_selectedJenisLaporan == 'Pengeluaran' || _selectedJenisLaporan == 'Semua') {
        final resPengeluaran = await FinanceService.listPengeluaran(from: from, to: to);
        dataPengeluaran = resPengeluaran['data'] as List<dynamic>;
      }
      if (_selectedJenisLaporan == 'Semua') {
        ringkasan = await FinanceService.ringkasan(from: from, to: to);
      }

      if (!mounted) return;
      _showPreviewDialog(dataPemasukan, dataPengeluaran, ringkasan);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showPreviewDialog(
    List<dynamic> pemasukan,
    List<dynamic> pengeluaran,
    Map<String, dynamic>? ringkasan,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preview Laporan $_selectedJenisLaporan'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Periode: ${_dariTanggalController.text} - ${_sampaiTanggalController.text}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (ringkasan != null) ...[
                  Text('Total Pemasukan: Rp ${NumberFormat.decimalPattern('id').format(ringkasan['pemasukan'] ?? 0)}',
                      style: const TextStyle(color: Colors.green)),
                  Text('Total Pengeluaran: Rp ${NumberFormat.decimalPattern('id').format(ringkasan['pengeluaran'] ?? 0)}',
                      style: const TextStyle(color: Colors.red)),
                  Text('Saldo: Rp ${NumberFormat.decimalPattern('id').format(ringkasan['saldo'] ?? 0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                ],
                if (pemasukan.isNotEmpty) ...[
                  const Text('Pemasukan:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...pemasukan.map((item) => ListTile(
                        dense: true,
                        title: Text(item['judul'] ?? '-'),
                        subtitle: Text(item['tanggal'] ?? '-'),
                        trailing: Text('Rp ${NumberFormat.decimalPattern('id').format(item['jumlah'] ?? 0)}',
                            style: const TextStyle(color: Colors.green)),
                      )),
                ],
                if (pengeluaran.isNotEmpty) ...[
                  const Text('Pengeluaran:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...pengeluaran.map((item) => ListTile(
                        dense: true,
                        title: Text(item['judul'] ?? '-'),
                        subtitle: Text(item['tanggal'] ?? '-'),
                        trailing: Text('Rp ${NumberFormat.decimalPattern('id').format(item['jumlah'] ?? 0)}',
                            style: const TextStyle(color: Colors.red)),
                      )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur download PDF akan segera tersedia')),
              );
            },
            child: const Text('Download PDF'),
          ),
        ],
      ),
    );
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
            onTap: () => _selectDate(context, _dariTanggalController, true),
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
            onTap: () => _selectDate(context, _sampaiTanggalController, false),
            validator: (value) =>
                value == null || value.isEmpty ? 'Tanggal harus diisi' : null,
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _loading ? null : _submitCetak,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text("Cetak"),
          ),
        ],
      ),
    );
  }
}
