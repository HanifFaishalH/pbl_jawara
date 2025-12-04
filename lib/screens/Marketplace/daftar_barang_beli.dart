import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

// Import Widget ProductCard yang baru diperbaiki
import '../../widgets/marketplace/product_card_beli.dart'; 
import '../../widgets/marketplace/promo_banner_beli.dart';

class DaftarPembelian extends StatefulWidget {
  const DaftarPembelian({super.key});

  @override
  State<DaftarPembelian> createState() => _DaftarPembelianState();
}

class _DaftarPembelianState extends State<DaftarPembelian> {
  // Variable Data
  late Future<List<dynamic>> futureBarang;
  
  // State Filter
  String selectedCategory = 'Semua';
  String searchQuery = '';
  
  final TextEditingController _searchController = TextEditingController();
  final Color jawaraColor = const Color(0xFF26547C);

  // --- IMPLEMENTASI STREAM & DEBOUNCE (Syarat PBL) ---
  final StreamController<String> _searchStreamController = StreamController<String>();
  StreamSubscription<String>? _searchSubscription;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    futureBarang = BarangService().fetchBarang();

    _searchController.addListener(() {
      _searchStreamController.add(_searchController.text);
    });

    _searchSubscription = _searchStreamController.stream.listen((query) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();

      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            searchQuery = query;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _searchStreamController.close();
    _searchSubscription?.cancel();
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Logika Filter List (SUDAH DIPERBAIKI UNTUK NESTED JSON)
  List<dynamic> _getFilteredBarangList(List<dynamic> allBarang) {
    return allBarang.where((item) {
      // Pastikan item adalah Map, cast jika perlu
      if (item is! Map<String, dynamic>) {
          // Jika dynamic, coba cast manual
          try {
             item = item as Map<String, dynamic>;
          } catch (e) {
             return false; 
          }
      }
      
      final itemMap = item as Map<String, dynamic>;
      
      // 1. Filter Kategori
      bool matchCategory = true;
      if (selectedCategory != 'Semua') {
        String catName = '';
        // Cek nested object kategori
        if (itemMap['kategori'] != null && itemMap['kategori'] is Map) {
          catName = itemMap['kategori']['kategori_nama'] ?? '';
        } else if (itemMap['kategori'] is String) {
          catName = itemMap['kategori'];
        }
        matchCategory = catName.toLowerCase().contains(selectedCategory.toLowerCase());
      }

      // 2. Filter Pencarian
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
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: _buildCustomAppBar(context),
      body: FutureBuilder<List<dynamic>>(
        future: futureBarang,
        builder: (context, snapshot) {
          // STATE 1: LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // STATE 2: ERROR
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

          // STATE 3: DATA READY
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
                  // Banner
                  PromoBanner(color: jawaraColor),
                  
                  // Kategori Selector
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

                  // Grid Barang
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        filteredBarangList.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 50.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off, size: 50, color: Colors.grey[300]),
                                      const SizedBox(height: 10),
                                      const Text("Barang tidak ditemukan"),
                                    ],
                                  ),
                                ),
                              )
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
                                  // Cast item ke Map<String, dynamic> agar aman
                                  final item = filteredBarangList[index] as Map<String, dynamic>;
                                  return ProductCard(
                                    item: item, 
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
          textAlignVertical: TextAlignVertical.center, 
          decoration: InputDecoration(
            hintText: "Cari barang...",
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            isDense: true, 
            contentPadding: EdgeInsets.zero, 
            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
            suffixIcon: searchQuery.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    _searchStreamController.add(""); 
                    FocusScope.of(context).unfocus();
                  },
                ) 
              : null,
            border: InputBorder.none,
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