import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/submenu_keuangan.dart';
import 'package:jawaramobile_1/widgets/submenu_manajemen_pengguna.dart';
import 'package:jawaramobile_1/widgets/submenu_channel_transfer.dart';


class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Fungsi helper untuk fitur yang belum siap
    void showFeatureNotReady() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fitur ini sedang dalam pengembangan'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.dashboard,
        'title': 'Dashboard',
        'action': showFeatureNotReady,
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
        'action': () =>
            showSubMenuKeuangan(context), // Panggil fungsi dengan context
      },
      {
        'icon': Icons.campaign,
        'title': 'Broadcast',
        'action': showFeatureNotReady,
      },
      {
        'icon': Icons.chat_bubble,
        'title': 'Pesan Warga',
        'action': showFeatureNotReady,
      },
      {
        'icon': Icons.person_add_alt_1,
        'title': 'Penerimaan Warga',
        'action': showFeatureNotReady,
      },
      {
        'icon': Icons.switch_account,
        'title': 'Mutasi Keluarga',
        'action': () => context.push('/mutasi'),
      },
      {
        'icon': Icons.history,
        'title': 'Log Aktifitas',
        'action': () => context.goNamed('log-aktivitas'), 
      },
      {
        'icon': Icons.manage_accounts,
        'title': 'Manajemen Pengguna',
        'action': () => showSubMenuManajemenPengguna(context), 
      },

      {
        'icon': Icons.wallet,
        'title': 'Channel Transfer',
        'action': () => showSubMenuChannelTransfer(context),
      },

    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Menu",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        // decoration: BoxDecoration(color: Colors.white.withOpacity(0.9)),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuItem(
              context,
              icon: item['icon'],
              title: item['title'],
              onTap: item['action'],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
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
            Icon(icon, size: 36, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              title,
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
  }
}
