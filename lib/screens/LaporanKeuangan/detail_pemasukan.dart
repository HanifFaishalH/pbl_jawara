import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/finance_service.dart';

class DetailPemasukan extends StatefulWidget {
  // Data Pemasukan akan diterima melalui constructor
  final Map<String, dynamic> pemasukanData;

  const DetailPemasukan({super.key, required this.pemasukanData});

  @override
  State<DetailPemasukan> createState() => _DetailPemasukanState();
}

class _DetailPemasukanState extends State<DetailPemasukan> {

  // Widget helper untuk membuat baris detail (Label: Value)
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isNominal = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[900]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isNominal
                    ? Colors.green[700]
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus pemasukan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    try {
      final id = widget.pemasukanData['pemasukan_id'] as int;
      await FinanceService.deletePemasukan(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pemasukan berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          "Detail Pemasukan",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await context.push('/form-pemasukan', extra: widget.pemasukanData);
              if (result == true && mounted) context.pop(true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        context,
                        "Nama Pemasukan",
                        widget.pemasukanData['judul']?.toString() ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Tanggal",
                        widget.pemasukanData['tanggal']?.toString() ?? '-',
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Nominal",
                        'Rp ${NumberFormat.decimalPattern('id').format(int.tryParse(widget.pemasukanData['jumlah']?.toString() ?? '0') ?? 0)}',
                        isNominal: true,
                      ),
                      const Divider(height: 1),
                      _buildDetailRow(
                        context,
                        "Deskripsi",
                        widget.pemasukanData['deskripsi']?.toString() ?? '-',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Bukti Pemasukan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              // Placeholder untuk gambar bukti
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade100,
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
