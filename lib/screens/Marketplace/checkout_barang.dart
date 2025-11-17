import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CheckoutBarang extends StatefulWidget {
  final Map<String, String> barangData;

  const CheckoutBarang({super.key, required this.barangData});

  @override
  State<CheckoutBarang> createState() => _CheckoutBarangState();
}

class _CheckoutBarangState extends State<CheckoutBarang> {
  // Pilihan Pembayaran
  String _metodePembayaran = 'Cash (Tunai)'; // Hanya ada satu pilihan

  // Pilihan Pengambilan
  DateTime _tanggalPengambilan = DateTime.now().add(const Duration(days: 1));

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengambilan.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(days: 1))
          : _tanggalPengambilan,
      firstDate: DateTime.now().add(const Duration(days: 1)), // Mulai besok
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _tanggalPengambilan) {
      setState(() {
        _tanggalPengambilan = picked;
      });
    }
  }

  void _processPayment() {
    // Simulasi proses pembelian berhasil
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pembelian Berhasil!"),
          content: Text(
              "Anda telah memesan ${widget.barangData['nama']}.\n\nSilahkan ambil barang pada:\nTanggal: ${DateFormat('dd MMMM yyyy').format(_tanggalPengambilan)}\nMetode Pembayaran: $_metodePembayaran (Dibayar saat pengambilan)"),
          actions: [
            TextButton(
              onPressed: () {
                context.go('/daftar-pembelian'); // Kembali ke daftar barang
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final barang = widget.barangData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Checkout Barang",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Barang
            Text("Ringkasan Pesanan", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              title: Text(barang['nama'] ?? 'Barang',
                  style: theme.textTheme.titleSmall),
              subtitle: Text(barang['harga'] ?? 'Rp 0'),
              trailing: Text("Stok: ${barang['stok']}"),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(height: 30),

            // Pilihan Pembayaran
            Text("Metode Pembayaran", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Cash (Tunai)'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
                onTap: () {
                  // Tidak ada pilihan lain, hanya simulasi
                },
              ),
            ),
            const SizedBox(height: 20),

            // Pilihan Pengambilan
            Text("Tanggal & Tempat Pengambilan",
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text("Tanggal: ${DateFormat('dd MMMM yyyy').format(_tanggalPengambilan)}"),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("Tempat Pengambilan"),
                subtitle: Text(barang['alamat'] ?? 'Alamat tidak tersedia'),
              ),
            ),
            const SizedBox(height: 40),

            // Button Konfirmasi Beli
            ElevatedButton.icon(
              onPressed: _processPayment,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: Text(
                "Konfirmasi Beli & Bayar Tunai",
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}