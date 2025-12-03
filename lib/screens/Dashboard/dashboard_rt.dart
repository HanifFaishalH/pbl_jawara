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
      extendBody: true,
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // ======= MAIN CONTENT =======
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER DASHBOARD
                    const DashboardHeader(
                      title: "Dashboard Ketua RT",
                      subtitle: "Pantau laporan dan kegiatan warga",
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: 24),

                    // ======= INFO CARD SECTION =======
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.report_problem_outlined,
                            title: "Laporan",
                            value: "12",
                            subtitle: "Total laporan warga",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.verified_outlined,
                            title: "Selesai",
                            value: "8",
                            subtitle: "Sudah ditangani",
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.timelapse_rounded,
                            title: "Proses",
                            value: "4",
                            subtitle: "Dalam pengerjaan",
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildInfoCard(
                            context,
                            icon: Icons.group_outlined,
                            title: "Warga Aktif",
                            value: "87",
                            subtitle: "Terdata aktif",
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 700.ms).slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 30),

                    // ======= AKTIVITAS SECTION =======
                    const LogAktivitasSection()
                        .animate()
                        .fadeIn(duration: 700.ms, delay: 100.ms),

                    const SizedBox(height: 30),

                    // ======= LAPORAN TERBARU =======
                    const Text(
                      "Laporan Terbaru",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    _buildLaporanCard(
                      context,
                      title: "Lampu jalan mati di RW 04",
                      subtitle: "Dikirim oleh: Budi Santoso",
                      status: "Dalam proses",
                      color: Colors.amber,
                    ),
                    const SizedBox(height: 10),
                    _buildLaporanCard(
                      context,
                      title: "Got tersumbat di blok C",
                      subtitle: "Dikirim oleh: Ibu Wati",
                      status: "Selesai",
                      color: Colors.green,
                    ),

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

  // ======= WIDGET: Info Card =======
  Widget _buildInfoCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String value,
      required String subtitle,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                color: color.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              )),
        ],
      ),
    );
  }

  // ======= WIDGET: Laporan Card =======
  Widget _buildLaporanCard(BuildContext context,
      {required String title,
      required String subtitle,
      required String status,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: color),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
