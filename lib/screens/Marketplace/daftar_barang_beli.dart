import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Data dummy untuk daftar batik (TETAP)
final List<Map<String, String>> dummyBatikList = [
  {
    "id": "B001",
    "nama": "Batik Tulis Parang Rusak",
    "harga": "Rp 350.000",
    "stok": "5",
    "kategori": "Batik",
    "alamat": "Kantor RW 05, Blok A, Malang",
    "imageUrl": "placeholder_batik_1",
  },
  {
    "id": "B002",
    "nama": "Batik Cap Kawung",
    "harga": "Rp 150.000",
    "stok": "12",
    "kategori": "Batik",
    "alamat": "Kantor RW 05, Blok A, Malang",
    "imageUrl": "placeholder_batik_2",
  },
  {
    "id": "B003",
    "nama": "Kemeja Batik Modern",
    "harga": "Rp 250.000",
    "stok": "8",
    "kategori": "Batik",
    "alamat": "Kantor RW 05, Blok A, Malang",
    "imageUrl": "placeholder_batik_3",
  },
];

class DaftarPembelian extends StatelessWidget {
  const DaftarPembelian({super.key});

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
        // MODIFIKASI: Tambahkan actions untuk tombol 'Pesanan Saya'
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: 'Pesanan Saya',
            onPressed: () {
              // Navigasi ke halaman riwayat pesanan
              context.go('/riwayat-pesanan'); 
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kategori Populer",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Button Kategori (Contoh: Batik)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.brush),
                    label: const Text("Batik"),
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    onPressed: () {
                      // Di sini kita langsung menampilkan daftar batik
                    },
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.chair),
                    label: const Text("Perabotan"),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.laptop),
                    label: const Text("Elektronik"),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Daftar Barang: Batik",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Daftar Barang (Batik)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dummyBatikList.length,
              itemBuilder: (context, index) {
                final item = dummyBatikList[index];
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.pink.shade50,
                      ),
                      child: const Icon(Icons.palette, color: Colors.pink),
                    ),
                    title: Text(item['nama']!, style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      "${item['harga']} | Stok: ${item['stok']}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigasi ke DetailBarangBeli
                      context.push('/detail-barang-beli', extra: item);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}