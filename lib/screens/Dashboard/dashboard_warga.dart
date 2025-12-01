import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/kegiatan_section.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardWargaScreen extends StatelessWidget {
  const DashboardWargaScreen({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Gunakan header baru
                    const DashboardHeader(
                      title: "Dashboard Warga",
                      subtitle: "Selamat datang kembali",
                    ),

                    const SizedBox(height: 24),

                    // Kegiatan section
                    const KegiatanSection(
                      roleFilter: "Warga",
                      showAddButton: false,
                      title: "Kegiatan Warga",
                      subtitle: "Kegiatan terbaru minggu ini",
                    ).animate().fadeIn(duration: 700.ms),

                    const SizedBox(height: 24),

                    // Tombol kirim laporan
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur kirim laporan coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.report_problem),
                      label: const Text("Kirim Laporan"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Navbar mengambang di bawah
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
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
