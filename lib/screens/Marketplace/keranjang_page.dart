import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/keranjang_service.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  
  // Menyimpan ID keranjang yang dipilih (Checkbox)
  final Set<int> _selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    final items = await KeranjangService().getKeranjang();
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  // Logic Update Jumlah (+ / -)
  Future<void> _updateQty(int index, int delta) async {
    final item = _cartItems[index];
    int currentQty = int.parse(item['jumlah'].toString());
    int newQty = currentQty + delta;
    int keranjangId = int.parse(item['keranjang_id'].toString());

    if (newQty < 1) return; // Minimal 1

    // Update UI langsung biar cepat (Optimistic)
    setState(() {
      _cartItems[index]['jumlah'] = newQty;
    });

    // Panggil API di background
    await KeranjangService().updateQuantity(keranjangId, newQty);
  }

  // Logic Hapus Item
  Future<void> _deleteItem(int index) async {
    int keranjangId = int.parse(_cartItems[index]['keranjang_id'].toString());
    
    setState(() {
      _selectedItemIds.remove(keranjangId);
      _cartItems.removeAt(index);
    });

    await KeranjangService().deleteItem(keranjangId);
  }

  // Hitung Total Harga (Hanya yang dicentang)
  int get _totalSelectedPrice {
    int total = 0;
    for (var item in _cartItems) {
      int id = int.parse(item['keranjang_id'].toString());
      if (_selectedItemIds.contains(id)) {
        int harga = int.tryParse(item['barang']['barang_harga'].toString()) ?? 0;
        int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
        total += (harga * qty);
      }
    }
    return total;
  }

  void _checkout() {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal satu barang untuk checkout")),
      );
      return;
    }

    // Filter barang yang dipilih & Format data
    List<Map<String, dynamic>> selectedItems = [];
    for (var item in _cartItems) {
      int id = int.parse(item['keranjang_id'].toString());
      if (_selectedItemIds.contains(id)) {
        selectedItems.add({
          'nama': item['barang']['barang_nama'],
          'harga': item['barang']['barang_harga'].toString(),
          'jumlah': item['jumlah'].toString(),
          'foto': item['barang']['image'] ?? '',
          'alamat': item['barang']['alamat'] ?? 'Toko Warga', 
        });
      }
    }

    // Kirim Data ke Halaman Checkout
    context.push('/checkout-barang', extra: {'items': selectedItems});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
              ? const Center(child: Text("Keranjang Kosong"))
              : Column(
                  children: [
                    // LIST BARANG
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: _cartItems.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final barang = item['barang'] ?? {};
                          final int keranjangId = int.parse(item['keranjang_id'].toString());
                          final int harga = int.tryParse(barang['barang_harga'].toString()) ?? 0;
                          final int qty = int.tryParse(item['jumlah'].toString()) ?? 1;

                          return Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  // CHECKBOX
                                  Checkbox(
                                    value: _selectedItemIds.contains(keranjangId),
                                    onChanged: (bool? val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedItemIds.add(keranjangId);
                                        } else {
                                          _selectedItemIds.remove(keranjangId);
                                        }
                                      });
                                    },
                                  ),
                                  // GAMBAR
                                  Container(
                                    width: 60, height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: barang['image'] != null
                                        ? Image.network(barang['image'], fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Icon(Icons.image))
                                        : const Icon(Icons.image),
                                  ),
                                  const SizedBox(width: 12),
                                  // INFO & TOMBOL JUMLAH
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(barang['barang_nama'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text("Rp $harga", style: TextStyle(color: Colors.grey[600])),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            // Minus
                                            InkWell(
                                              onTap: () => _updateQty(index, -1),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                                                child: const Icon(Icons.remove, size: 16),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 12),
                                              child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            // Plus
                                            InkWell(
                                              onTap: () => _updateQty(index, 1),
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                                                child: const Icon(Icons.add, size: 16),
                                              ),
                                            ),
                                            const Spacer(),
                                            // Hapus
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                              onPressed: () => _deleteItem(index),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // BOTTOM BAR CHECKOUT
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Total:", style: TextStyle(color: Colors.grey)),
                              Text("Rp $_totalSelectedPrice", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _checkout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Checkout (${_selectedItemIds.length})"),
                          )
                        ],
                      ),
                    )
                  ],
                ),
    );
  }
}