import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Pastikan import ini ada untuk format uang
import 'package:jawaramobile_1/services/keranjang_service.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;
  
  // Menyimpan ID keranjang yang dipilih
  final Set<int> _selectedItemIds = {};

  // Warna Utama (Jawara Color)
  final Color jawaraColor = const Color(0xFF26547C);

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  // --- LOGIC SECTION ---

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

    // Optimistic Update (Update UI duluan biar cepat)
    setState(() {
      _cartItems[index]['jumlah'] = newQty;
    });

    await KeranjangService().updateQuantity(keranjangId, newQty);
  }

  Future<void> _deleteItem(int index) async {
    // Tampilkan Dialog Konfirmasi Hapus
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Barang?"),
        content: const Text("Apakah Anda yakin ingin menghapus barang ini dari keranjang?"),
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

  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih minimal satu barang untuk checkout")),
      );
      return;
    }

    List<Map<String, dynamic>> selectedItems = [];
    for (var item in _cartItems) {
      int id = int.tryParse(item['keranjang_id'].toString()) ?? 0;
      if (_selectedItemIds.contains(id)) {
        
        String rawFoto = item['barang_foto']?.toString() ?? '';
        String fullFotoUrl = '';
        if (rawFoto.isNotEmpty) {
           if (rawFoto.startsWith('http')) {
             fullFotoUrl = rawFoto;
           } else {
             fullFotoUrl = "${BarangService.baseImageUrl}$rawFoto";
           }
        }

        selectedItems.add({
          'id': item['barang_id'], 
          'nama': item['barang_nama'],
          'harga': item['barang_harga'].toString(),
          'jumlah': item['jumlah'].toString(),
          'foto': fullFotoUrl, 
          'alamat_penjual': item['alamat_penjual'] ?? 'Alamat tidak tersedia', 
        });
      }
    }

    context.push('/checkout-barang', extra: {'items': selectedItems});
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background abu muda agar kartu pop-out
      appBar: AppBar(
        title: const Text("Keranjang Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: jawaraColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: jawaraColor))
          : _cartItems.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    // LIST ITEM
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _cartItems.length,
                        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _buildCartItem(index);
                        },
                      ),
                    ),
                    // BOTTOM BAR (Sticky)
                    _buildBottomCheckoutBar(),
                  ],
                ),
    );
  }

  // Widget Item Keranjang
  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    final int keranjangId = int.tryParse(item['keranjang_id'].toString()) ?? 0;
    
    final String nama = item['barang_nama'] ?? '-';
    final String hargaRaw = item['barang_harga']?.toString() ?? '0';
    final String hargaFmt = _formatRupiah(hargaRaw);
    final int qty = int.tryParse(item['jumlah'].toString()) ?? 1;

    // Foto Logic
    String rawFoto = item['barang_foto']?.toString() ?? '';
    String fotoUrl = '';
    if (rawFoto.isNotEmpty) {
      if (rawFoto.startsWith('http')) {
        fotoUrl = rawFoto;
      } else {
        fotoUrl = "${BarangService.baseImageUrl}$rawFoto";
      }
    }

    bool isSelected = _selectedItemIds.contains(keranjangId);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 1. CHECKBOX
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                activeColor: jawaraColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                value: isSelected,
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
            ),
            
            // 2. FOTO PRODUK
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 75, height: 75,
                color: Colors.grey[200],
                child: fotoUrl.isNotEmpty
                    ? Image.network(
                        fotoUrl, 
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, _) => const Icon(Icons.image_not_supported, color: Colors.grey),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // 3. INFO & ACTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Produk
                  Text(
                    nama, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  
                  // Harga
                  Text(
                    hargaFmt, 
                    style: TextStyle(color: jawaraColor, fontWeight: FontWeight.bold, fontSize: 15)
                  ),
                  const SizedBox(height: 8),

                  // Row: Qty Controller & Delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Qty Controller
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => _updateQty(index, -1),
                              child: Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Icon(Icons.remove, size: 16, color: Colors.grey[600]),
                              ),
                            ),
                            Container(
                              width: 30,
                              decoration: BoxDecoration(
                                border: Border.symmetric(vertical: BorderSide(color: Colors.grey.shade300))
                              ),
                              alignment: Alignment.center,
                              child: Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            InkWell(
                              onTap: () => _updateQty(index, 1),
                              child: Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Icon(Icons.add, size: 16, color: jawaraColor),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete Button
                      InkWell(
                        onTap: () => _deleteItem(index),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.delete_outline, color: Colors.grey, size: 22),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bottom Bar
  Widget _buildBottomCheckoutBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Total Harga", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text(
                  _formatRupiah(_totalSelectedPrice), 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: jawaraColor)
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _checkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: jawaraColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Checkout (${_selectedItemIds.length})",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text("Keranjang Kosong", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text("Yuk, isi keranjangmu dengan barang impian!", style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.go('/daftar-pembelian'), // Sesuaikan route menu utama
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: jawaraColor),
              foregroundColor: jawaraColor,
            ),
            child: const Text("Belanja Sekarang"),
          )
        ],
      ),
    );
  }
}