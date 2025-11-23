import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart'; // Sesuaikan import ini

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

  // Helper untuk mengambil string aman dari Map
  String _safeGet(Map<String, dynamic> item, String key, [String defaultValue = '-']) {
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Filter List berdasarkan kategori
  List<dynamic> _getFilteredBarangList(List<dynamic> allBarang) {
    if (selectedCategory == 'Semua') return allBarang;

    return allBarang.where((item) {
      final itemMap = item as Map<String, dynamic>;
      
      // Mengambil nama kategori jika bentuknya object/nested dari Laravel
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
                // --- CHIP KATEGORI ---
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

                // --- JUDUL DAFTAR ---
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Daftar Barang", style: theme.textTheme.titleLarge),
                ),

                // --- GRID BARANG ---
                filteredBarangList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text("Tidak ada barang ditemukan."),
                        ),
                      )
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

                          // 1. Ekstraksi Data untuk Tampilan Grid
                          final String nama = _safeGet(item, 'barang_nama');
                          final String harga = _safeGet(item, 'barang_harga', '0');
                          final String alamat = _safeGet(item, 'alamat', 'Malang'); // Default jika null
                          // Sesuaikan key 'image' ini dengan response API Laravel Anda
                          final String fotoUrl = item['image']?.toString() ?? ""; 

                          return InkWell(
                            onTap: () {
                              // 2. LOGIKA UTAMA: Siapkan data bersih untuk halaman Detail
                              
                              // Ambil nama kategori dari object nested
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
                                'stok': _safeGet(item, 'barang_stok', '0'), // Pastikan key 'barang_stok' benar
                                'alamat': alamat,
                                'foto': fotoUrl, // URL Foto dikirim
                                'id': _safeGet(item, 'barang_id'),
                              };

                              // Pindah ke halaman detail dengan membawa data extra
                              context.push(
                                '/detail-barang-beli',
                                extra: dataUntukDetail,
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              clipBehavior: Clip.antiAlias,
                              elevation: 2,
                              child: Column(
                                children: [
                                  // Gambar di Grid
                                  Expanded(
                                    child: fotoUrl.isNotEmpty
                                        ? Image.network(
                                            fotoUrl,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (ctx, err, _) => Container(
                                              color: Colors.grey.shade200,
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                          ),
                                  ),
                                  // Teks di Grid
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Rp $harga",
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
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