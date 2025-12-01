import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

void showMenuPopUp(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, secondaryAnim, child) {
      final offsetAnim = Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));

      return SlideTransition(
        position: offsetAnim,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70, left: 16, right: 16),
            child: const _MenuPopUpContent(),
          ),
        ),
      );
    },
  );
}

class _MenuPopUpContent extends StatelessWidget {
  const _MenuPopUpContent();

  void showFeatureNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini sedang dalam pengembangan'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final int roleId = AuthService.currentRoleId ?? 6;

    // === Daftar Menu (Gunakan route name dari app router kamu) ===
    final Map<String, Map<String, dynamic>> menuLibrary = {
      // ---- Menu Umum ----
      'dashboard': {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'action': () => context.pushNamed('dashboard'),
      },
      'pesan_warga': {
        'icon': Icons.chat_bubble,
        'title': 'Pesan Warga',
        'action': () => context.pushNamed('pesan-warga'),
      },
      'broadcast': {
        'icon': Icons.campaign,
        'title': 'Broadcast',
        'action': () => context.pushNamed('broadcast'),
      },
      'kegiatan': {
        'icon': Icons.event_note,
        'title': 'Kegiatan',
        'action': () => context.pushNamed('kegiatan'),
      },
      'log_aktivitas': {
        'icon': Icons.history,
        'title': 'Log Aktivitas',
        'action': () => context.pushNamed('log-aktivitas'),
      },
      'marketplace': {
        'icon': Icons.store,
        'title': 'Marketplace',
        'action': () => context.pushNamed('menu-marketplace'),
      },
      'channel': {
        'icon': Icons.wallet,
        'title': 'Channel Transfer',
        'action': () => context.pushNamed('channel-transfer'),
      },
      'aspirasi': {
        'icon': Icons.lightbulb,
        'title': 'Aspirasi',
        'action': () => context.pushNamed('dashboard-aspirasi'),
      },

      // ---- Menu Khusus Pengurus ----
      'data_warga': {
        'icon': Icons.home_work,
        'title': 'Data Warga',
        'action': () => context.pushNamed('data-warga-rumah'),
      },
      'laporan_keuangan': {
        'icon': Icons.assessment,
        'title': 'Laporan Keuangan',
        'action': () => context.pushNamed('laporan-keuangan'),
      },
      'penerimaan_warga': {
        'icon': Icons.person_add,
        'title': 'Penerimaan Warga',
        'action': () => context.pushNamed('penerimaan-warga'),
      },
      'mutasi': {
        'icon': Icons.switch_account,
        'title': 'Mutasi Keluarga',
        'action': () => context.pushNamed('mutasi'),
      },
      'pemasukan': {
        'icon': Icons.download,
        'title': 'Pemasukan',
        'action': () => context.pushNamed('menu-pemasukan'),
      },
      'pengeluaran': {
        'icon': Icons.upload,
        'title': 'Pengeluaran',
        'action': () => context.pushNamed('pengeluaran'),
      },
      'manajemen_pengguna': {
        'icon': Icons.manage_accounts,
        'title': 'Manajemen User',
        'action': () => context.pushNamed('manajemen-pengguna'),
      },
    };

    // === Susunan Menu Dasar ===
    final List<Map<String, dynamic>> menuItems = [];
    final baseKeys = [
      'dashboard',
      'pesan_warga',
      'broadcast',
      'kegiatan',
      'log_aktivitas',
      'marketplace',
      'channel',
      'aspirasi',
    ];

    for (final key in baseKeys) {
      if (menuLibrary.containsKey(key)) {
        menuItems.add(menuLibrary[key]!);
      }
    }

    // === Menu Tambahan Berdasarkan Role ===
    if (roleId == 1) {
      // === ADMIN ===
      final adminKeys = [
        'data_warga',
        'laporan_keuangan',
        'penerimaan_warga',
        'mutasi',
        'pemasukan',
        'pengeluaran',
        'manajemen_pengguna',
      ];
      for (final key in adminKeys) {
        menuItems.add(menuLibrary[key]!);
      }
    } else if (roleId == 2 || roleId == 3) {
      // === PENGURUS / RW ===
      final pengurusKeys = [
        'data_warga',
        'laporan_keuangan',
        'penerimaan_warga',
        'mutasi',
      ];
      for (final key in pengurusKeys) {
        menuItems.add(menuLibrary[key]!);
      }
    } else if (roleId == 4) {
      // === KETUA RT ===
      final ketuaKeys = [
        'data_warga',
        'manajemen_pengguna',
        'mutasi',
      ];
      for (final key in ketuaKeys) {
        menuItems.add(menuLibrary[key]!);
      }
    } else if (roleId == 5) {
      // === BENDAHARA ===
      final bendaharaKeys = [
        'pemasukan',
        'pengeluaran',
        'laporan_keuangan',
      ];
      for (final key in bendaharaKeys) {
        menuItems.add(menuLibrary[key]!);
      }
    }

    // === UI Popup ===
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar (indikator drag)
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Grid Menu
              GridView.builder(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 120), () {
                        final action = item['action'] as VoidCallback?;
                        action?.call();
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 30,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
