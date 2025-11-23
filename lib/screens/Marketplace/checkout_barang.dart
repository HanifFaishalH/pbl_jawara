import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CheckoutBarang extends StatefulWidget {
  // Menggunakan dynamic agar bisa menerima data Single (Map) atau Bulk (Map dengan List)
  final dynamic checkoutData;

  const CheckoutBarang({super.key, required this.checkoutData});

  @override
  State<CheckoutBarang> createState() => _CheckoutBarangState();
}

class _CheckoutBarangState extends State<CheckoutBarang> {
  final String _metodePembayaran = 'Cash (Tunai)';
  DateTime _tanggalPengambilan = DateTime.now().add(const Duration(days: 1));

  List<Map<String, dynamic>> _itemsToBuy = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _parseData();
  }

  void _parseData() {
    // Skenario 1: Dari Keranjang (Ada key 'items')
    if (widget.checkoutData is Map && widget.checkoutData.containsKey('items')) {
      var list = widget.checkoutData['items'] as List;
      _itemsToBuy = list.map((e) => Map<String, dynamic>.from(e)).toList();
    } 
    // Skenario 2: Beli Langsung / Single Item
    else if (widget.checkoutData is Map) {
      Map<String, dynamic> singleItem = Map<String, dynamic>.from(widget.checkoutData);
      
      // Pastikan ada key jumlah, default 1
      if (!singleItem.containsKey('jumlah')) {
        singleItem['jumlah'] = "1";
      }
      _itemsToBuy = [singleItem];
    }
  }

  // Hitung Grand Total
  int get _grandTotal {
    int total = 0;
    for (var item in _itemsToBuy) {
      int harga = int.tryParse(item['harga'].toString()) ?? 0;
      int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
      total += (harga * qty);
    }
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengambilan,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _tanggalPengambilan = picked);
  }

  void _processPayment() {
    // TODO: Panggil API Transaksi disini
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text("Pesanan Berhasil!"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Item: ${_itemsToBuy.length}"),
                const Divider(),
                // Tampilkan list barang yang dibeli
                ..._itemsToBuy.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text("- ${e['nama']} (${e['jumlah']}x)"),
                )),
                const Divider(),
                Text("Total Bayar: Rp $_grandTotal", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Ambil pada: ${DateFormat('dd MMM yyyy', 'id_ID').format(_tanggalPengambilan)}"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.go('/daftar-pembelian'),
              child: const Text("Selesai"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Daftar Pesanan", style: theme.textTheme.titleMedium),
            const SizedBox(height: 10),
            
            // LIST BARANG
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _itemsToBuy.length,
              itemBuilder: (context, index) {
                final item = _itemsToBuy[index];
                final int totalItemPrice = (int.tryParse(item['harga'].toString()) ?? 0) * (int.tryParse(item['jumlah'].toString()) ?? 1);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 50, height: 50, color: Colors.grey[200],
                        child: item['foto'] != '' 
                          ? Image.network(item['foto'], fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))
                          : const Icon(Icons.image),
                      ),
                    ),
                    title: Text(item['nama']),
                    subtitle: Text("${item['jumlah']} x Rp ${item['harga']}"),
                    trailing: Text(
                      "Rp $totalItemPrice",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),

            const Divider(height: 30),

            // OPSI PEMBAYARAN
            Text("Metode Pembayaran", style: theme.textTheme.titleMedium),
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.money, color: Colors.green),
                title: Text(_metodePembayaran, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Bayar Tunai"),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // OPSI PENGAMBILAN
            Text("Rencana Pengambilan", style: theme.textTheme.titleMedium),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan)),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectDate(context),
              ),
            ),
            
            // Lokasi (Ambil dari item pertama saja sebagai referensi)
            if (_itemsToBuy.isNotEmpty)
               Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text("Lokasi Penjual"),
                  subtitle: Text(_itemsToBuy.first['alamat'] ?? '-'),
                ),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Tagihan"),
                Text("Rp $_grandTotal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("Bayar Sekarang", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}