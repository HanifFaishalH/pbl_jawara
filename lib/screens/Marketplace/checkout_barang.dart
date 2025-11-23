import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
// 1. TAMBAHKAN IMPORT INI AGAR BISA BAHASA INDONESIA
import 'package:intl/date_symbol_data_local.dart'; 

class CheckoutBarang extends StatefulWidget {
  final Map<String, String> barangData;

  const CheckoutBarang({super.key, required this.barangData});

  @override
  State<CheckoutBarang> createState() => _CheckoutBarangState();
}

class _CheckoutBarangState extends State<CheckoutBarang> {
  // Pilihan Pembayaran
  final String _metodePembayaran = 'Cash (Tunai)'; 

  // Pilihan Pengambilan (Default: Besok)
  DateTime _tanggalPengambilan = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    // 2. TAMBAHKAN KODE INI UNTUK INISIALISASI LOCALE INDONESIA
    initializeDateFormatting('id_ID', null);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengambilan.isBefore(DateTime.now())
          ? DateTime.now().add(const Duration(days: 1))
          : _tanggalPengambilan,
      firstDate: DateTime.now().add(const Duration(days: 1)), 
      lastDate: DateTime.now().add(const Duration(days: 30)), 
    );
    if (picked != null && picked != _tanggalPengambilan) {
      setState(() {
        _tanggalPengambilan = picked;
      });
    }
  }

  void _processPayment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text("Pesanan Berhasil!"),
          content: Text(
              "Anda telah memesan ${widget.barangData['nama']}.\n\n"
              "Silahkan ambil barang pada:\n"
              // Pastikan locale 'id_ID' sudah di-init di initState
              "📅 ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan)}\n"
              "📍 ${widget.barangData['alamat']}\n\n"
              "Mohon siapkan uang tunai saat pengambilan."
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.go('/daftar-pembelian'); 
              },
              child: const Text("OK, Kembali Belanja"),
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
    
    // Ekstraksi Data Aman
    final String nama = widget.barangData['nama'] ?? 'Barang Tanpa Nama';
    final String harga = widget.barangData['harga'] ?? '0';
    final String stok = widget.barangData['stok'] ?? '0';
    final String alamat = widget.barangData['alamat'] ?? '-';
    final String fotoUrl = widget.barangData['foto'] ?? '';

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
            // --- RINGKASAN BARANG ---
            Text("Ringkasan Pesanan", style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Gambar Kecil (Thumbnail)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: fotoUrl.isNotEmpty
                            ? Image.network(
                                fotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, _) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                              )
                            : const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Detail Teks
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Rp $harga",
                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Stok Tersedia: $stok",
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 40),

            // --- PILIHAN PEMBAYARAN ---
            Text("Metode Pembayaran", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: Colors.green.shade50, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.green.shade200),
              ),
              child: ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: Text(_metodePembayaran, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Bayar langsung di tempat"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),

            // --- PILIHAN PENGAMBILAN ---
            Text("Detail Pengambilan", style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            
            // Tanggal
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: const Text("Rencana Tanggal Ambil"),
                subtitle: Text(
                  // Menggunakan 'id_ID' untuk Bahasa Indonesia
                  DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan), 
                ),
                trailing: const Icon(Icons.edit_calendar),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 8),
            
            // Lokasi
            Card(
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: const Text("Lokasi Penjual"),
                subtitle: Text(alamat),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL KONFIRMASI ---
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, 
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.check, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Konfirmasi Pesanan",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}