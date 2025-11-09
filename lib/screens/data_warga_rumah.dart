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
      ),
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          // ================= TAB BAR =================
          Container(
            color: colorScheme.primaryContainer,
            child: TabBar(
              controller: _tabController,
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
              tabs: const [
                Tab(text: "Data Warga"),
                Tab(text: "Keluarga"),
                Tab(text: "Data Rumah"),
              ],
            ),
          ),

          // ================= ISI TAB =================
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
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
