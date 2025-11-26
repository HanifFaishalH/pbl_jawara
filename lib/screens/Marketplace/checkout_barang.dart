import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:jawaramobile_1/services/transaksi_service.dart';

// Import Widgets Modular
import '../../widgets/marketplace/co_item_card.dart';
import '../../widgets/marketplace/co_bottom_bar.dart';
import '../../widgets/marketplace/co_helpers.dart';

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
      if (newQty > 0) _itemsToBuy[index]['jumlah'] = newQty;
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
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: jawaraColor)),
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
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: jawaraColor)),
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
              const Text("Silakan ambil barang sesuai jadwal.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: jawaraColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
        elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_uniqueAddresses.length > 1) 
                    Container(
                      color: Colors.orange.shade50,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                          const SizedBox(width: 10),
                          Expanded(child: Text("Barang berasal dari ${_uniqueAddresses.length} lokasi berbeda.", style: TextStyle(color: Colors.orange.shade900, fontSize: 13))),
                        ],
                      ),
                    ),

                  ..._itemsToBuy.asMap().entries.map((entry) {
                    return CheckoutItemCard(
                      item: entry.value,
                      onUpdateQty: (delta) => _updateQuantity(entry.key, delta),
                      primaryColor: jawaraColor,
                    );
                  }),

                  const CheckoutDivider(),

                  CheckoutSectionHeader(title: "Jadwal Pengambilan", icon: Icons.calendar_month_outlined, iconColor: jawaraColor),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        CheckoutClickableRow(
                          label: "Tanggal", 
                          value: DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_tanggalPengambilan),
                          onTap: () => _selectDate(context)
                        ),
                        const Divider(height: 1, indent: 16),
                        CheckoutClickableRow(
                          label: "Waktu", 
                          value: _jamPengambilan.format(context),
                          onTap: () => _selectTime(context)
                        ),
                      ],
                    ),
                  ),

                  const CheckoutDivider(),

                  CheckoutSectionHeader(title: "Rincian Lainnya", icon: Icons.receipt_long_outlined, iconColor: jawaraColor),
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
                            filled: true, fillColor: Colors.grey[100],
                            hintText: "Tulis pesan untuk penjual...",
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.edit_note, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const CheckoutDivider(),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rincian Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Subtotal Produk", style: TextStyle(color: Colors.grey[600])), Text(_formatRupiah(_grandTotal), style: const TextStyle(fontWeight: FontWeight.w500))]),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Biaya Layanan", style: TextStyle(color: Colors.grey[600])), const Text("Rp 0", style: TextStyle(fontWeight: FontWeight.w500))]),
                        const SizedBox(height: 12),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total Pembayaran", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(_formatRupiah(_grandTotal), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: jawaraColor))]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          CheckoutBottomBar(
            grandTotal: _grandTotal, 
            isProcessing: _isProcessing, 
            onCheckout: _processOrder,
            primaryColor: jawaraColor
          ),
        ],
      ),
    );
  }
}