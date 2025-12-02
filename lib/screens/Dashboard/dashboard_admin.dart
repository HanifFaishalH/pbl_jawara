import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/dashboard_chart.dart';
import '../../widgets/dashboard_statistik.dart';
import '../../widgets/log_aktivitas_section.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // ======= MAIN CONTENT =======
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const DashboardHeader(
                      title: "Dashboard Admin",
                      subtitle: "Kelola semua data dan laporan RW/RT",
                    ),

                    const SizedBox(height: 24),

                    // Chart section
                    const DashboardChart()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Statistik ringkasan
                    const DashboardStatistik()
                        .animate()
                        .fadeIn(duration: 700.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 24),

                    // Log aktivitas terbaru
                    const LogAktivitasSection()
                        .animate()
                        .fadeIn(duration: 800.ms)
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),

            // ======= FLOATING NAVBAR =======
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
