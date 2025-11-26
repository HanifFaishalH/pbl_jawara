import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/keranjang_service.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

// Import Widget Modular
import '../../widgets/marketplace/cart_item.dart';
import '../../widgets/marketplace/cart_bottom.dart';
import '../../widgets/marketplace/cart_empty_state.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  final Set<int> _selectedItemIds = {};
  final Color jawaraColor = const Color(0xFF26547C);

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() => _isLoading = true);
    try {
      final items = await KeranjangService().getKeranjang();
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQty(int index, int delta) async {
    final item = _cartItems[index];
    int currentQty = int.tryParse(item['jumlah'].toString()) ?? 1;
    int newQty = currentQty + delta;
    int keranjangId = int.tryParse(item['keranjang_id'].toString()) ?? 0;

    if (newQty < 1) return;
    setState(() { _cartItems[index]['jumlah'] = newQty; });
    await KeranjangService().updateQuantity(keranjangId, newQty);
  }

  Future<void> _deleteItem(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: const Text("Hapus barang ini dari keranjang?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;
    int keranjangId = int.tryParse(_cartItems[index]['keranjang_id'].toString()) ?? 0;
    setState(() {
      _selectedItemIds.remove(keranjangId);
      _cartItems.removeAt(index);
    });
    await KeranjangService().deleteItem(keranjangId);
  }

  int get _totalSelectedPrice {
    int total = 0;
    for (var item in _cartItems) {
      int id = int.tryParse(item['keranjang_id'].toString()) ?? 0;
      if (_selectedItemIds.contains(id)) {
        int harga = int.tryParse(item['barang_harga'].toString()) ?? 0;
        int qty = int.tryParse(item['jumlah'].toString()) ?? 0;
        total += (harga * qty);
      }
    }
    return total;
  }

  void _checkout() {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih minimal satu barang")));
      return;
    }

    List<Map<String, dynamic>> selectedItems = [];
    for (var item in _cartItems) {
      int id = int.tryParse(item['keranjang_id'].toString()) ?? 0;
      if (_selectedItemIds.contains(id)) {
        String rawFoto = item['barang_foto']?.toString() ?? '';
        String fullFotoUrl = rawFoto.isNotEmpty 
            ? (rawFoto.startsWith('http') ? rawFoto : "${BarangService.baseImageUrl}$rawFoto") 
            : '';

        selectedItems.add({
          'id': item['barang_id'], 'nama': item['barang_nama'],
          'harga': item['barang_harga'].toString(), 'jumlah': item['jumlah'].toString(),
          'foto': fullFotoUrl, 'alamat_penjual': item['alamat_penjual'] ?? 'Alamat tidak tersedia',
        });
      }
    }
    context.push('/checkout-barang', extra: {'items': selectedItems});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: jawaraColor, elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: jawaraColor))
          : _cartItems.isEmpty
              ? CartEmptyState(primaryColor: jawaraColor)
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _cartItems[index];
                          final int kId = int.tryParse(item['keranjang_id'].toString()) ?? 0;
                          return CartItemCard(
                            item: item,
                            isSelected: _selectedItemIds.contains(kId),
                            primaryColor: jawaraColor,
                            onSelect: (val) {
                              setState(() {
                                val == true ? _selectedItemIds.add(kId) : _selectedItemIds.remove(kId);
                              });
                            },
                            onUpdateQty: (delta) => _updateQty(index, delta),
                            onDelete: () => _deleteItem(index),
                          );
                        },
                      ),
                    ),
                    CartBottomBar(
                      totalSelectedPrice: _totalSelectedPrice,
                      selectedCount: _selectedItemIds.length,
                      onCheckout: _checkout,
                      primaryColor: jawaraColor,
                    ),
                  ],
                ),
    );
  }
}