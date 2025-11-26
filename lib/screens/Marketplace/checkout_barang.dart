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

  // Warna Brand Utama
  final Color jawaraColor = const Color(0xFF26547C);

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

  String _formatRupiah(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

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
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: jawaraColor),
        ),
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
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: jawaraColor),
        ),
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
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal memproses pesanan"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, color: Colors.green[600], size: 70),
              const SizedBox(height: 16),
              const Text("Pesanan Berhasil!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Silakan ambil barang sesuai jadwal yang telah Anda tentukan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jawaraColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: () => context.go('/daftar-pembelian'), 
                  child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: jawaraColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. INFO LOKASI (JIKA BEDA-BEDA)
                  if (_uniqueAddresses.length > 1) 
                    Container(
                      color: Colors.orange.shade50,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Barang berasal dari ${_uniqueAddresses.length} lokasi berbeda. Cek detail di bawah.",
                              style: TextStyle(color: Colors.orange.shade900, fontSize: 13),
                            ),
                          )
                        ],
                      ),
                    ),

                  // 2. LIST BARANG
                  ..._itemsToBuy.asMap().entries.map((entry) {
                    return _buildItemCard(entry.value, entry.key);
                  }),

                  _buildDivider(),

                  // 3. JADWAL PENGAMBILAN
                  _buildSectionHeader("Jadwal Pengambilan", Icons.calendar_month_outlined),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        _buildClickableRow(
                          "Tanggal", 
                          DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan),
                          () => _selectDate(context)
                        ),
                        const Divider(height: 1, indent: 16),
                        _buildClickableRow(
                          "Waktu", 
                          _jamPengambilan.format(context),
                          () => _selectTime(context)
                        ),
                      ],
                    ),
                  ),

                  _buildDivider(),

                  // 4. METODE PEMBAYARAN & CATATAN
                  _buildSectionHeader("Rincian Lainnya", Icons.receipt_long_outlined),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Metode Pembayaran", style: TextStyle(fontSize: 14)),
                            Row(
                              children: [
                                const Icon(Icons.money, color: Colors.green, size: 20),
                                const SizedBox(width: 6),
                                Text("Bayar Tunai", style: TextStyle(color: jawaraColor, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _catatanController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: "Tulis pesan untuk penjual (opsional)...",
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  _buildDivider(),

                  // 5. RINGKASAN PEMBAYARAN
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rincian Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Subtotal Produk", style: TextStyle(color: Colors.grey[600])),
                            Text(_formatRupiah(_grandTotal), style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Biaya Layanan", style: TextStyle(color: Colors.grey[600])),
                            const Text("Rp 0", style: TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(_formatRupiah(_grandTotal), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: jawaraColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Spacer untuk Bottom Bar
                ],
              ),
            ),
          ),

          // BOTTOM ACTION BAR
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Total Tagihan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(_formatRupiah(_grandTotal), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jawaraColor)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _processOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: jawaraColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Buat Pesanan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildDivider() {
    return Container(height: 8, color: Colors.grey[100]);
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: jawaraColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildClickableRow(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[700])),
            Row(
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, int index) {
    int harga = int.tryParse(item['harga'].toString()) ?? 0;
    int qty = int.tryParse(item['jumlah'].toString()) ?? 1;
    String alamat = item['alamat_penjual'] ?? '-';
    String foto = item['foto'] ?? '';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 1), // Garis tipis pemisah
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Toko / Lokasi
          Row(
            children: [
              const Icon(Icons.store, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(alamat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const Divider(height: 20),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 70, height: 70, color: Colors.grey[100],
                  child: foto.isNotEmpty
                    ? Image.network(foto, fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))
                    : const Icon(Icons.image, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              
              // Detail
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['nama'] ?? '-', style: const TextStyle(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(_formatRupiah(harga), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Qty Editor
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _updateQuantity(index, -1),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.remove, size: 14, color: Colors.grey[600]))
                    ),
                    Text("$qty", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _updateQuantity(index, 1),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), child: Icon(Icons.add, size: 14, color: jawaraColor))
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