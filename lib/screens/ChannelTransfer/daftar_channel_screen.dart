// lib/screens/ChannelTransfer/daftar_channel_screen.dart
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/auth_service.dart';
import 'package:jawaramobile_1/services/channel_transfer_service.dart';

class DaftarChannelScreen extends StatefulWidget {
  const DaftarChannelScreen({super.key});

  @override
  State<DaftarChannelScreen> createState() => _DaftarChannelScreenState();
}

class _DaftarChannelScreenState extends State<DaftarChannelScreen> {
  final _service = ChannelTransferService();
  List<dynamic> _rows = [];
  bool _loading = true;

  bool get canManage {
    final allowedRoles = [1, 2, 3];
    return allowedRoles.contains(AuthService.currentRoleId);
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final data = await _service.getChannels();
      if (mounted) {
        setState(() {
          _rows = data;
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

  Future<void> _deleteChannel(int id) async {
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _service.deleteChannel(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Channel berhasil dihapus' : 'Gagal menghapus'),
          ),
        );
        if (success) _refresh();
      }
    }
  }

  Widget _typeChip(BuildContext context, String t) {
    final cs = Theme.of(context).colorScheme;
    // warna mengikuti theme
    Color bg;
    Color fg;
    switch (t) {
      case 'bank':
        bg = cs.primary.withOpacity(.12);
        fg = cs.primary;
        break;
      case 'ewallet':
        bg = cs.secondary.withOpacity(.35);
        fg = cs.onSecondary;
        break;
      case 'qris':
        bg = Colors.white;
        fg = cs.primary;
        break;
      default:
        bg = cs.surfaceVariant;
        fg = cs.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        t,
        style: TextStyle(fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          "Channel Transfer",
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              icon: const Icon(Icons.add_link),
              label: const Text("Tambah Channel"),
              onPressed: () async {
                await context.push('/tambah-channel');
                _refresh();
              },
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: colorScheme.primary,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _rows.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada channel transfer',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: DataTable2(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        headingRowColor: MaterialStateProperty.all(
                          theme.colorScheme.primary.withOpacity(0.1),
                        ),
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                        columns: const [
                          DataColumn2(label: Text('Nama Channel')),
                          DataColumn2(label: Text('Tipe')),
                          DataColumn2(label: Text('Aksi'), fixedWidth: 100),
                        ],
                        rows: _rows.map((r) {
                          return DataRow2(
                            onTap: () async {
                              await context.push('/detail-channel/${r['channel_id']}');
                              _refresh();
                            },
                            cells: [
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      r['channel_nama'] ?? '',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "A/N ${r['channel_pemilik'] ?? ''}",
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(.7),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(_typeChip(context, r['channel_tipe'] ?? '')),
                              DataCell(
                                canManage
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 20),
                                            onPressed: () async {
                                              await context.push(
                                                  '/edit-channel/${r['channel_id']}');
                                              _refresh();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            onPressed: () =>
                                                _deleteChannel(r['channel_id']),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
      ),
    );
  }
}
