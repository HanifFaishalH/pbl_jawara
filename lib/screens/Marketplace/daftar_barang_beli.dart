import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart';
import '../../widgets/marketplace/promo_banner_beli.dart';
import '../../widgets/marketplace/product_card_beli.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: _buildCustomAppBar(context),
      body: FutureBuilder<List<dynamic>>(
        future: futureBarang,
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
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

          // 3. Data Ready
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
                  // WIDGET BANNER
                  PromoBanner(color: jawaraColor),

                  // WIDGET KATEGORI
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

                  // WIDGET GRID PRODUK
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filteredBarangList.isEmpty
                            ? const EmptyProductState() // Widget Kosong
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
                                  // Widget Kartu Produk
                                  return ProductCard(
                                    item: filteredBarangList[index], 
                                    primaryColor: jawaraColor
                                  );
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

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
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
}