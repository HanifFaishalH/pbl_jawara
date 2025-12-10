import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class MenuPemasukan extends StatefulWidget {
  const MenuPemasukan({super.key});

  @override
  State<MenuPemasukan> createState() => _MenuPemasukanState();
}

class _MenuPemasukanState extends State<MenuPemasukan> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pemasukan'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      // Aktifkan agar body bisa “tembus” ke bawah navigation bar yang melayang
      extendBody: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 24, right: 16, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  MenuPemasukanHeader(), // beri jarak agar konten tak tertutup nav
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPemasukanItem extends StatefulWidget {
  const MenuPemasukanItem({
    super.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;

  @override
  State<MenuPemasukanItem> createState() => _MenuPemasukanItemState();
}

class _MenuPemasukanItemState extends State<MenuPemasukanItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => context.go(widget.route),
      // Gunakan onHover untuk mengubah state
      onHover: (hovering) {
        setState(() {
          _isHovering = hovering;
        });
      },
      borderRadius: BorderRadius.circular(
        16,
      ), // Samakan radius dengan container
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50), // Animasi halus
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: _isHovering
              ? colorScheme
                    .surfaceVariant // Beri sedikit warna latar saat hover
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(widget.icon, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuPemasukanHeader extends StatelessWidget {
  const MenuPemasukanHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Get user role from AuthService
    final userRole = AuthService.currentRoleId ?? 6; // Default to Warga if null
    
    // Define menu items based on role
    final List<Map<String, dynamic>> items = [];
    
    // Menu untuk Admin/Bendahara (role 1 atau 5)
    if (userRole == 1 || userRole == 5) {
      items.addAll([
        {
          'label': 'Kategori Iuran',
          'icon': FontAwesomeIcons.wallet,
          'route': '/kategori-iuran',
        },
        {
          'label': 'Tarik Iuran',
          'icon': FontAwesomeIcons.moneyBillTransfer,
          'route': '/tarik-iuran',
        },
        {
          'label': 'Daftar Tagihan',
          'icon': FontAwesomeIcons.listCheck,
          'route': '/daftar-tagihan-admin',
        },
        {
          'label': 'Verifikasi Pembayaran',
          'icon': FontAwesomeIcons.circleCheck,
          'route': '/verifikasi-pembayaran',
        },
      ]);
    } 
    // Menu untuk Warga (role 6) dan role lainnya
    else {
      items.addAll([
        {
          'label': 'Tagihan Saya',
          'icon': FontAwesomeIcons.fileInvoice,
          'route': '/tagihan-saya',
        },
        {
          'label': 'Bayar Tagihan',
          'icon': FontAwesomeIcons.creditCard,
          'route': '/bayar-tagihan',
        },
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Menu Pemasukan', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          // Gunakan GridView untuk layout yang lebih baik
          LayoutBuilder(
            builder: (context, constraints) {
              // Tentukan jumlah kolom berdasarkan lebar - 2 kolom untuk mobile
              final crossAxisCount = constraints.maxWidth > 600 ? 2 : 2;
              
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: items.map((e) {
                  final icon = e['icon'];
                  final label = e['label'];
                  final route = e['route'];
                  
                  // Null safety check
                  if (icon == null || label == null || route == null) {
                    return const SizedBox.shrink();
                  }
                  
                  return MenuPemasukanItem(
                    icon: icon as IconData,
                    label: label as String,
                    route: route as String,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
