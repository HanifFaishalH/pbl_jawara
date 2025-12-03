import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/keluarga_service.dart';

class TabelKeluarga extends StatefulWidget {
  const TabelKeluarga({super.key});

  @override
  State<TabelKeluarga> createState() => _TabelKeluargaState();
}

class _TabelKeluargaState extends State<TabelKeluarga> {
  final _service = KeluargaService();
  List<dynamic> _keluarga = [];
  List<dynamic> _filteredKeluarga = [];
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
      final data = await _service.getKeluarga();
      if (mounted) {
        setState(() {
          _keluarga = data;
          _filteredKeluarga = data;
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
      _filteredKeluarga = _keluarga.where((k) {
        // Filter by search
        final searchLower = _searchController.text.toLowerCase();
        final matchSearch = k['keluarga_nama_kepala']
                .toString()
                .toLowerCase()
                .contains(searchLower) ||
            k['keluarga_no_kk'].toString().toLowerCase().contains(searchLower) ||
            (k['keluarga_alamat'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchLower);

        // Filter by status
        final matchStatus = _selectedStatus == 'semua' ||
            k['keluarga_status'] == _selectedStatus;

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
          ],
        ),
      ),
    );
  }

  Future<void> _deleteKeluarga(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus data keluarga ini?'),
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
      final success = await _service.deleteKeluarga(id);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/tambah-keluarga');
                _refresh();
              },
              backgroundColor: colorScheme.secondary,
              icon: const Icon(Icons.family_restroom),
              label: const Text('Tambah Keluarga'),
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
                      hintText: 'Cari nama kepala, No. KK, atau alamat...',
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
                        ? colorScheme.secondary
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
                  : _filteredKeluarga.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.family_restroom,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data keluarga',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        if (canManage) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await context.push('/tambah-keluarga');
                              _refresh();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Keluarga Pertama'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
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
                      itemCount: _filteredKeluarga.length,
                      itemBuilder: (context, index) {
                        final k = _filteredKeluarga[index];
                    final jumlahAnggota =
                        k['warga'] != null ? (k['warga'] as List).length : 0;
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () async {
                          await context
                              .push('/detail-keluarga/${k["keluarga_id"]}');
                          _refresh();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.family_restroom,
                                  size: 32,
                                  color: colorScheme.secondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      k["keluarga_nama_kepala"] ?? '',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'No. KK: ${k["keluarga_no_kk"] ?? '-'}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.people,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$jumlahAnggota anggota',
                                          style:
                                              theme.textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.location_on,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            k["keluarga_alamat"] ?? '',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 1,
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
                                      await context.push(
                                          '/edit-keluarga/${k["keluarga_id"]}');
                                      _refresh();
                                    } else if (value == 'delete') {
                                      _deleteKeluarga(k["keluarga_id"]);
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
