import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/log_aktivitas_section.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardRtScreen extends StatelessWidget {
  const DashboardRtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const DashboardHeader(
                    title: "Dashboard Ketua RT",
                    subtitle: "Lihat laporan dan update kegiatan warga",
                  ),
                  const SizedBox(height: 24),
                  const LogAktivitasSection(),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "📋 Total laporan warga: 12\n✅ Selesai: 8\n⏳ Dalam proses: 4",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
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
