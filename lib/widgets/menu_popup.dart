import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Ganti import ini sesuai lokasi file AuthService Anda
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
            child: _MenuPopUpContent(),
          ),
        ),
      );
    },
  );
}

class _MenuPopUpContent extends StatelessWidget {
  _MenuPopUpContent();

  void showFeatureNotReady(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini sedang dalam pengembangan'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 1. AMBIL ROLE ID (Default ke 6/Warga jika null)
    final int roleId = AuthService.currentRoleId ?? 6;

    // 2. LIBRARY SEMUA MENU (Definisi Icon & Route)
    final Map<String, Map<String, dynamic>> menuLibrary = {
      // -- Menu Umum --
      'dashboard': {
        'icon': Icons.dashboard, 'title': 'Dashboard', 
        'action': () => showFeatureNotReady(context) // Atau context.push('/dashboard')
      },
      'pesan_warga': {
        'icon': Icons.chat_bubble, 'title': 'Pesan Warga', 
        'action': () => showFeatureNotReady(context)
      },
      'broadcast': {
        'icon': Icons.campaign, 'title': 'Broadcast', 
        'action': () => context.push('/broadcast')
      },
      'kegiatan': {
        'icon': Icons.event_note, 'title': 'Kegiatan', 
        'action': () => context.push('/kegiatan')
      },
      'log_aktivitas': {
        'icon': Icons.history, 'title': 'Log Aktifitas', 
        'action': () => context.push('/log-aktivitas')
      },
      'marketplace': {
        'icon': Icons.store, 'title': 'Marketplace', 
        'action': () => context.push('/menu-marketplace')
      },
      'channel': {
        'icon': Icons.wallet, 'title': 'Channel Transfer', 
        'action': () => context.push('/channel-transfer')
      },
      'aspirasi': {
        'icon': Icons.lightbulb, 'title': 'Aspirasi', 
        'action': () => context.push('/aspirasi-screen')
      },

      // -- Menu Khusus Pengurus --
      'data_warga': {
        'icon': Icons.home_work, 'title': 'Data Warga', 
        'action': () => context.push('/data-warga-rumah')
      },
      'laporan_keuangan': {
        'icon': Icons.assessment, 'title': 'Laporan Keuangan', 
        'action': () => context.push('/laporan-keuangan')
      },
      'penerimaan_warga': {
        'icon': Icons.person_add, 'title': 'Penerimaan Warga', 
        'action': () => context.push('/penerimaan-warga')
      },
      'mutasi': {
        'icon': Icons.switch_account, 'title': 'Mutasi Keluarga', 
        'action': () => context.push('/mutasi')
      },
      'pemasukan': {
        'icon': Icons.download, 'title': 'Pemasukan', 
        'action': () => context.push('/menu-pemasukan')
      },
      'pengeluaran': {
        'icon': Icons.upload, 'title': 'Pengeluaran', 
        'action': () => context.push('/pengeluaran')
      },
      'manajemen_pengguna': {
        'icon': Icons.manage_accounts, 'title': 'Manajemen User', 
        'action': () => context.push('/manajemen-pengguna')
      },
    };

    // 3. LOGIKA PENYUSUNAN MENU
    List<Map<String, dynamic>> menuItems = [];

    // A. Menu Dasar (Semua Orang Dapat)
    List<String> baseKeys = [
      'dashboard', 'pesan_warga', 'broadcast', 'kegiatan', 
      'log_aktivitas', 'marketplace', 'channel', 'aspirasi'
    ];
    for (var key in baseKeys) {
      if (menuLibrary.containsKey(key)) menuItems.add(menuLibrary[key]!);
    }

    // B. Menu Tambahan Berdasarkan Role
    if (roleId == 1) { 
      // === ADMIN (1) ===
      // Tambahkan sisa menu yang belum ada di baseKeys
      List<String> adminKeys = [
        'data_warga', 'laporan_keuangan', 'penerimaan_warga', 'mutasi',
        'pemasukan', 'pengeluaran', 'manajemen_pengguna'
      ];
      for (var key in adminKeys) {
        menuItems.add(menuLibrary[key]!);
      }

    } else if (roleId == 2 || roleId == 3) {
      // === RW (2) & RT (3) ===
      menuItems.add(menuLibrary['data_warga']!);
      menuItems.add(menuLibrary['laporan_keuangan']!);
      menuItems.add(menuLibrary['penerimaan_warga']!);
      menuItems.add(menuLibrary['mutasi']!);

    } else if (roleId == 4) {
      // === SEKRETARIS (4) ===
      menuItems.add(menuLibrary['data_warga']!);
      menuItems.add(menuLibrary['manajemen_pengguna']!);
      menuItems.add(menuLibrary['mutasi']!);

    } else if (roleId == 5) {
      // === BENDAHARA (5) ===
      menuItems.add(menuLibrary['pemasukan']!);
      menuItems.add(menuLibrary['pengeluaran']!);
      menuItems.add(menuLibrary['laporan_keuangan']!);
    }

    // 4. RENDER TAMPILAN
    return Material(
      color: Colors.transparent,
      child: Container(
        // Batasi tinggi maksimal agar tidak menutupi seluruh layar jika menu banyak
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
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 5),
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              // Grid Menu
              GridView.builder(
                padding: const EdgeInsets.all(20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Scroll di handle oleh SingleChildScrollView
                itemCount: menuItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 kolom
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, 
                ),
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context); // Tutup popup
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (item['action'] != null) item['action']();
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
                            spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 30, color: theme.colorScheme.primary),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(
                              item['title'],
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