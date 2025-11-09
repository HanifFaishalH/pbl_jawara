import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/menu_popup.dart'; // ⬅️ Tambahkan ini

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/laporan')) return 1;
    if (location.startsWith('/menu-popup')) return 2;
    if (location.startsWith('/pengguna')) return 3;
    return 0;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
      // laporan
        break;
      case 2:
        showMenuPopUp(context); // ✅ ganti ini
        break;
      case 3:
      // pengguna
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = const [
      {'icon': FontAwesomeIcons.house, 'label': 'Home'},
      {'icon': FontAwesomeIcons.fileLines, 'label': 'Laporan'},
      {'icon': FontAwesomeIcons.bars, 'label': 'Menu'},
      {'icon': FontAwesomeIcons.userGroup, 'label': 'Pengguna'},
    ];

    return BottomNavigationBar(
      currentIndex: _calculateSelectedIndex(context),
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
      backgroundColor: colorScheme.surface,
      items: items
          .map((e) => BottomNavigationBarItem(
        icon: FaIcon(e['icon'] as IconData),
        label: e['label'] as String,
      ))
          .toList(),
    );
  }
}
