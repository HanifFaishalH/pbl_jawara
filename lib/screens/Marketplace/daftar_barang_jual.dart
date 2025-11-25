import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/barang_service.dart';

class DaftarBarang extends StatefulWidget {
  const DaftarBarang({super.key});

  @override
  State<DaftarBarang> createState() => _DaftarBarangState();
}

class _DaftarBarangState extends State<DaftarBarang> {
  late Future<List<dynamic>> futureBarang;

  @override
  void initState() {
    super.initState();
    // PERUBAHAN DISINI: Panggil fetchUserBarang (bukan fetchBarang biasa)
    futureBarang = BarangService().fetchUserBarang();
  }

  Future<void> _refreshData() async {
    setState(() {
      // PERUBAHAN DISINI JUGA
      futureBarang = BarangService().fetchUserBarang();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/menu-marketplace'),
        ),
        title: Text(
          "Dagangan Saya", 
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            onPressed: () {
              context.push('/pesanan-masuk');
            },
            tooltip: 'Pesanan Masuk',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/add-barang');
          _refreshData();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Tambah Barang",
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
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

          final List<dynamic> barangList = snapshot.data ?? [];

          if (barangList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    "Anda belum mengunggah barang.",
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tekan tombol Tambah Barang untuk mulai berjualan.",
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: GridView.builder(
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
              ),
              itemCount: barangList.length,
              itemBuilder: (context, index) {
                final item = barangList[index];
                
                final String nama = item['barang_nama'] ?? 'Tanpa Nama';
                final String harga = item['barang_harga']?.toString() ?? '0';
                final String stok = item['barang_stok']?.toString() ?? '0';
                final String fotoUrl = item['barang_foto']?.toString() ?? '';

                return Card(
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: colorScheme.surfaceVariant,
                          child: fotoUrl.isNotEmpty
                              ? Image.network(
                                  fotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                )
                              : const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
                        ),
                      ),
                      
                      // Info Text
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rp $harga",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Stok Indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: int.parse(stok) > 0 ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: int.parse(stok) > 0 ? Colors.green : Colors.red, 
                                  width: 0.5
                                )
                              ),
                              child: Text(
                                "Stok: $stok",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: int.parse(stok) > 0 ? Colors.green[700] : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}