import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/rumah_service.dart';

class DetailRumahScreen extends StatefulWidget {
  final int rumahId;
  const DetailRumahScreen({super.key, required this.rumahId});

  @override
  State<DetailRumahScreen> createState() => _DetailRumahScreenState();
}

class _DetailRumahScreenState extends State<DetailRumahScreen> {
  final _service = RumahService();
  Map<String, dynamic>? _data;
  bool _loading = true;

  bool get canManage {
    final allowedRoles = [1, 2, 3];
    return allowedRoles.contains(AuthService.currentRoleId);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getRumahById(widget.rumahId);
      if (mounted) {
        setState(() {
          _data = data;
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

  Future<void> _deleteRumah() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus data rumah ini?'),
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
      final success = await _service.deleteRumah(widget.rumahId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Data berhasil dihapus' : 'Gagal menghapus'),
          ),
        );
        if (success) context.pop();
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatusKepemilikan(String status) {
    switch (status) {
      case 'milik_sendiri':
        return 'Milik Sendiri';
      case 'kontrak':
        return 'Kontrak';
      case 'sewa':
        return 'Sewa';
      case 'lainnya':
        return 'Lainnya';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Detail Data Rumah",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: canManage
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.push('/edit-rumah/${widget.rumahId}');
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteRumah,
                ),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _data!['rumah_alamat'] ?? '',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'RT ${_data!['rumah_rt'] ?? '-'} / RW ${_data!['rumah_rw'] ?? '-'}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Divider(height: 32),
                                _buildInfoRow(
                                  'Kelurahan',
                                  _data!['rumah_kelurahan'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Kecamatan',
                                  _data!['rumah_kecamatan'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Kota',
                                  _data!['rumah_kota'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Provinsi',
                                  _data!['rumah_provinsi'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Kode Pos',
                                  _data!['rumah_kode_pos'] ?? '-',
                                ),
                                const Divider(height: 32),
                                _buildInfoRow(
                                  'Luas Tanah',
                                  '${_data!['rumah_luas_tanah'] ?? '-'} m²',
                                ),
                                _buildInfoRow(
                                  'Luas Bangunan',
                                  '${_data!['rumah_luas_bangunan'] ?? '-'} m²',
                                ),
                                _buildInfoRow(
                                  'Status Kepemilikan',
                                  _formatStatusKepemilikan(
                                      _data!['rumah_status_kepemilikan'] ?? ''),
                                ),
                                _buildInfoRow(
                                  'Jumlah Penghuni',
                                  '${_data!['rumah_jumlah_penghuni'] ?? 0} orang',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_data!['keluarga'] != null &&
                            (_data!['keluarga'] as List).isNotEmpty)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Keluarga yang Tinggal',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  ...(_data!['keluarga'] as List).map((k) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: colorScheme.secondary,
                                        child: const Icon(Icons.family_restroom,
                                            color: Colors.white),
                                      ),
                                      title: Text(k['keluarga_nama_kepala'] ?? ''),
                                      subtitle: Text('No. KK: ${k['keluarga_no_kk'] ?? '-'}'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        context.push('/detail-keluarga/${k['keluarga_id']}');
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (_data!['warga'] != null &&
                            (_data!['warga'] as List).isNotEmpty)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penghuni',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  ...(_data!['warga'] as List).map((w) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: colorScheme.primary,
                                        child: Text(
                                          w['warga_nama'][0].toUpperCase(),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(w['warga_nama'] ?? ''),
                                      subtitle: Text(w['warga_pekerjaan'] ?? '-'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () {
                                        context.push('/detail-warga/${w['warga_id']}');
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
