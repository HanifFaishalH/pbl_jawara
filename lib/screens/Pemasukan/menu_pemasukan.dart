import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _isHovering
              ? colorScheme
                    .surfaceVariant // Beri sedikit warna latar saat hover
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(widget.icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label,
              textAlign: TextAlign.center, // Agar rapi jika label 2 baris
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
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

    final items = [
      {
        'label': 'Kategori Iuran',
        'icon': FontAwesomeIcons.wallet,
        'route': '/kategori-iuran',
      },
      {
        'label': 'Tagih Iuran',
        'icon': FontAwesomeIcons.calendarDays,
        'route': '/tagih-iuran',
      },
      {
        'label': 'Tagihan',
        'icon': FontAwesomeIcons.peopleGroup,
        'route': '/daftar-tagihan',
      },
      {
        'label': 'Lain-lain',
        'icon': FontAwesomeIcons.book,
        'route': '/pemasukan-lain',
      },
    ];

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
          const SizedBox(height: 12),
          Row(
            // Tambahkan ini agar item tetap rapi di atas
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) {
              // Ganti blok InkWell lama dengan widget baru ini
              // Bungkus dengan Expanded agar area tap/hover merata
              return Expanded(
                child: MenuPemasukanItem(
                  icon: e['icon'] as IconData,
                  label: e['label'] as String,
                  route: e['route'] as String,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
