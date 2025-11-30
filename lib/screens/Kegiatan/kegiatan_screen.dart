import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/kegiatan_service.dart';
import 'package:jawaramobile_1/widgets/kegiatan/kegiatan_card.dart';
import 'package:jawaramobile_1/widgets/kegiatan/kegiatan_empty_state.dart';

class KegiatanScreen extends StatefulWidget {
  const KegiatanScreen({super.key});

  @override
  State<KegiatanScreen> createState() => _KegiatanScreenState();
}

class _KegiatanScreenState extends State<KegiatanScreen> {
  final _service = KegiatanService();
  List<dynamic> _list = [];
  bool _loading = true;

  // --- PERBAIKAN DI SINI ---
  // Mengizinkan akses manajemen untuk:
  // 1 = Admin, 2 = RW, 3 = RT
  bool get canManage {
    final allowedRoles = [1, 2, 3];
    return allowedRoles.contains(AuthService.currentRoleId);
  }
  // -------------------------

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);
    
    try {
      final data = await _service.getKegiatan();
      if (mounted) {
        setState(() {
          _list = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Daftar Kegiatan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      
      // Menggunakan variabel canManage untuk menampilkan tombol tambah
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: primaryColor,
              icon: const Icon(Icons.add),
              label: const Text("Buat Kegiatan"),
              onPressed: () async {
                await context.push('/tambah-kegiatan');
                _refresh();
              },
            )
          : null,
          
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryColor,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _list.isEmpty
                ? const KegiatanEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      final item = _list[index];
                      return KegiatanCard(
                        item: item,
                        onRefreshNeeded: _refresh,
                      );
                    },
                  ),
      ),
    );
  }
}