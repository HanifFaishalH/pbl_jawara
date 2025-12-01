import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/channel_transfer_service.dart';

class DetailChannelScreen extends StatefulWidget {
  final int channelId;
  const DetailChannelScreen({super.key, required this.channelId});

  @override
  State<DetailChannelScreen> createState() => _DetailChannelScreenState();
}

class _DetailChannelScreenState extends State<DetailChannelScreen> {
  final _service = ChannelTransferService();
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
      final data = await _service.getChannelById(widget.channelId);
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

  Future<void> _deleteChannel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menghapus channel ini?'),
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
      final success = await _service.deleteChannel(widget.channelId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Channel berhasil dihapus' : 'Gagal menghapus'),
          ),
        );
        if (success) context.pop();
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disalin ke clipboard')),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                if (canCopy)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyToClipboard(value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(String? imagePath, String label) {
    if (imagePath == null) return const SizedBox();
    
    final imageUrl = '${AuthService.baseUrl}/image-proxy/$imagePath';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _typeChip(String type) {
    Color bg;
    Color fg;
    String label;
    
    switch (type) {
      case 'bank':
        bg = Theme.of(context).colorScheme.primary.withOpacity(.12);
        fg = Theme.of(context).colorScheme.primary;
        label = 'Bank';
        break;
      case 'ewallet':
        bg = Theme.of(context).colorScheme.secondary.withOpacity(.35);
        fg = Theme.of(context).colorScheme.onSecondary;
        label = 'E-Wallet';
        break;
      case 'qris':
        bg = Colors.white;
        fg = Theme.of(context).colorScheme.primary;
        label = 'QRIS';
        break;
      default:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade800;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _statusChip(String status) {
    final isActive = status == 'aktif';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Non-Aktif',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
        ),
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
          "Detail Channel Transfer",
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
                    await context.push('/edit-channel/${widget.channelId}');
                    _loadData();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteChannel,
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
                                        _data!['channel_nama'] ?? '',
                                        style: theme.textTheme.headlineSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    _statusChip(_data!['channel_status'] ?? 'aktif'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _typeChip(_data!['channel_tipe'] ?? ''),
                                const Divider(height: 32),
                                _buildInfoRow(
                                  'Nomor Rekening',
                                  _data!['channel_nomor'] ?? '',
                                  canCopy: true,
                                ),
                                _buildInfoRow(
                                  'Nama Pemilik',
                                  _data!['channel_pemilik'] ?? '',
                                  canCopy: true,
                                ),
                                if (_data!['channel_catatan'] != null &&
                                    _data!['channel_catatan'].toString().isNotEmpty)
                                  _buildInfoRow(
                                    'Catatan',
                                    _data!['channel_catatan'],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_data!['channel_qr'] != null)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildImageSection(
                                _data!['channel_qr'],
                                'QR Code',
                              ),
                            ),
                          ),
                        if (_data!['channel_thumbnail'] != null)
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: _buildImageSection(
                                _data!['channel_thumbnail'],
                                'Thumbnail',
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
