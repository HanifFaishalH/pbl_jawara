import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class DaftarPembelian extends StatefulWidget {
  const DaftarPembelian({super.key});

  @override
  State<DaftarPembelian> createState() => _DaftarPembelianState();
}

class _DaftarPembelianState extends State<DaftarPembelian> {
  late Future<List<dynamic>> futureBarang;
  String selectedCategory = 'Semua';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Warna Tema
  final Color jawaraColor = const Color(0xFF26547C);

  @override
  void initState() {
    super.initState();
    futureBarang = BarangService().fetchBarang();

    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- HELPER FUNCTIONS ---
  String _safeGet(Map<String, dynamic> item, String key, [String defaultValue = '-']) {
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  List<dynamic> _getFilteredBarangList(List<dynamic> allBarang) {
    return allBarang.where((item) {
      final itemMap = item as Map<String, dynamic>;
      
      bool matchCategory = true;
      if (selectedCategory != 'Semua') {
        String catName = '';
        if (itemMap['kategori'] is Map) {
          catName = itemMap['kategori']['kategori_nama'] ?? '';
        } else {
          catName = itemMap['kategori']?.toString() ?? '';
        }
        matchCategory = catName.toLowerCase().contains(selectedCategory.toLowerCase());
      }

      bool matchSearch = true;
      if (searchQuery.isNotEmpty) {
        String namaBarang = itemMap['barang_nama']?.toString().toLowerCase() ?? '';
        matchSearch = namaBarang.contains(searchQuery.toLowerCase());
      }

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: _buildCustomAppBar(context, colorScheme),
      body: FutureBuilder<List<dynamic>>(
        future: futureBarang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text("Gagal memuat data", style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () => setState(() {
                      futureBarang = BarangService().fetchBarang();
                    }),
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          }

          final allBarangList = snapshot.data ?? [];
          final filteredBarangList = _getFilteredBarangList(allBarangList);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                futureBarang = BarangService().fetchBarang();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPromoBanner(),

                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text("Kategori",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCategoryIcon('Semua', Icons.grid_view_rounded),
                            _buildCategoryIcon('Batik Tulis', Icons.brush_rounded),
                            _buildCategoryIcon('Batik Cap', Icons.print_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8), 

                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filteredBarangList.isEmpty
                            ? _buildEmptyState()
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.62, 
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: filteredBarangList.length,
                                itemBuilder: (context, index) {
                                  return _buildProductCard(filteredBarangList[index], colorScheme);
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: jawaraColor, 
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.go('/menu-marketplace'),
      ),
      title: Container(
        height: 40,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari barang...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            suffixIcon: searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                ) 
              : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
          onPressed: () => context.push('/keranjang'),
        ),
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined, color: Colors.white),
          onPressed: () => context.go('/riwayat-pesanan'),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: jawaraColor, 
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.storefront, size: 130, color: Colors.white.withOpacity(0.1)),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Selamat Datang di", 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)
                ),
                SizedBox(height: 4),
                Text(
                  "Marketplace Jawara", 
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String label, IconData icon) {
    bool isSelected = selectedCategory == label;
    Color activeColor = jawaraColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = label;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey[50],
              border: Border.all(
                color: isSelected ? activeColor : Colors.grey.shade200, 
                width: 1.5
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon, 
              color: isSelected ? activeColor : Colors.grey[600], 
              size: 24
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? activeColor : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, ColorScheme colorScheme) {
    final String nama = _safeGet(item, 'barang_nama');
    final String hargaRaw = _safeGet(item, 'barang_harga', '0');
    final String hargaFormat = _formatRupiah(hargaRaw);
    final String alamat = _safeGet(item, 'alamat_penjual', 'Kota Malang');
    final String stok = _safeGet(item, 'barang_stok', '0');
    final String idBarang = _safeGet(item, 'barang_id');
    
    // --- DATA BARU: NAMA PENJUAL ---
    final String namaPenjual = _safeGet(item, 'nama_penjual', 'Penjual Jawara');

    String rawFoto = item['barang_foto']?.toString() ?? "";
    String finalFotoUrl = "";
    if (rawFoto.isNotEmpty) {
      if (!rawFoto.startsWith('http')) {
        finalFotoUrl = "${BarangService.baseImageUrl}$rawFoto";
      } else {
        finalFotoUrl = rawFoto;
      }
    }

    String kategoriBersih = '-';
    if (item['kategori'] != null) {
      if (item['kategori'] is Map) {
        kategoriBersih = item['kategori']['kategori_nama'] ?? '-';
      } else {
        kategoriBersih = item['kategori'].toString();
      }
    }

    return InkWell(
      onTap: () {
        // KIRIM DATA PENJUAL KE DETAIL
        final Map<String, String> dataDetail = {
          'id': idBarang,
          'nama': nama,
          'kategori': kategoriBersih,
          'harga': hargaRaw,
          'stok': stok,
          'alamat_penjual': alamat,
          'foto': finalFotoUrl,
          'nama_penjual': namaPenjual, // <-- Penting
        };
        context.push('/detail-barang-beli', extra: dataDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: finalFotoUrl.isNotEmpty
                          ? Image.network(
                              finalFotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, _) => Container(
                                color: Colors.grey[100],
                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                            )
                          : Container(color: Colors.grey[200]),
                    ),
                    Positioned(
                      top: 8,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(4)),
                        ),
                        child: const Text("Terlaris", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.2),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hargaFormat,
                          style: TextStyle(
                            color: jawaraColor, 
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                alamat,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star, size: 12, color: Colors.amber[700]),
                            const Text(" 4.8 ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            Container(width: 1, height: 10, color: Colors.grey),
                            const Text(" Terjual 100+", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 10),
            Text("Barang tidak ditemukan", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}