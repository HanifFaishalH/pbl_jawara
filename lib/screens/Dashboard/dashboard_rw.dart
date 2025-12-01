import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/kegiatan_section.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardRwScreen extends StatelessWidget {
  const DashboardRwScreen({super.key});

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
                    const DashboardHeader(
                      title: "Dashboard Ketua RW",
                      subtitle: "Pantau laporan dan kegiatan RT",
                    ),
                    const SizedBox(height: 24),

                    const KegiatanSection(showAddButton: true)
                        .animate()
                        .fadeIn(duration: 700.ms),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        "📊 5 laporan baru dari warga minggu ini",
                        style: TextStyle(fontSize: 15),
                      ),
                    ).animate().fadeIn(duration: 700.ms, delay: 300.ms),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // 🔹 Navbar mengambang
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                  child: Container(
                    height: 70,
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
                    child: const ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(24)),
                      child: BottomNavbar(),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
