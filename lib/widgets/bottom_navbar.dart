import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/widgets/menu_popup.dart';
import 'package:jawaramobile_1/services/auth_service.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/broadcast')) return 1;
    if (location.startsWith('/menu-popup')) return 2;
    if (location.startsWith('/marketplace')) return 3;
    return 0;
  }

  Future<void> _logout() async {
    try {
      await AuthService().logout();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout'),
          backgroundColor: Color(0xFF26547C),
        ),
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    }
  }

  void _showUnderDevelopment() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 10),
            Text("Fitur ini sedang dalam pengembangan."),
          ],
        ),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onItemTapped(int index) async {
    try {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;

        case 1:
          try {
            context.push('/broadcast'); 
          } catch (_) {
            _showUnderDevelopment();
          }
          break;

        case 2:
          await _controller.forward();
          if (!mounted) return;
          showMenuPopUp(context);
          await _controller.reverse();
          break;

        case 3:
          try {
            context.go('/menu-marketplace');
          } catch (_) {
            _showUnderDevelopment();
          }
          break;

        case 4:
          _logout();
          break;

        default:
          _showUnderDevelopment();
      }
    } catch (_) {
      _showUnderDevelopment();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = const [
      {'icon': FontAwesomeIcons.house, 'label': 'Home'},
      {'icon': FontAwesomeIcons.bullhorn, 'label': 'Broadcast'}, 
      {'icon': FontAwesomeIcons.bars, 'label': 'Menu'},
      {'icon': FontAwesomeIcons.store, 'label': 'Market'},
      {'icon': FontAwesomeIcons.rightFromBracket, 'label': 'Logout'},
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