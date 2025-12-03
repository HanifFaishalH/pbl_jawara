import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/finance_service.dart';

class FormPemasukan extends StatefulWidget {
  final Map<String, dynamic>? data;

  const FormPemasukan({super.key, this.data});

  @override
  State<FormPemasukan> createState() => _FormPemasukanState();
}

class _FormPemasukanState extends State<FormPemasukan> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jumlahController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _judulController.text = widget.data!['judul']?.toString() ?? '';
      _deskripsiController.text = widget.data!['deskripsi']?.toString() ?? '';
      _jumlahController.text = widget.data!['jumlah']?.toString() ?? '';
      final tanggal = widget.data!['tanggal']?.toString();
      if (tanggal != null) {
        try {
          _selectedDate = DateTime.parse(tanggal);
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final payload = {
        'judul': _judulController.text,
        'deskripsi': _deskripsiController.text,
        'jumlah': _jumlahController.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
      };
      if (widget.data == null) {
        await FinanceService.createPemasukan(payload);
      } else {
        final id = widget.data!['pemasukan_id'] as int;
        await FinanceService.updatePemasukan(id, payload);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.data == null ? 'Pemasukan berhasil ditambah' : 'Pemasukan berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          widget.data == null ? 'Tambah Pemasukan' : 'Edit Pemasukan',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Nama Pemasukan',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nominal (Rp)',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null) return 'Harus angka';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        widget.data == null ? 'Simpan' : 'Perbarui',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
