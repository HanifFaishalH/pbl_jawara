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
      "nama": "Meja Kayu Jati Minimalis Modern Tahan Air",
      "harga": "Rp 500.000",
      "stok": "10",
      "kategori": "Perabotan",
      "alamat": "Jl. Mawar No. 5, Jakarta",
      "imageUrl": "placeholder_meja",
    },
    {
      "id": "2",
      "nama": "Kaos Cotton Combed 30s Motif Garis-garis",
      "harga": "Rp 75.000",
      "stok": "50",
      "kategori": "Pakaian",
      "alamat": "Jl. Kamboja No. 10, Bandung",
      "imageUrl": "placeholder_kaos",
    },
    {
      "id": "3",
      "nama": "Smartphone Android Terbaru 64MP Kamera Ultra Wide",
      "harga": "Rp 3.000.000",
      "stok": "5",
      "kategori": "Elektronik",
      "alamat": "Jl. Anggrek Raya, Surabaya",
      "imageUrl": "placeholder_hp",
    },
    {
      "id": "4",
      "nama": "Paket Bibit Tanaman Hias Aglonema Super",
      "harga": "Rp 25.000",
      "stok": "150",
      "kategori": "Hobi",
      "alamat": "Jl. Melati Putih, Medan",
      "imageUrl": "placeholder_bibit",
    },
    {
      "id": "5",
      "nama": "Headset Gaming AULA S603 RGB Sound",
      "harga": "Rp 100.000",
      "stok": "30",
      "kategori": "Elektronik",
      "alamat": "Jakarta Selatan",
      "imageUrl": "placeholder_headset",
    },
    {
      "id": "6",
      "nama": "Lampu Meja Belajar LED Minimalis",
      "harga": "Rp 85.000",
      "stok": "25",
      "kategori": "Perabotan",
      "alamat": "Jakarta Barat",
      "imageUrl": "placeholder_lampu",
    },
    {
      "id": "7",
      "nama": "Botol Minum Sporty 1 Liter BPA Free",
      "harga": "Rp 40.000",
      "stok": "100",
      "kategori": "Perlengkapan Olahraga",
      "alamat": "Depok",
      "imageUrl": "placeholder_botol",
    },
    {
      "id": "8",
      "nama": "Kopi Arabika Gayo Blend Premium",
      "harga": "Rp 65.000",
      "stok": "70",
      "kategori": "Makanan & Minuman",
      "alamat": "Bogor",
      "imageUrl": "placeholder_kopi",
    },
  ];

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
          "Daftar Barang",
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
      body: _daftarBarang.isEmpty
          ? Center(
              child: Text(
                "Belum ada barang yang diunggah.",
                style: theme.textTheme.titleMedium,
              ),
            )
          : GridView.builder( // Menggunakan GridView.builder
              padding: const EdgeInsets.all(8.0), // Padding lebih kecil agar card lebih rapat
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 kolom
                childAspectRatio: 0.7, // Rasio lebar/tinggi untuk setiap item
                crossAxisSpacing: 8.0, // Jarak antar kolom
                mainAxisSpacing: 8.0, // Jarak antar baris
              ),
              itemCount: _daftarBarang.length,
              itemBuilder: (context, index) {
                final item = _daftarBarang[index];
                
                return InkWell(
                  onTap: () {
                    context.push('/detail-barang-jual', extra: item);
                  },
                  child: Card(
                    elevation: 2, // Bayangan standar
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // Radius sudut lebih kecil
                    ),
                    clipBehavior: Clip.antiAlias, // Memastikan gambar juga terpangkas radius
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Produk (di bagian atas Card)
                        Container(
                          height: 120, // Tinggi gambar fixed
                          width: double.infinity, // Lebar penuh Card
                          color: colorScheme.secondary.withOpacity(0.1),
                          child: const Icon(
                            Icons.image_outlined, // Placeholder image
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.all(8.0), // Padding untuk teks di dalam Card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama Barang
                              Text(
                                item['nama']!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Harga
                              Text(
                                item['harga']!,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.error, // Warna harga (misal: merah)
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Lokasi (Opsional: rating bintang)
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded( // Agar teks lokasi tidak overflow
                                    child: Text(
                                      item['alamat']!.split(',').last.trim(), // Ambil hanya nama kota
                                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
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