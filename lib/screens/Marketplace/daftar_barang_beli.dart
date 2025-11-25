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

  @override
  void initState() {
    super.initState();
    futureBarang = BarangService().fetchBarang();
  }

  // Helper: Ambil data map dengan aman
  String _safeGet(Map<String, dynamic> item, String key, [String defaultValue = '-']) {
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Helper: Format Rupiah
  String _formatRupiah(dynamic harga) {
    int price = int.tryParse(harga.toString()) ?? 0;
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  // Logic: Filter Kategori
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
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => context.push('/keranjang'),
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
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Gagal memuat data:\n${snapshot.error}", textAlign: TextAlign.center),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureBarang = BarangService().fetchBarang();
                      });
                    },
                    child: const Text("Coba Lagi"),
                  )
                ],
              ),
            );
          }

          // 3. Data Ready
          final allBarangList = snapshot.data ?? [];
          final filteredBarangList = _getFilteredBarangList(allBarangList);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- SECTION KATEGORI ---
                Text("Kategori", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
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
                
                const SizedBox(height: 20),

                // --- SECTION LIST BARANG ---
                Text("Rekomendasi Barang", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                filteredBarangList.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text("Barang tidak ditemukan untuk kategori ini."),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, 
                          childAspectRatio: 0.65, 
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredBarangList.length,
                        itemBuilder: (context, index) {
                          final item = filteredBarangList[index] as Map<String, dynamic>;

                          // --- PREPARE DATA ---
                          final String nama = _safeGet(item, 'barang_nama');
                          final String hargaRaw = _safeGet(item, 'barang_harga', '0');
                          final String hargaFormat = _formatRupiah(hargaRaw);
                          final String alamat = _safeGet(item, 'alamat_penjual', 'Dikirim dari Gudang');
                          final String stok = _safeGet(item, 'barang_stok', '0');
                          final String idBarang = _safeGet(item, 'barang_id');

                          // --- PREPARE IMAGE URL ---
                          String rawFoto = item['barang_foto']?.toString() ?? "";
                          String finalFotoUrl = "";
                          if (rawFoto.isNotEmpty) {
                            if (!rawFoto.startsWith('http')) {
                              finalFotoUrl = "${BarangService.baseImageUrl}$rawFoto";
                            } else {
                              finalFotoUrl = rawFoto;
                            }
                          }

                          return InkWell(
                            onTap: () {
                              // --- PERBAIKAN LOGIKA KATEGORI ---
                              String kategoriBersih = '-';
                              if (item['kategori'] != null) {
                                // Jika formatnya Map (objek), ambil kuncinya
                                if (item['kategori'] is Map) {
                                  kategoriBersih = item['kategori']['kategori_nama'] ?? '-';
                                } 
                                // Jika formatnya String (seperti dari Controller Anda), ambil langsung
                                else {
                                  kategoriBersih = item['kategori'].toString();
                                }
                              }

                              final Map<String, String> dataDetail = {
                                'id': idBarang,
                                'nama': nama,
                                'kategori': kategoriBersih, // Sekarang nilai ini pasti benar
                                'harga': hargaRaw,
                                'stok': stok,
                                'alamat_penjual': alamat,
                                'foto': finalFotoUrl, 
                              };

                              context.push('/detail-barang-beli', extra: dataDetail);
                            },
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: finalFotoUrl.isNotEmpty
                                          ? Image.network(
                                              finalFotoUrl,
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
                                  ),
                                  
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0), 
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
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, size: 10, color: Colors.grey),
                                                  const SizedBox(width: 2),
                                                  Expanded(
                                                    child: Text(
                                                      alamat,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Text(
                                            hargaFormat,
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
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

  // Widget Chip Kategori
  Widget _buildCategoryChip(BuildContext context, String label, IconData icon, ColorScheme colorScheme) {
    final bool isSelected = selectedCategory == label;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : colorScheme.primary),
      label: Text(label),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      backgroundColor: isSelected ? colorScheme.primary : Colors.white,
      side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        setState(() {
          selectedCategory = label;
        });
      },
    );
  }
}