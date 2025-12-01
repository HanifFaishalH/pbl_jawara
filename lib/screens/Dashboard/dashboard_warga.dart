import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/kegiatan_section.dart';
import '../../widgets/bottom_navbar.dart';

class DashboardWargaScreen extends StatefulWidget {
  const DashboardWargaScreen({super.key});

  @override
  State<DashboardWargaScreen> createState() => _DashboardWargaScreenState();
}

class _DashboardWargaScreenState extends State<DashboardWargaScreen> {
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final namaDepan = prefs.getString('user_nama_depan') ?? 'User';
    setState(() {
      userName = namaDepan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      extendBody: true, // biar konten di belakang navbar bisa tembus
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 KONTEN UTAMA
            Padding(
              padding: const EdgeInsets.only(bottom: 90), // beri ruang untuk navbar
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $userName 👋',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Selamat datang kembali',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none),
                            color: colors.primary,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notifikasi belum tersedia')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // KEGIATAN SECTION
                    const KegiatanSection(
                      roleFilter: "Warga",
                      showAddButton: false,
                      title: "Kegiatan Warga",
                      subtitle: "Kegiatan terbaru minggu ini",
                    ).animate().fadeIn(duration: 700.ms),
                    const SizedBox(height: 24),

                    // TOMBOL KIRIM LAPORAN
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

            // 🔹 NAVBAR MENGAMBANG DI BAWAH
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
