import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/warga_service.dart';

class TabelWarga extends StatefulWidget {
  const TabelWarga({super.key});

  @override
  State<TabelWarga> createState() => _TabelWargaState();
}

class _TabelWargaState extends State<TabelWarga> {
  final _service = WargaService();
  List<dynamic> _warga = [];
  List<dynamic> _filteredWarga = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _selectedStatus = 'semua';

  bool get canManage {
    final allowedRoles = [1, 2, 3];
    return allowedRoles.contains(AuthService.currentRoleId);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final data = await _service.getWarga();
      if (mounted) {
        setState(() {
          _warga = data;
          _filteredWarga = data;
          _loading = false;
        });
        _filterData();
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

  void _filterData() {
    setState(() {
      _filteredWarga = _warga.where((w) {
        // Filter by search
        final searchLower = _searchController.text.toLowerCase();
        final matchSearch = w['warga_nama']
                .toString()
                .toLowerCase()
                .contains(searchLower) ||
            w['warga_nik'].toString().toLowerCase().contains(searchLower) ||
            (w['warga_pekerjaan'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchLower);

        // Filter by status
        final matchStatus = _selectedStatus == 'semua' ||
            w['warga_status'] == _selectedStatus;

        return matchSearch && matchStatus;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Semua'),
              value: 'semua',
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _filterData();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Aktif'),
              value: 'aktif',
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _filterData();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Non-Aktif'),
              value: 'nonaktif',
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _filterData();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pindah'),
              value: 'pindah',
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _filterData();
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Meninggal'),
              value: 'meninggal',
              groupValue: _selectedStatus,
              onChanged: (value) {
                setState(() => _selectedStatus = value!);
                _filterData();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWarga(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus data warga ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteWarga(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Data berhasil dihapus' : 'Gagal menghapus'),
          ),
        );
        if (success) _refresh();
      }
    }
  }

  int _calculateAge(String? tanggalLahir) {
    if (tanggalLahir == null) return 0;
    try {
      final birthDate = DateTime.parse(tanggalLahir);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/tambah-warga');
                _refresh();
              },
              backgroundColor: colorScheme.primary,
              icon: const Icon(Icons.person_add),
              label: const Text('Tambah Warga'),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, NIK, atau pekerjaan...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: _selectedStatus != 'semua'
                        ? colorScheme.primary
                        : Colors.grey,
                  ),
                  onPressed: _showFilterDialog,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredWarga.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data warga',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        if (canManage) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/tambah-warga');
                              _refresh();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Warga Pertama'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredWarga.length,
                      itemBuilder: (context, index) {
                        final w = _filteredWarga[index];
                      final umur = _calculateAge(w["warga_tanggal_lahir"]);
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () async {
                            await context.push('/detail-warga/${w["warga_id"]}');
                            _refresh();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: colorScheme.primary,
                                  child: Text(
                                    w["warga_nama"][0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        w["warga_nama"] ?? '',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        w["warga_pekerjaan"] ?? '-',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.cake,
                                              size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$umur tahun',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(Icons.badge,
                                              size: 16, color: Colors.grey[600]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              w["warga_nik"] ?? '',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(color: Colors.grey[600]),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (canManage)
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        await context
                                            .push('/edit-warga/${w["warga_id"]}');
                                        _refresh();
                                      } else if (value == 'delete') {
                                        _deleteWarga(w["warga_id"]);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Hapus',
                                                style: TextStyle(color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
