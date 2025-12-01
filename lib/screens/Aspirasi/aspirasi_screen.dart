import 'package:flutter/material.dart';
import '../../theme/AppTheme.dart';
import '../../widgets/status_chip.dart';
import '../../models/aspirasi_models.dart';
import '../../services/aspirasi_service.dart';
import '../../services/auth_service.dart';
import 'detail_aspirasi_screen.dart';
import 'tambah_aspirasi_screen.dart';

class DashboardAspirasi extends StatefulWidget {
  const DashboardAspirasi({super.key});

  @override
  State<DashboardAspirasi> createState() => _DashboardAspirasiState();
}

class _DashboardAspirasiState extends State<DashboardAspirasi> {
  final AspirasiService _aspirasiService = AspirasiService();
  List<AspirasiModel> _allData = [];
  List<AspirasiModel> _filteredData = [];
  bool _isLoading = true;

  String? _filterJudul;
  String? _filterStatus;
  
  bool get _isWarga => AuthService.currentRoleId == 6;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _aspirasiService.getAspirasi();
      setState(() {
        _allData = data;
        _applyFilter();
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredData = _allData.where((p) {
        final byJudul = _filterJudul == null || 
            p.judul.toLowerCase().contains(_filterJudul!.toLowerCase());
        final byStatus = _filterStatus == null || 
            p.status.toLowerCase() == _filterStatus!.toLowerCase();
        return byJudul && byStatus;
      }).toList();
    });
  }

  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? tempJudul = _filterJudul;
        String? tempStatus = _filterStatus;
        return AlertDialog(
          title: const Text('Filter Aspirasi'),
          content: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
               TextField(
                 decoration: const InputDecoration(labelText: 'Cari Judul'),
                 onChanged: (v) => tempJudul = v.isEmpty ? null : v,
               ),
               const SizedBox(height: 16),
               DropdownButtonFormField<String>(
                  value: tempStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  // PERUBAHAN: Hanya Pending dan Diterima
                  items: ['Pending', 'Diterima']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => tempStatus = v,
                  hint: const Text('Semua Status'),
               )
             ],
          ),
          actions: [
             TextButton(
              onPressed: () {
                 // Reset Filter
                 _filterJudul = null;
                 _filterStatus = null;
                 _applyFilter();
                 Navigator.pop(context);
              }, 
              child: const Text('Reset', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              onPressed: () {
                _filterJudul = tempJudul;
                _filterStatus = tempStatus;
                _applyFilter();
                Navigator.pop(context);
              }, 
              child: const Text('Terapkan', style: TextStyle(color: Colors.white))
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Aspirasi Warga'),
        backgroundColor: AppTheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          )
        ],
      ),
      floatingActionButton: _isWarga ? FloatingActionButton.extended(
        onPressed: () async {
          bool? reload = await Navigator.push(context, 
            MaterialPageRoute(builder: (_) => const TambahAspirasiScreen()));
          if (reload == true) _fetchData();
        },
        label: const Text('Tulis Aspirasi'),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.secondary,
      ) : null,
      
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showFilterModal(context),
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, 
                  foregroundColor: Colors.white
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredData.isEmpty 
              ? const Center(child: Text('Belum ada data aspirasi'))
              : ListView.builder(
                  itemCount: _filteredData.length,
                  itemBuilder: (context, index) {
                    final item = _filteredData[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: ListTile(
                        title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.pengirim, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            StatusChip(status: item.status), // Pastikan widget StatusChip ada
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                           bool? reload = await Navigator.push(context, 
                                  MaterialPageRoute(builder: (_) => DetailAspirasiScreen(aspirasi: item)));
                                if (reload == true) _fetchData();
                        },
                      ),
                    );
                  },
                ),
            ),
          ],
        ),
      ),
    );
  }
}