import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/mutasi_warga_service.dart';
import 'package:intl/intl.dart';

class DaftarMutasiWargaScreen extends StatefulWidget {
  const DaftarMutasiWargaScreen({super.key});

  @override
  State<DaftarMutasiWargaScreen> createState() => _DaftarMutasiWargaScreenState();
}

class _DaftarMutasiWargaScreenState extends State<DaftarMutasiWargaScreen> {
  final _service = MutasiWargaService();
  List<dynamic> _mutasi = [];
  List<dynamic> _filteredMutasi = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _selectedStatus = 'semua';
  String _selectedJenis = 'semua';

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
      final data = await _service.getMutasi();
      if (mounted) {
        setState(() {
          _mutasi = data;
          _filteredMutasi = data;
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
      _filteredMutasi = _mutasi.where((m) {
        final searchLower = _searchController.text.toLowerCase();
        final matchSearch = (m['warga']?['warga_nama'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchLower) ||
            (m['mutasi_jenis'] ?? '').toString().toLowerCase().contains(searchLower);

        final matchStatus =
            _selectedStatus == 'semua' || m['mutasi_status'] == _selectedStatus;

        final matchJenis =
            _selectedJenis == 'semua' || m['mutasi_jenis'] == _selectedJenis;

        return matchSearch && matchStatus && matchJenis;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Mutasi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Semua'),
                value: 'semua',
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Pending'),
                value: 'pending',
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Disetujui'),
                value: 'disetujui',
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Ditolak'),
                value: 'ditolak',
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() => _selectedStatus = value!);
                  _filterData();
                },
              ),
              const Divider(),
              const Text('Jenis:', style: TextStyle(fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('Semua'),
                value: 'semua',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Kelahiran'),
                value: 'kelahiran',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Kematian'),
                value: 'kematian',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Pindah Masuk'),
                value: 'pindah_masuk',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Pindah Keluar'),
                value: 'pindah_keluar',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
              RadioListTile<String>(
                title: const Text('Perubahan Status'),
                value: 'perubahan_status',
                groupValue: _selectedJenis,
                onChanged: (value) {
                  setState(() => _selectedJenis = value!);
                  _filterData();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMutasi(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus data mutasi ini?'),
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
      final success = await _service.deleteMutasi(id);
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

  Future<void> _showStatusDialog(int id, String currentStatus) async {
    String? selectedStatus = await showDialog<String>(
      context: context,
      builder: (context) {
        String tempStatus = currentStatus;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Ubah Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('Pending'),
                  value: 'pending',
                  groupValue: tempStatus,
                  onChanged: (value) {
                    setState(() => tempStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Disetujui'),
                  value: 'disetujui',
                  groupValue: tempStatus,
                  onChanged: (value) {
                    setState(() => tempStatus = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Ditolak'),
                  value: 'ditolak',
                  groupValue: tempStatus,
                  onChanged: (value) {
                    setState(() => tempStatus = value!);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, tempStatus),
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedStatus != null && selectedStatus != currentStatus) {
      final success = await _service.updateStatus(id, selectedStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Status berhasil diubah'
                : 'Gagal mengubah status'),
          ),
        );
        if (success) _refresh();
      }
    }
  }

  IconData _getJenisIcon(String jenis) {
    switch (jenis) {
      case 'kelahiran':
        return Icons.child_care;
      case 'kematian':
        return Icons.sentiment_very_dissatisfied;
      case 'pindah_masuk':
        return Icons.login;
      case 'pindah_keluar':
        return Icons.logout;
      case 'perubahan_status':
        return Icons.edit;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'kelahiran':
        return Colors.blue;
      case 'kematian':
        return Colors.grey;
      case 'pindah_masuk':
        return Colors.green;
      case 'pindah_keluar':
        return Colors.orange;
      case 'perubahan_status':
        return Colors.amber;
      default:
        return Colors.deepPurple;
    }
  }

  String _formatJenis(String jenis) {
    switch (jenis) {
      case 'kelahiran':
        return 'Kelahiran';
      case 'kematian':
        return 'Kematian';
      case 'pindah_masuk':
        return 'Pindah Masuk';
      case 'pindah_keluar':
        return 'Pindah Keluar';
      case 'perubahan_status':
        return 'Perubahan Status';
      default:
        return jenis;
    }
  }

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'pending':
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade700;
        label = 'Pending';
        break;
      case 'disetujui':
        bg = Colors.green.shade100;
        fg = Colors.green.shade700;
        label = 'Disetujui';
        break;
      case 'ditolak':
        bg = Colors.red.shade100;
        fg = Colors.red.shade700;
        label = 'Ditolak';
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: fg, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mutasi Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/tambah-mutasi-warga');
                _refresh();
              },
              backgroundColor: Colors.deepPurple,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mutasi'),
            )
          : null,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau jenis mutasi...',
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
                    color: _selectedStatus != 'semua' || _selectedJenis != 'semua'
                        ? Colors.deepPurple
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMutasi.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.swap_horiz,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data mutasi',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              if (canManage) ...[
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await context.push('/tambah-mutasi-warga');
                                    _refresh();
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Tambah Mutasi Pertama'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple,
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
                          itemCount: _filteredMutasi.length,
                          itemBuilder: (context, index) {
                            final m = _filteredMutasi[index];
                            final jenis = m['mutasi_jenis'] ?? '';
                            final status = m['mutasi_status'] ?? 'pending';
                            final tanggal = m['mutasi_tanggal'] ?? '';
                            
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await context.push(
                                      '/detail-mutasi-warga/${m["mutasi_id"]}');
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
                                          color: _getJenisColor(jenis)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _getJenisIcon(jenis),
                                          size: 32,
                                          color: _getJenisColor(jenis),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              m['warga']?['warga_nama'] ?? '-',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _formatJenis(jenis),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today,
                                                    size: 16,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('dd MMM yyyy')
                                                      .format(DateTime.parse(
                                                          tanggal)),
                                                  style: theme.textTheme.bodySmall
                                                      ?.copyWith(
                                                          color: Colors.grey[600]),
                                                ),
                                                const SizedBox(width: 16),
                                                _statusChip(status),
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
                                                  '/edit-mutasi-warga/${m["mutasi_id"]}');
                                              _refresh();
                                            } else if (value == 'delete') {
                                              _deleteMutasi(m["mutasi_id"]);
                                            } else if (value == 'status') {
                                              _showStatusDialog(
                                                  m["mutasi_id"], status);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'status',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.check_circle, size: 20),
                                                  SizedBox(width: 8),
                                                  Text('Ubah Status'),
                                                ],
                                              ),
                                            ),
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
                                                      style: TextStyle(
                                                          color: Colors.red)),
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
