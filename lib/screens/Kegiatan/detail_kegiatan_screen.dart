import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/widgets/kegiatan/detail_header.dart';
import 'package:jawaramobile_1/widgets/kegiatan/detail_content.dart';
import 'package:jawaramobile_1/widgets/kegiatan/detail_admin_actions.dart';

class DetailKegiatanScreen extends StatelessWidget {
  final Map<String, dynamic> kegiatanData;

  const DetailKegiatanScreen({super.key, required this.kegiatanData});

  @override
  Widget build(BuildContext context) {
    // --- PERBAIKAN DI SINI ---
    // Cek Role: Izinkan Admin (1), RW (2), dan RT (3)
    final allowedRoles = [1, 2, 3];
    bool canManage = allowedRoles.contains(AuthService.currentRoleId);
    // -------------------------

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // 1. Header Gambar
          DetailHeader(
            fotoPath: kegiatanData['kegiatan_foto'] ?? kegiatanData['foto'],
          ),

          // 2. Konten & Actions
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
                ),
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                child: Column(
                  children: [
                    DetailContent(
                      title: kegiatanData['kegiatan_nama'] ?? 'Tanpa Nama',
                      category: kegiatanData['kegiatan_kategori'] ?? 'Umum',
                      location: kegiatanData['kegiatan_lokasi'] ?? '-',
                      date: kegiatanData['kegiatan_tanggal'] ?? '-',
                      description: kegiatanData['kegiatan_deskripsi'] ?? 'Tidak ada deskripsi.',
                    ),
                    
                    // Tampilkan tombol aksi jika user punya hak akses (1, 2, atau 3)
                    if (canManage) 
                      DetailAdminActions(kegiatanData: kegiatanData),
                      
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}