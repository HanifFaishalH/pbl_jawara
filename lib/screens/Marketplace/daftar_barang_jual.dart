import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DaftarBarang extends StatefulWidget {
  const DaftarBarang({super.key});

  @override
  State<DaftarBarang> createState() => _DaftarBarangState();
}

class _DaftarBarangState extends State<DaftarBarang> {
  // Data dummy daftar barang
  final List<Map<String, String>> _daftarBarang = [
    {
      "id": "1",
      "nama": "Meja Kayu Jati",
      "harga": "Rp 500.000",
      "stok": "10",
      "kategori": "Perabotan",
      "alamat": "Jl. Mawar No. 5, Jakarta",
      "imageUrl": "placeholder_meja",
    },
    {
      "id": "2",
      "nama": "Kaos Cotton Combed",
      "harga": "Rp 75.000",
      "stok": "50",
      "kategori": "Pakaian",
      "alamat": "Jl. Mawar No. 5, Jakarta",
      "imageUrl": "placeholder_kaos",
    },
    {
      "id": "3",
      "nama": "Smartphone Android",
      "harga": "Rp 3.000.000",
      "stok": "5",
      "kategori": "Elektronik",
      "alamat": "Jl. Mawar No. 5, Jakarta",
      "imageUrl": "placeholder_hp",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        // Diarahkan ke rute /menu-marketplace
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/menu-marketplace'),
        ),
        title: Text(
          "Daftar Barang",
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        // Penambahan Icon Pesanan Masuk
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            onPressed: () {
              context.push('/pesanan-masuk'); // Navigasi ke Pesanan Masuk
            },
            tooltip: 'Pesanan Masuk',
          ),
        ],
      ),
      body: _daftarBarang.isEmpty
          ? Center(
              child: Text(
                "Belum ada barang yang diunggah.",
                style: theme.textTheme.titleMedium,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _daftarBarang.length,
              itemBuilder: (context, index) {
                final item = _daftarBarang[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: colorScheme.secondary.withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                      ),
                    ),
                    title: Text(
                      item['nama']!,
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Harga: ${item['harga']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text("Stok: ${item['stok']}"),
                        Text("Kategori: ${item['kategori']}"),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigasi ke DetailBarang
                      context.push('/detail-barang-jual', extra: item);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke halaman Tambah Barang
          context.push('/add-barang');
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Tambah Barang",
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
    );
  }
}