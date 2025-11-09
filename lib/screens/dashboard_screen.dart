import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/dashboard_chart.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_statistik.dart';
import '../widgets/kegiatan_section.dart';
import '../widgets/log_aktivitas_section.dart';
import '../widgets/bottom_navbar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // Aktifkan agar body bisa “tembus” ke bawah navigation bar yang melayang
      extendBody: true,
      backgroundColor: colorScheme.onPrimary,

      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Konten utama dashboard
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  DashboardHeader(),
                  SizedBox(height: 16),
                  DashboardStatistik(),
                  SizedBox(height: 24),

                  DashboardChart(),
                  SizedBox(height: 24),

                  KegiatanSection(),
                  SizedBox(height: 24),
                  LogAktivitasSection(),
                  SizedBox(height: 80), // beri jarak agar konten tak tertutup nav
                ],
              ),
            ),

            // 🔹 Bottom Navigation mengambang
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const BottomNavbar(), // Widget bottom_navbar.dart
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
