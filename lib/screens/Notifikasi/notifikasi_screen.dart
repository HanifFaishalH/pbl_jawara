import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/notifikasi_service.dart';
import 'package:intl/intl.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final _notifikasiService = NotifikasiService();
  List<dynamic> _notifikasi = [];
  bool _isLoading = true;
  String _filter = 'semua'; // semua, belum_dibaca, sudah_dibaca

  @override
  void initState() {
    super.initState();
    _fetchNotifikasi();
  }

  Future<void> _fetchNotifikasi() async {
    setState(() => _isLoading = true);
    try {
      List<dynamic> data;
      if (_filter == 'belum_dibaca') {
        data = await _notifikasiService.getNotifikasi(isRead: false);
      } else if (_filter == 'sudah_dibaca') {
        data = await _notifikasiService.getNotifikasi(isRead: true);
      } else {
        data = await _notifikasiService.getNotifikasi();
      }
      
      if (mounted) {
        setState(() {
          _notifikasi = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead(int id, int index) async {
    final success = await _notifikasiService.markAsRead(id);
    if (success && mounted) {
      setState(() {
        _notifikasi[index]['is_read'] = true;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _notifikasiService.markAllAsRead();
    if (success && mounted) {
      _fetchNotifikasi();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sebagai sudah dibaca')),
      );
    }
  }

  Future<void> _deleteNotifikasi(int id) async {
    final success = await _notifikasiService.deleteNotifikasi(id);
    if (success && mounted) {
      _fetchNotifikasi();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi berhasil dihapus')),
      );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        if (diff.inHours == 0) {
          if (diff.inMinutes == 0) {
            return 'Baru saja';
          }
          return '${diff.inMinutes} menit yang lalu';
        }
        return '${diff.inHours} jam yang lalu';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} hari yang lalu';
      }
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        title: Text(
          'Notifikasi',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'mark_all') {
                _markAllAsRead();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, size: 20),
                    SizedBox(width: 8),
                    Text('Tandai semua sudah dibaca'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Semua', 'semua'),
                _buildFilterChip('Belum Dibaca', 'belum_dibaca'),
                _buildFilterChip('Sudah Dibaca', 'sudah_dibaca'),
              ],
            ),
          ),

          // List Notifikasi
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchNotifikasi,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _notifikasi.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada notifikasi',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _notifikasi.length,
                          itemBuilder: (context, index) {
                            final notif = _notifikasi[index];
                            final isRead = notif['is_read'] == true || notif['is_read'] == 1;
                            final type = notif['notifikasi_tipe'];
                            final typeColor = _getTypeColor(type);

                            return Dismissible(
                              key: Key(notif['notifikasi_id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) {
                                _deleteNotifikasi(notif['notifikasi_id']);
                              },
                              child: Card(
                                elevation: isRead ? 1 : 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isRead
                                        ? Colors.transparent
                                        : colorScheme.primary.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (!isRead) {
                                      _markAsRead(notif['notifikasi_id'], index);
                                    }
                                    // Navigate jika ada link
                                    if (notif['notifikasi_link'] != null) {
                                      context.push(notif['notifikasi_link']);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Icon
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: typeColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getTypeIcon(type),
                                            color: typeColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      notif['notifikasi_judul'] ?? '',
                                                      style: theme.textTheme.titleSmall?.copyWith(
                                                        fontWeight: isRead
                                                            ? FontWeight.w600
                                                            : FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!isRead)
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: colorScheme.primary,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                notif['notifikasi_pesan'] ?? '',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _formatDate(notif['created_at']),
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : colorScheme.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _filter = value;
              _fetchNotifikasi();
            });
          },
          backgroundColor: Colors.white,
          selectedColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected ? colorScheme.primary : colorScheme.primary.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
