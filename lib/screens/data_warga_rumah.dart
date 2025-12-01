import 'package:flutter/material.dart';
import './DataWargaRumah/tabel_keluarga.dart';
import './DataWargaRumah/tabel_rumah.dart';
import './DataWargaRumah/tabel_warga.dart';

class DataWargaPage extends StatefulWidget {
  const DataWargaPage({super.key});

  @override
  State<DataWargaPage> createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Data Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ================= TAB BAR =================
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.people, size: 20),
                  text: "Warga",
                ),
                Tab(
                  icon: Icon(Icons.family_restroom, size: 20),
                  text: "Keluarga",
                ),
                Tab(
                  icon: Icon(Icons.home, size: 20),
                  text: "Rumah",
                ),
              ],
            ),
          ),

          // ================= ISI TAB =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TabelWarga(),
                TabelKeluarga(),
                TabelRumah(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
