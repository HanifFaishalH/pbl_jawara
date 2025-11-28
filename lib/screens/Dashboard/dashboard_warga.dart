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
                    title: "Dashboard Warga",
                    subtitle: "Lihat kegiatan & kirim laporan",
                  ),
                  const SizedBox(height: 24),
                  const KegiatanSection(showAddButton: false),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur laporan coming soon')),
                      );
                    },
                    icon: const Icon(Icons.report_problem),
                    label: const Text("Kirim Laporan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
