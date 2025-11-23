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

  String _safeGet(Map<String, dynamic> item, String key, [String defaultValue = '-']) {
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  List<dynamic> _getFilteredBarangList(List<dynamic> allBarang) {
    if (selectedCategory == 'Semua') return allBarang;

    return allBarang.where((item) {
      final itemMap = item as Map<String, dynamic>;
      return _safeGet(itemMap, 'barang_kategori', '').toLowerCase() ==
          selectedCategory.toLowerCase();
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
            tooltip: "Pesanan Saya",
            onPressed: () => context.go('/riwayat-pesanan'),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: futureBarang,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final allBarangList = snapshot.data ?? [];
          final filteredBarangList = _getFilteredBarangList(allBarangList);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KATEGORI
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

                // TITLE
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Daftar Barang", style: theme.textTheme.titleLarge),
                ),

                // GRID BARANG
                filteredBarangList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Text(
                            "Tidak ada barang untuk kategori '$selectedCategory'",
                            style: theme.textTheme.titleMedium,
                          ),
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

                          final String nama = _safeGet(item, 'barang_nama');
                          final String harga = _safeGet(item, 'barang_harga');
                          final String alamat = _safeGet(item, 'alamat', 'Lokasi Tidak Diketahui');

                          // FOTO URL LANGSUNG DARI API
                          final String fotoUrl = item['foto_url']?.toString() ?? "";

                          return InkWell(
                            onTap: () {
                              context.push(
                                '/detail-barang-beli',
                                extra: item.map((key, value) => MapEntry(key, value.toString())),
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
                                  // FOTO BARANG
                                  fotoUrl.isNotEmpty
                                      ? Image.network(
                                          fotoUrl,
                                          height: 130,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, _) => const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        )
                                      : Container(
                                          height: 130,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.image_not_supported, size: 40),
                                        ),

                                  // NAMA + HARGA + ALAMAT
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
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                alamat,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
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

  Widget _buildCategoryChip(
      BuildContext context, String label, IconData icon, ColorScheme colorScheme) {
    final bool isSelected = selectedCategory == label;

    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : colorScheme.primary,
      ),
      label: Text(label),
      backgroundColor: isSelected
          ? colorScheme.primary
          : colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : colorScheme.onSurface,
      ),
      onPressed: () {
        setState(() {
          selectedCategory = label;
        });
      },
    );
  }
}
