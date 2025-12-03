import 'package:flutter/material.dart';
import 'package:jawaramobile_1/screens/Mutasi/daftar_mutasi_warga_screen.dart';
import 'package:jawaramobile_1/screens/Mutasi/daftar_mutasi_keluarga_screen.dart';

class MutasiScreen extends StatefulWidget {
  const MutasiScreen({super.key});

  @override
  State<MutasiScreen> createState() => _MutasiScreenState();
}

class _MutasiScreenState extends State<MutasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mutasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Mutasi Warga',
            ),
            Tab(
              icon: Icon(Icons.family_restroom),
              text: 'Mutasi Keluarga',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DaftarMutasiWargaScreen(isTabView: true),
          DaftarMutasiKeluargaScreen(isTabView: true),
        ],
      ),
    );
  }
}
