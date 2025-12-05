import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/activity_log_service.dart';
import 'package:intl/intl.dart';

class DaftarActivityLogScreen extends StatefulWidget {
  const DaftarActivityLogScreen({super.key});

  @override
  State<DaftarActivityLogScreen> createState() =>
      _DaftarActivityLogScreenState();
}

class _DaftarActivityLogScreenState extends State<DaftarActivityLogScreen> {
  final _service = ActivityLogService();
  List<dynamic> _logs = [];
  List<dynamic> _filteredLogs = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _selectedType = 'semua';
  String _selectedAction = 'semua';

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
      final data = await _service.getLogs();
      if (mounted) {
        setState(() {
          _logs = data;
          _filteredLogs = data;
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
      _filteredLogs = _logs.where((log) {
        final searchLower = _searchController.text.toLowerCase();
        final matchSearch = (log['log_description'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchLower) ||
            ('${log['user']?['user_nama_depan'] ?? ''} ${log['user']?['user_nama_belakang'] ?? ''}')
                .toString()
                .toLowerCase()
                .contains(searchLower);

        final matchType =
            _selectedType == 'semua' || log['log_type'] == _selectedType;

        final matchAction =
            _selectedAction == 'semua' || log['log_action'] == _selectedAction;

        return matchSearch && matchType && matchAction;
      }).toList();
    });
  }

  void _showFilterDialog() {
    String tempType = _selectedType;
    String tempAction = _selectedAction;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Log Activity'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipe:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                RadioListTile<String>(
                  title: const Text('Semua'),
                  value: 'semua',
                  groupValue: tempType,
                  onChanged: (value) {
                    setDialogState(() => tempType = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Data Warga'),
                  value: 'warga',
                  groupValue: tempType,
                  onChanged: (value) {
                    setDialogState(() => tempType = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Channel Transfer'),
                  value: 'channel',
                  groupValue: tempType,
                  onChanged: (value) {
                    setDialogState(() => tempType = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Mutasi Warga'),
                  value: 'mutasi_warga',
                  groupValue: tempType,
                  onChanged: (value) {
                    setDialogState(() => tempType = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Mutasi Keluarga'),
                  value: 'mutasi_keluarga',
                  groupValue: tempType,
                  onChanged: (value) {
                    setDialogState(() => tempType = value!);
                  },
                ),
                const Divider(),
                const Text('Aksi:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                RadioListTile<String>(
                  title: const Text('Semua'),
                  value: 'semua',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Tambah'),
                  value: 'create',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Ubah'),
                  value: 'update',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Hapus'),
                  value: 'delete',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Setujui'),
                  value: 'approve',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Tolak'),
                  value: 'reject',
                  groupValue: tempAction,
                  onChanged: (value) {
                    setDialogState(() => tempAction = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedType = tempType;
                  _selectedAction = tempAction;
                });
                _filterData();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'create':
        return Icons.add_circle;
      case 'update':
        return Icons.edit;
      case 'delete':
        return Icons.delete;
      case 'approve':
        return Icons.check_circle;
      case 'reject':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'create':
        return Colors.green;
      case 'update':
        return Colors.blue;
      case 'delete':
        return Colors.red;
      case 'approve':
        return Colors.teal;
      case 'reject':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatType(String type) {
    switch (type) {
      case 'warga':
        return 'Data Warga';
      case 'channel':
        return 'Channel Transfer';
      case 'mutasi_warga':
        return 'Mutasi Warga';
      case 'mutasi_keluarga':
        return 'Mutasi Keluarga';
      default:
        return type;
    }
  }

  String _formatAction(String action) {
    switch (action) {
      case 'create':
        return 'Tambah';
      case 'update':
        return 'Ubah';
      case 'delete':
        return 'Hapus';
      case 'approve':
        return 'Setujui';
      case 'reject':
        return 'Tolak';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Log Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                      hintText: 'Cari aktivitas atau user...',
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
                    color: _selectedType != 'semua' ||
                            _selectedAction != 'semua'
                        ? theme.colorScheme.primary
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
                  : _filteredLogs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history,
                                  size: 80, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada log activity',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredLogs.length,
                          itemBuilder: (context, index) {
                            final log = _filteredLogs[index];
                            final action = log['log_action'] ?? '';
                            final type = log['log_type'] ?? '';
                            final createdAt = log['created_at'] ?? '';

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  await context.push(
                                      '/detail-activity-log/${log["log_id"]}');
                                  _refresh();
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: _getActionColor(action)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          _getActionIcon(action),
                                          size: 28,
                                          color: _getActionColor(action),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              log['log_description'] ?? '-',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    _formatType(type),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          Colors.blue.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: _getActionColor(
                                                            action)
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    _formatAction(action),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color:
                                                          _getActionColor(
                                                              action),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.person,
                                                    size: 14,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${log['user']?['user_nama_depan'] ?? 'System'} ${log['user']?['user_nama_belakang'] ?? ''}',
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color:
                                                              Colors.grey[600]),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('dd MMM yyyy HH:mm')
                                                      .format(DateTime.parse(
                                                          createdAt)),
                                                  style: theme
                                                      .textTheme.bodySmall
                                                      ?.copyWith(
                                                          color:
                                                              Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: Colors.grey[400]),
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
