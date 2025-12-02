import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/activity_log_service.dart';
import 'package:intl/intl.dart';

class DetailActivityLogScreen extends StatefulWidget {
  final String logId;

  const DetailActivityLogScreen({super.key, required this.logId});

  @override
  State<DetailActivityLogScreen> createState() =>
      _DetailActivityLogScreenState();
}

class _DetailActivityLogScreenState extends State<DetailActivityLogScreen> {
  final _service = ActivityLogService();
  Map<String, dynamic>? _log;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getLogDetail(int.parse(widget.logId));
      if (mounted) {
        setState(() {
          _log = data;
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

  Widget _buildInfoCard(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.indigo, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value?.toString() ?? '-',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Log Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _log == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: _getActionColor(
                                          _log!['log_action'] ?? '')
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _log!['log_action'] == 'create'
                                      ? Icons.add_circle
                                      : _log!['log_action'] == 'update'
                                          ? Icons.edit
                                          : _log!['log_action'] == 'delete'
                                              ? Icons.delete
                                              : _log!['log_action'] == 'approve'
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                  size: 40,
                                  color: _getActionColor(
                                      _log!['log_action'] ?? ''),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _log!['log_description'] ?? '-',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatType(_log!['log_type'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _getActionColor(
                                              _log!['log_action'] ?? '')
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _formatAction(_log!['log_action'] ?? ''),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getActionColor(
                                            _log!['log_action'] ?? ''),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Informasi',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        'User',
                        '${_log!['user']?['user_nama_depan'] ?? 'System'} ${_log!['user']?['user_nama_belakang'] ?? ''}',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        'Email',
                        _log!['user']?['email'] ?? '-',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        'Waktu',
                        DateFormat('dd MMMM yyyy, HH:mm:ss')
                            .format(DateTime.parse(_log!['created_at'])),
                        icon: Icons.access_time,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        'IP Address',
                        _log!['log_ip_address'] ?? '-',
                        icon: Icons.computer,
                      ),
                      const SizedBox(height: 20),
                      if (_log!['log_old_data'] != null) ...[
                        _buildDataSection(
                            'Data Sebelumnya', _log!['log_old_data']),
                        const SizedBox(height: 20),
                      ],
                      if (_log!['log_new_data'] != null) ...[
                        _buildDataSection('Data Baru', _log!['log_new_data']),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
    );
  }
}
