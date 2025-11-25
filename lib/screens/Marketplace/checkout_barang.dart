import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';

class CheckoutBarang extends StatefulWidget {
  final dynamic checkoutData;

  const CheckoutBarang({super.key, required this.checkoutData});

  @override
  State<CheckoutBarang> createState() => _CheckoutBarangState();
}

class _CheckoutBarangState extends State<CheckoutBarang> {
  final _catatanController = TextEditingController();
  DateTime _tanggalPengambilan = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _jamPengambilan = const TimeOfDay(hour: 09, minute: 00);
  
  List<Map<String, dynamic>> _itemsToBuy = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _parseData();
  }

  void _parseData() {
    if (widget.checkoutData is Map && widget.checkoutData.containsKey('items')) {
      var list = widget.checkoutData['items'] as List;
      _itemsToBuy = list.map((e) => Map<String, dynamic>.from(e)).toList();
    } else if (widget.checkoutData is Map) {
      Map<String, dynamic> singleItem = Map<String, dynamic>.from(widget.checkoutData);
      if (!singleItem.containsKey('jumlah')) singleItem['jumlah'] = 1;
      _itemsToBuy = [singleItem];
    }
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      int currentQty = int.tryParse(_itemsToBuy[index]['jumlah'].toString()) ?? 1;
      int newQty = currentQty + delta;
      if (newQty > 0) {
        _itemsToBuy[index]['jumlah'] = newQty;
      }
    });
  }

  int get _grandTotal {
    int total = 0;
    for (var item in _itemsToBuy) {
      int harga = int.tryParse(item['harga'].toString()) ?? 0;
      int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
      total += (harga * qty);
    }
    return total;
  }

  // --- LOGIC BARU: CEK APAKAH ALAMAT BEDA-BEDA ---
  Set<String> get _uniqueAddresses {
    return _itemsToBuy.map((e) => e['alamat_penjual'].toString()).toSet();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPengambilan,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalPengambilan = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _jamPengambilan,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Theme.of(context).primaryColor)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _jamPengambilan = picked);
  }

  Future<void> _processOrder() async {
    setState(() => _isProcessing = true);
    try {
      Map<String, dynamic> transactionData = {
        'total_harga': _grandTotal,
        'catatan': _catatanController.text,
        'tanggal_pengambilan': DateFormat('yyyy-MM-dd').format(_tanggalPengambilan),
        'jam_pengambilan': "${_jamPengambilan.hour}:${_jamPengambilan.minute}",
        'barang': _itemsToBuy.map((item) => {
          'barang_id': item['id'],
          'jumlah': item['jumlah'],
          'harga': item['harga']
        }).toList(),
      };

      bool success = await TransaksiService().createTransaction(transactionData);
      
      if (!mounted) return;
      if (success) {
        showDialog(
          context: context, barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                const Text("Pesanan Berhasil!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Stok barang telah diamankan.\nSilakan ambil barang sesuai jadwal.", textAlign: TextAlign.center),
              ],
            ),
            actions: [TextButton(onPressed: () => context.go('/menu-marketplace'), child: const Text("OK"))],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses pesanan"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uniqueLocs = _uniqueAddresses; // Ambil daftar alamat unik

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan", style: TextStyle(color: Colors.white)),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Barang yang dibeli"),
            ..._itemsToBuy.asMap().entries.map((entry) {
              return _buildItemCard(entry.value, entry.key, theme);
            }),

            const SizedBox(height: 20),

            _buildSectionTitle("Lokasi Pengambilan"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      const Text("Alamat Penjual", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // --- LOGIKA TAMPILAN ALAMAT ---
                  if (uniqueLocs.length == 1)
                    // Jika cuma 1 lokasi, tampilkan alamatnya
                    Text(uniqueLocs.first, style: TextStyle(color: Colors.grey[700], height: 1.3))
                  else
                    // Jika lokasi beda-beda, beri peringatan
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange.shade800),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Terdapat ${uniqueLocs.length} lokasi pengambilan berbeda.\nSilakan cek rincian pada tiap barang di atas.",
                              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle("Jadwal Pengambilan"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tanggal Ambil", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  InkWell(
                    onTap: () => _selectTime(context),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Jam Ambil", style: TextStyle(fontSize: 12, color: Colors.grey)),
                              Text(_jamPengambilan.format(context),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            _buildSectionTitle("Detail Pesanan"),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              color: Colors.white,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payments, color: Colors.green),
                    title: const Text("Metode Pembayaran"),
                    subtitle: const Text("Cash / Tunai (Bayar saat ambil)"),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                  const Divider(height: 0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _catatanController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: "Tambah catatan (opsional)...",
                        border: InputBorder.none,
                        icon: Icon(Icons.note_add_outlined, color: Colors.grey),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Tagihan", style: TextStyle(color: Colors.grey)),
                Text("Rp $_grandTotal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              ],
            ),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isProcessing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  // --- ITEM CARD YANG SUDAH DIMODIFIKASI ---
  Widget _buildItemCard(Map<String, dynamic> item, int index, ThemeData theme) {
    int harga = int.tryParse(item['harga'].toString()) ?? 0;
    int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
    String alamat = item['alamat_penjual'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60, height: 60, color: Colors.grey[100],
                  child: item['foto'] != '' && item['foto'] != null
                      ? Image.network(item['foto'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                      : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text("Rp $harga / pcs", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              // Total Harga per item
              Text("Rp ${harga * qty}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // --- BARIS KONTROL JUMLAH & LOKASI ---
          Row(
            children: [
              // LOKASI (Tampil di setiap barang)
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alamat, // Alamat spesifik barang ini
                        maxLines: 1, 
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
              
              // COUNTER (+/-)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(index, -1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.remove, size: 16, color: qty > 1 ? Colors.black : Colors.grey),
                      ),
                    ),
                    Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _updateQuantity(index, 1),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Icon(Icons.add, size: 16, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}