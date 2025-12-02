import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/pengguna_model.dart';
import '../../services/man_pengguna_service.dart';
// Sesuaikan path ini dengan lokasi file filter kamu
import '../../widgets/manajemen_pengguna_filter.dart'; 

class DaftarPenggunaScreen extends StatefulWidget {
  const DaftarPenggunaScreen({super.key});

  @override
  State<DaftarPenggunaScreen> createState() => _DaftarPenggunaScreenState();
}

class _DaftarPenggunaScreenState extends State<DaftarPenggunaScreen> {
  final PenggunaService _service = PenggunaService();
  
  List<PenggunaModel> _allUsers = [];
  List<PenggunaModel> _filteredUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Variabel untuk menyimpan state filter saat ini
  String? _queryNama;
  String? _queryStatus;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { 
      _isLoading = true; 
      _errorMessage = null; 
    });
    
    try {
      final users = await _service.getPengguna();
      setState(() {
        _allUsers = users;
        _applyFilter(); // Filter ulang setiap data di-refresh
        _isLoading = false;
      });
    } catch (e) {
      setState(() { 
        _errorMessage = e.toString(); 
        _isLoading = false; 
      });
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        // Logika Nama
        final okNama = _queryNama == null || _queryNama!.isEmpty 
            ? true 
            : (u.nama.toLowerCase().contains(_queryNama!.toLowerCase()));
        
        // Logika Status
        final okStatus = _queryStatus == null || _queryStatus!.isEmpty 
            ? true 
            : (u.status.toLowerCase() == _queryStatus!.toLowerCase());
            
        return okNama && okStatus;
      }).toList();
    });
  }

  // LOGIKA UTAMA INTEGRASI FILTER
  void _openFilter() async {
    // 1. Panggil dialog dan tunggu (await) hasilnya
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Filter Data"),
        // 2. Masukkan Widget Filter & Kirim data saat ini (agar tidak reset saat dibuka)
        content: ManajemenPenggunaFilter(
          initialNama: _queryNama,
          initialStatus: _queryStatus,
        ),
        // CATATAN: Jangan tambahkan 'actions' di sini, 
        // karena tombol sudah ada di dalam ManajemenPenggunaFilter
      ),
    );

    // 3. Jika user menekan "Terapkan" (result tidak null), update state screen ini
    if (result != null) {
      setState(() {
        _queryNama = result['nama'];
        _queryStatus = result['status'];
        _applyFilter();
      });
    }
  }

  Color statusBg(String s) {
    switch (s.toLowerCase()) {
      case 'diterima': return Colors.green.withOpacity(0.1);
      case 'pending':  return Colors.orange.withOpacity(0.1);
      case 'ditolak':  return Colors.red.withOpacity(0.1);
      default: return Colors.grey.withOpacity(0.1);
    }
  }

  Color statusFg(String s) {
    switch (s.toLowerCase()) {
      case 'diterima': return Colors.green.shade700;
      case 'pending':  return Colors.orange.shade700;
      case 'ditolak':  return Colors.red.shade700;
      default: return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah sedang ada filter aktif untuk visual feedback
    final bool isFiltering = _queryNama != null || _queryStatus != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Daftar Pengguna"),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: isFiltering ? Colors.blue : null, // Biru jika sedang memfilter
            ), 
            onPressed: _openFilter
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.pushNamed('tambah-pengguna');
          _fetchData(); 
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _errorMessage != null
            ? Center(child: Text(_errorMessage!))
            : _filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Data tidak ditemukan"),
                      if (isFiltering)
                        TextButton(
                          onPressed: () {
                             // Reset cepat jika kosong karena filter
                             setState(() { _queryNama = null; _queryStatus = null; _applyFilter(); });
                          }, 
                          child: const Text("Hapus Filter")
                        )
                    ],
                  )
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80, top: 8),
                  itemCount: _filteredUsers.length,
                  itemBuilder: (context, index) {
                    final u = _filteredUsers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          await context.pushNamed('detail-pengguna', extra: u);
                          _fetchData();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(
                                  u.nama.isNotEmpty ? u.nama[0].toUpperCase() : '?',
                                  style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.nama,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      u.email,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      maxLines: 1, overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusBg(u.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  u.status,
                                  style: TextStyle(color: statusFg(u.status), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}