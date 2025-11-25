import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class DaftarPembelian extends StatefulWidget {
  const DaftarPembelian({super.key});

  @override
  State<DaftarPembelian> createState() => _DaftarPembelianState();
}

class _DaftarPembelianState extends State<DaftarPembelian> {
  late Future<List<dynamic>> futureBarang;
  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    futureBarang = BarangService().fetchBarang();
  }

  // Helper untuk mengambil data dengan aman (mencegah null)
  String _safeGet(Map<String, dynamic> item, String key, [String defaultValue = '-']) {
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  List<dynamic> _getFilteredBarangList(List<dynamic> allBarang) {
    if (selectedCategory == 'Semua') return allBarang;

    return allBarang.where((item) {
      final itemMap = item as Map<String, dynamic>;
      String catName = '';
      if (itemMap['kategori'] is Map) {
        catName = itemMap['kategori']['kategori_nama'] ?? '';
      } else {
        catName = itemMap['kategori']?.toString() ?? '';
      }
      return catName.toLowerCase().contains(selectedCategory.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          "Marketplace RW",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/menu-marketplace'),
        ),
        actions: [
          // --- IKON KERANJANG ---
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              context.push('/keranjang'); 
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            onPressed: () => context.go('/riwayat-pesanan'),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: futureBarang,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final allBarangList = snapshot.data ?? [];
          final filteredBarangList = _getFilteredBarangList(allBarangList);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Kategori Populer", style: theme.textTheme.titleMedium),
                ),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategoryChip(context, 'Semua', Icons.grid_view, colorScheme),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'Batik Tulis', Icons.palette, colorScheme),
                      const SizedBox(width: 8),
                      _buildCategoryChip(context, 'Batik Cap', Icons.brush, colorScheme),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Daftar Barang", style: theme.textTheme.titleLarge),
                ),
                filteredBarangList.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(30.0), child: Text("Tidak ada barang ditemukan.")))
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: filteredBarangList.length,
                        itemBuilder: (context, index) {
                          final item = filteredBarangList[index] as Map<String, dynamic>;
                          
                          // --- PENGAMBILAN DATA ---
                          final String nama = _safeGet(item, 'barang_nama');
                          final String harga = _safeGet(item, 'barang_harga', '0');
                          
                          // PERBAIKAN 1: Mengambil 'alamat_penjual' sesuai JSON Laravel
                          final String alamat = _safeGet(item, 'alamat_penjual', 'Alamat tidak tersedia');
                          
                          // PERBAIKAN 2: Mengambil 'barang_foto' sesuai JSON Laravel (sebelumnya 'image')
                          final String fotoUrl = item['barang_foto']?.toString() ?? ""; 

                          return InkWell(
                            onTap: () {
                              String kategoriBersih = '-';
                              if (item['kategori'] != null) {
                                if (item['kategori'] is Map) {
                                  kategoriBersih = item['kategori']['kategori_nama']?.toString() ?? '-';
                                } else {
                                  kategoriBersih = item['kategori'].toString();
                                }
                              }

                              final Map<String, String> dataUntukDetail = {
                                'nama': nama,
                                'kategori': kategoriBersih,
                                'harga': harga,
                                'stok': _safeGet(item, 'barang_stok', '0'),
                                
                                // PERBAIKAN 3: Mengirim key 'alamat_penjual' agar konsisten
                                'alamat_penjual': alamat, 
                                
                                'foto': fotoUrl,
                                'id': _safeGet(item, 'barang_id'),
                              };

                              context.push('/detail-barang-beli', extra: dataUntukDetail);
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              clipBehavior: Clip.antiAlias,
                              elevation: 2,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: fotoUrl.isNotEmpty
                                        ? Image.network(fotoUrl, width: double.infinity, fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, _) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)))
                                        : Container(color: Colors.grey.shade200, child: const Icon(Icons.image, size: 40)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(nama, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        // Opsional: Menampilkan alamat penjual di Card
                                        Text(alamat, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                                        const SizedBox(height: 4),
                                        Text("Rp $harga", style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, ColorScheme colorScheme) {
    final bool isSelected = selectedCategory == label;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: isSelected ? Colors.white : colorScheme.primary),
      label: Text(label),
      backgroundColor: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: isSelected ? Colors.white : colorScheme.onSurface),
      onPressed: () {
        setState(() {
          selectedCategory = label;
        });
      },
    );
  }
}