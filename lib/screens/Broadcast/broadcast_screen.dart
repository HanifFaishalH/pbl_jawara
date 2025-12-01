import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/broadcast_service.dart';
import '../../widgets/broadcast/broadcast_filter.dart';
import '../../theme/AppTheme.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final BroadcastService _service = BroadcastService();
  List<Map<String, dynamic>> _broadcastData = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBroadcast();
  }

  Future<void> _loadBroadcast() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await _service.getBroadcastList();
      setState(() {
        _broadcastData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data broadcast: $e")),
        );
      }
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Filter Broadcast"),
        content: const SingleChildScrollView(child: BroadcastFilter()),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Cari"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppTheme.lightTheme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: const Text(
          "Broadcast",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.tertiary,
        onPressed: () => context.push('/tambah-broadcast'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView(colorScheme)
              : _broadcastData.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: _loadBroadcast,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _broadcastData.length,
                        itemBuilder: (context, index) {
                          final item = _broadcastData[index];
                          final judul = item['judul']?.toString() ?? '-';
                          final pengirim = item['admin']?['user_nama_depan']?.toString() ?? '-';
                          final tanggal = item['tanggal_kirim']?.toString() ?? '-';
                          final isi = item['isi_pesan']?.toString() ?? '-';

                          return _buildBroadcastCard(
                            judul: judul,
                            pengirim: pengirim,
                            tanggal: tanggal,
                            isi: isi,
                            onTap: () => context.push('/detail-broadcast', extra: item),
                          );
                        },
                      ),
                    ),
    );
  }

  // 🌈 Desain kartu broadcast modern
  Widget _buildBroadcastCard({
    required String judul,
    required String pengirim,
    required String tanggal,
    required String isi,
    required VoidCallback onTap,
  }) {
    final colorScheme = AppTheme.lightTheme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Text(
                judul,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),

              // Pengirim + tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pengirim,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tanggal,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),
              // Isi pesan
              Text(
                isi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 12),
          const Text("Terjadi kesalahan saat memuat data."),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.tertiary,
              foregroundColor: Colors.white,
            ),
            onPressed: _loadBroadcast,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "Belum ada broadcast.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
