import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/dashboard_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_statistik.dart';
import '../widgets/kegiatan_section.dart';
import '../widgets/log_aktivitas_section.dart';
import '../widgets/bottom_navbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // 🌟 Konten Utama Dashboard
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader()
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 20),

                  // Statistik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const DashboardStatistik(),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),

                  // Grafik
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const DashboardChart(),
                  ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0),

                  const SizedBox(height: 24),

                  const KegiatanSection()
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .slideX(begin: 0.2, end: 0),
                  const SizedBox(height: 24),

                  const LogAktivitasSection()
                      .animate()
                      .fadeIn(duration: 700.ms)
                      .slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // 🌊 Bottom Navbar Floating
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
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
        ],
      ),
    );
  }
}
