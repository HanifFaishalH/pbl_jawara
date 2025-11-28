import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/dashboard_chart.dart';
import '../../widgets/dashboard_statistik.dart';
import '../../widgets/kegiatan_section.dart';
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(
                    title: "Dashboard Admin",
                    subtitle: "Kelola semua data dan laporan RW/RT",
                  ),
                  const SizedBox(height: 24),
                  const DashboardChart(),
                  const SizedBox(height: 24),
                  const DashboardStatistik(),
                  const SizedBox(height: 24),
                  const LogAktivitasSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          const Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: BottomNavbar(),
          ),
        ],
      ),
    );
  }
}
