import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/warga_service.dart';

class DetailWargaScreen extends StatefulWidget {
  final int wargaId;
  const DetailWargaScreen({super.key, required this.wargaId});

  @override
  State<DetailWargaScreen> createState() => _DetailWargaScreenState();
}

class _DetailWargaScreenState extends State<DetailWargaScreen> {
  final _service = WargaService();
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
      final data = await _service.getWargaById(widget.wargaId);
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

  Future<void> _deleteWarga() async {
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
      final success = await _service.deleteWarga(widget.wargaId);
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

  Widget _statusChip(String status) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'aktif':
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        label = 'Aktif';
        break;
      case 'nonaktif':
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'Non-Aktif';
        break;
      case 'pindah':
        bg = Colors.orange.shade50;
        fg = Colors.orange.shade700;
        label = 'Pindah';
        break;
      case 'meninggal':
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        label = 'Meninggal';
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
        style: TextStyle(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Detail Data Warga",
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
                    await context.push('/edit-warga/${widget.wargaId}');
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteWarga,
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
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _data!['warga_nama'] ?? '',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _statusChip(_data!['warga_status'] ?? 'aktif'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'NIK: ${_data!['warga_nik'] ?? '-'}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Divider(height: 32),
                                _buildInfoRow(
                                  'Tempat, Tanggal Lahir',
                                  '${_data!['warga_tempat_lahir'] ?? '-'}, ${_data!['warga_tanggal_lahir'] ?? '-'}',
                                ),
                                _buildInfoRow(
                                  'Umur',
                                  '${_calculateAge(_data!['warga_tanggal_lahir'])} tahun',
                                ),
                                _buildInfoRow(
                                  'Jenis Kelamin',
                                  _data!['warga_jenis_kelamin'] == 'L'
                                      ? 'Laki-laki'
                                      : 'Perempuan',
                                ),
                                _buildInfoRow(
                                  'Agama',
                                  _data!['warga_agama'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Pendidikan',
                                  _data!['warga_pendidikan'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Pekerjaan',
                                  _data!['warga_pekerjaan'] ?? '-',
                                ),
                                _buildInfoRow(
                                  'Status Perkawinan',
                                  _data!['warga_status_perkawinan'] ?? '-',
                                ),
                                if (_data!['warga_telepon'] != null)
                                  _buildInfoRow(
                                    'Telepon',
                                    _data!['warga_telepon'],
                                  ),
                                if (_data!['warga_email'] != null)
                                  _buildInfoRow(
                                    'Email',
                                    _data!['warga_email'],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_data!['keluarga'] != null)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Keluarga',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'No. KK',
                                    _data!['keluarga']['keluarga_no_kk'] ?? '-',
                                  ),
                                  _buildInfoRow(
                                    'Kepala Keluarga',
                                    _data!['keluarga']['keluarga_nama_kepala'] ??
                                        '-',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (_data!['rumah'] != null)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Informasi Rumah',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Divider(height: 24),
                                  _buildInfoRow(
                                    'Alamat',
                                    _data!['rumah']['rumah_alamat'] ?? '-',
                                  ),
                                  _buildInfoRow(
                                    'RT/RW',
                                    '${_data!['rumah']['rumah_rt'] ?? '-'}/${_data!['rumah']['rumah_rw'] ?? '-'}',
                                  ),
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
