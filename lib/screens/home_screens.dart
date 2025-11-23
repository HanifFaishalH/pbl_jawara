import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(
      child: Text(
        "Beranda",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        "Pencarian",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(
      child: Text(
        "Profil",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.background,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary, // biru tua
              AppTheme.third,   // hijau toska lembut
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _pages[_selectedIndex],
      ),

      // 🔘 Bottom Navigation Bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.grey.shade500,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
                label: 'Cari',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.user),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),

      // 🆕 Floating Action Button (opsional)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.secondary,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aksi cepat diaktifkan'),
              backgroundColor: AppTheme.secondary,
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
