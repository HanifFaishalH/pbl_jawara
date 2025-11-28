import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardBendaharaScreen extends StatelessWidget {
  const DashboardBendaharaScreen({super.key});

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
                    title: "Dashboard Bendahara",
                    subtitle: "Kelola keuangan dan kas warga",
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "💰 Total kas RW: Rp 2.450.000\n📥 Pemasukan bulan ini: Rp 750.000\n📤 Pengeluaran: Rp 300.000",
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
