import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/mutasi_warga_service.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:intl/intl.dart';

class DetailMutasiWargaScreen extends StatefulWidget {
  final int mutasiId;

  const DetailMutasiWargaScreen({super.key, required this.mutasiId});

  @override
  State<DetailMutasiWargaScreen> createState() =>
      _DetailMutasiWargaScreenState();
}

class _DetailMutasiWargaScreenState extends State<DetailMutasiWargaScreen> {
  final _service = MutasiWargaService();
  Map<String, dynamic>? _mutasi;
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
      final data = await _service.getMutasiById(widget.mutasiId);
      if (mounted) {
        setState(() {
          _mutasi = data;
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

  Future<void> _deleteMutasi() async {
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
      final success = await _service.deleteMutasi(widget.mutasiId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menghapus data')),
          );
        }
      }
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
        return const Color(0xFF26547C); // theme primary color
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: fg, fontSize: 14),
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
          'Detail Mutasi Warga',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: canManage
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await context.push('/edit-mutasi-warga/${widget.mutasiId}');
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteMutasi,
                ),
              ]
            : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _mutasi == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(),
                        const SizedBox(height: 16),
                        _buildDetailCard(),
                        const SizedBox(height: 16),
                        _buildWargaCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeaderCard() {
    final jenis = _mutasi!['mutasi_jenis'] ?? '';
    final status = _mutasi!['mutasi_status'] ?? 'pending';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getJenisColor(jenis).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getJenisIcon(jenis),
                size: 40,
                color: _getJenisColor(jenis),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _mutasi!['warga']?['warga_nama'] ?? '-',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatJenis(jenis),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _statusChip(status),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    final tanggal = _mutasi!['mutasi_tanggal'] ?? '';
    final jenis = _mutasi!['mutasi_jenis'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Mutasi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal',
              value: DateFormat('dd MMMM yyyy').format(DateTime.parse(tanggal)),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.description,
              label: 'Keterangan',
              value: _mutasi!['mutasi_keterangan'] ?? '-',
            ),
            if (['pindah_masuk', 'pindah_keluar'].contains(jenis)) ...[
              if (_mutasi!['mutasi_alamat_asal'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Alamat Asal',
                  value: _mutasi!['mutasi_alamat_asal'],
                ),
              ],
              if (_mutasi!['mutasi_alamat_tujuan'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'Alamat Tujuan',
                  value: _mutasi!['mutasi_alamat_tujuan'],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWargaCard() {
    final warga = _mutasi!['warga'];
    if (warga == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          context.push('/detail-warga/${warga['warga_id']}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Informasi Warga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
                ],
              ),
              const Divider(height: 24),
              _buildInfoRow(
                icon: Icons.badge,
                label: 'NIK',
                value: warga['warga_nik'] ?? '-',
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.person,
                label: 'Nama',
                value: warga['warga_nama'] ?? '-',
              ),
              if (warga['warga_tempat_lahir'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.place,
                  label: 'Tempat Lahir',
                  value: warga['warga_tempat_lahir'],
                ),
              ],
              if (warga['warga_jenis_kelamin'] != null) ...[
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.wc,
                  label: 'Jenis Kelamin',
                  value: warga['warga_jenis_kelamin'] == 'L'
                      ? 'Laki-laki'
                      : 'Perempuan',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
