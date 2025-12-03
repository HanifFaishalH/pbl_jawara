import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart'; // ✅ WAJIB: Import GoRouter

// SESUAIKAN IMPORT INI DENGAN STRUKTUR FOLDER ANDA
import '../../widgets/dashboard_header.dart';
import '../../widgets/kegiatan_section.dart';
import '../../widgets/bottom_navbar.dart';
import '../../services/kegiatan_service.dart';

class DashboardWargaScreen extends StatefulWidget {
  const DashboardWargaScreen({super.key});

  @override
  State<DashboardWargaScreen> createState() => _DashboardWargaScreenState();
}

class _DashboardWargaScreenState extends State<DashboardWargaScreen> {
  final _kegiatanService = KegiatanService();
  List<dynamic> _kegiatanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchKegiatan();
  }

  Future<void> _fetchKegiatan() async {
    try {
      final data = await _kegiatanService.getKegiatan();
      if (mounted) {
        setState(() {
          _kegiatanList = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Error fetching dashboard data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardHeader(
                      title: "Dashboard Warga",
                      subtitle: "Selamat datang kembali",
                    ),
                    const SizedBox(height: 24),

                    // 🔥 Mengirim data ke KegiatanSection
                    KegiatanSection(
                      roleFilter: "Warga",
                      showAddButton: false,
                      title: "Kegiatan Warga",
                      subtitle: "Kegiatan terbaru minggu ini",
                      dataList: _kegiatanList, // Data dari database
                      isLoading: _isLoading,   // Status loading
                    ).animate().fadeIn(duration: 700.ms),

                    const SizedBox(height: 24),

                    // ✅ TOMBOL ASPIRASI (DIPERBAIKI)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigasi ke halaman Aspirasi
                        context.push('/aspirasi-screen'); 
                      },
                      // Menggunakan icon Campaign (Toa/Megaphone) agar lebih cocok untuk "Aspirasi"
                      icon: const Icon(Icons.campaign), 
                      label: const Text("Kirim Aspirasi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navbar
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Container(
                    height: 70,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: colors.surface.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: const BottomNavbar(),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}