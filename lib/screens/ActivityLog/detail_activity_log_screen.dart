import 'dart:convert';
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

  Widget _buildInfoCard(BuildContext context, String label, String value, {IconData? icon}) {
    final theme = Theme.of(context);
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
            Icon(icon, color: theme.colorScheme.primary, size: 24),
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

  String _formatFieldName(String fieldName) {
    // Mapping field names ke label yang lebih user-friendly
    final Map<String, String> fieldLabels = {
      // Warga fields
      'warga_id': 'ID Warga',
      'warga_nama': 'Nama Warga',
      'warga_nik': 'NIK',
      'warga_tanggal_lahir': 'Tanggal Lahir',
      'warga_tempat_lahir': 'Tempat Lahir',
      'warga_jenis_kelamin': 'Jenis Kelamin',
      'warga_agama': 'Agama',
      'warga_pendidikan': 'Pendidikan',
      'warga_pekerjaan': 'Pekerjaan',
      'warga_status_perkawinan': 'Status Perkawinan',
      'warga_golongan_darah': 'Golongan Darah',
      'warga_telepon': 'Telepon',
      'warga_email': 'Email',
      'warga_status': 'Status',
      'keluarga_id': 'ID Keluarga',
      'rumah_id': 'ID Rumah',
      
      // Mutasi fields
      'mutasi_id': 'ID Mutasi',
      'mutasi_jenis': 'Jenis Mutasi',
      'mutasi_status': 'Status Mutasi',
      'mutasi_dokumen': 'Dokumen',
      'mutasi_tanggal': 'Tanggal Mutasi',
      'mutasi_keterangan': 'Keterangan',
      'mutasi_alamat_asal': 'Alamat Asal',
      'mutasi_alamat_tujuan': 'Alamat Tujuan',
      
      // Channel fields
      'channel_id': 'ID Channel',
      'channel_nama': 'Nama Channel',
      'channel_tipe': 'Tipe Channel',
      'channel_nomor': 'Nomor Rekening/Akun',
      'channel_pemilik': 'Nama Pemilik',
      'channel_status': 'Status Channel',
      'channel_catatan': 'Catatan',
      'channel_qr': 'QR Code',
      'channel_thumbnail': 'Thumbnail',
      
      // Common fields
      'created_at': 'Dibuat Pada',
      'updated_at': 'Diperbarui Pada',
      'user_id': 'ID User',
    };

    return fieldLabels[fieldName] ?? _formatCamelCase(fieldName);
  }

  String _formatCamelCase(String text) {
    // Convert snake_case to Title Case
    return text
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatFieldValue(String key, dynamic value) {
    if (value == null) return '-';
    
    // Format specific field types
    if (key.contains('tanggal') || key.contains('date')) {
      try {
        final date = DateTime.parse(value.toString());
        return DateFormat('dd MMMM yyyy').format(date);
      } catch (e) {
        return value.toString();
      }
    }
    
    if (key.contains('created_at') || key.contains('updated_at')) {
      try {
        final date = DateTime.parse(value.toString());
        return DateFormat('dd MMM yyyy, HH:mm').format(date);
      } catch (e) {
        return value.toString();
      }
    }
    
    // Format jenis kelamin
    if (key == 'warga_jenis_kelamin') {
      return value.toString() == 'L' ? 'Laki-laki' : 'Perempuan';
    }
    
    // Format status
    if (key.contains('status')) {
      final statusMap = {
        'aktif': 'Aktif',
        'nonaktif': 'Non-Aktif',
        'pending': 'Pending',
        'disetujui': 'Disetujui',
        'ditolak': 'Ditolak',
      };
      return statusMap[value.toString().toLowerCase()] ?? value.toString();
    }
    
    // Format jenis mutasi
    if (key == 'mutasi_jenis') {
      final jenisMap = {
        'kelahiran': 'Kelahiran',
        'kematian': 'Kematian',
        'pindah_masuk': 'Pindah Masuk',
        'pindah_keluar': 'Pindah Keluar',
        'perubahan_status': 'Perubahan Status',
        'pindah_rumah': 'Pindah Rumah',
        'keluar_wilayah': 'Keluar Wilayah',
        'masuk_wilayah': 'Masuk Wilayah',
        'pindah_rt_rw': 'Pindah RT/RW',
      };
      return jenisMap[value.toString()] ?? value.toString();
    }
    
    // Format channel tipe
    if (key == 'channel_tipe') {
      final tipeMap = {
        'bank': 'Bank',
        'ewallet': 'E-Wallet',
        'qris': 'QRIS',
      };
      return tipeMap[value.toString()] ?? value.toString();
    }
    
    return value.toString();
  }

  Map<String, dynamic>? _parseData(dynamic data) {
    if (data == null) return null;
    
    // Jika sudah Map, return langsung
    if (data is Map<String, dynamic>) {
      return data;
    }
    
    // Jika String, coba parse sebagai JSON
    if (data is String) {
      try {
        final parsed = json.decode(data);
        if (parsed is Map<String, dynamic>) {
          return parsed;
        }
      } catch (e) {
        // Jika gagal parse, return null
        return null;
      }
    }
    
    return null;
  }

  List<String> _fieldsToExclude = [
    'created_at',
    'updated_at',
    'deleted_at',
  ];

  Widget _buildDataSection(String title, dynamic rawData) {
    final data = _parseData(rawData);
    
    if (data == null || data.isEmpty) return const SizedBox();

    // Filter out fields yang tidak perlu ditampilkan
    final filteredData = Map<String, dynamic>.from(data)
      ..removeWhere((key, value) => _fieldsToExclude.contains(key));

    if (filteredData.isEmpty) return const SizedBox();

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
            children: filteredData.entries.map((entry) {
              // Skip jika value adalah object/map yang kompleks
              if (entry.value is Map || entry.value is List) {
                return const SizedBox.shrink();
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatFieldName(entry.key),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatFieldValue(entry.key, entry.value),
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
        backgroundColor: theme.colorScheme.primary,
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
                        context,
                        'User',
                        '${_log!['user']?['user_nama_depan'] ?? 'System'} ${_log!['user']?['user_nama_belakang'] ?? ''}',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        context,
                        'Email',
                        _log!['user']?['email'] ?? '-',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        context,
                        'Waktu',
                        DateFormat('dd MMMM yyyy, HH:mm:ss')
                            .format(DateTime.parse(_log!['created_at'])),
                        icon: Icons.access_time,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoCard(
                        context,
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
