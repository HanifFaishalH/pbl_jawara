import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void showMenuPopUp(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return const SizedBox.shrink(); // Tidak perlu isi di sini
    },
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
            child: _MenuPopUpContent(parentContext: context),
          ),
        ),
      );
    },
  );
}

class _MenuPopUpContent extends StatelessWidget {
  final BuildContext parentContext;

  const _MenuPopUpContent({required this.parentContext});

  void showFeatureNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini sedang dalam pengembangan'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'action': () => showFeatureNotReady(context),
      },
      {
        'icon': Icons.event_note,
        'title': 'Kegiatan',
        'action': () => context.push('/kegiatan'),
      },
      {
        'icon': Icons.home_work,
        'title': 'Data Warga & Rumah',
        'action': () => context.push('/data-warga-rumah'),
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Pemasukan',
        'action': () => context.push('/menu-pemasukan'),
      },
      {
        'icon': Icons.monetization_on,
        'title': 'Pengeluaran',
        'action': () => context.push('/pengeluaran'),
      },
      {
        'icon': Icons.assessment,
        'title': 'Laporan Keuangan',
        'action': () => context.push('/laporan-keuangan'),
      },
      {
        'icon': Icons.campaign,
        'title': 'Broadcast',
        'action': () => context.push('/broadcast'),
      },
      {
        'icon': Icons.chat_bubble,
        'title': 'Pesan Warga',
        'action': () => showFeatureNotReady(context),
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Penerimaan Warga',
        'action': () => context.push('/penerimaan-warga'),
      },
      {
        'icon': Icons.switch_account,
        'title': 'Mutasi Keluarga',
        'action': () => context.push('/mutasi'),
      },
      {
        'icon': Icons.history,
        'title': 'Log Aktifitas',
        'action': () => context.push('/log-aktivitas'),
      },
      {
        'icon': Icons.manage_accounts,
        'title': 'Manajemen Pengguna',
        'action': () => context.push('/manajemen-pengguna'),
      },
      {
        'icon': Icons.wallet,
        'title': 'Channel Transfer',
        'action': () => context.push('/channel-transfer'),
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Aspirasi',
        'action': () => context.push('/dashboard-aspirasi'),
      },
      {
        'icon': Icons.store,
        'title': 'Marketplace',
        'action': () => context.push('/menu-marketplace'),
      },
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
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
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: menuItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return InkWell(
              onTap: () {
                Navigator.pop(context); // Tutup popup dulu
                Future.delayed(const Duration(milliseconds: 100), () {
                  item['action']();
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
                      item['icon'],
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['title'],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
