import 'package:flutter/material.dart';
import 'package:jawaramobile_1/widgets/pesanWarga/pesan_input.dart';
import 'package:jawaramobile_1/widgets/pesanWarga/pesan_tile.dart';
import '../../models/pesan_warga.dart';
import '../../services/pesan_warga_service.dart';

class PesanWargaScreen extends StatefulWidget {
  const PesanWargaScreen({super.key});

  @override
  State<PesanWargaScreen> createState() => _PesanWargaScreenState();
}

class _PesanWargaScreenState extends State<PesanWargaScreen> {
  final PesanWargaService _service = PesanWargaService();
  List<PesanWarga> _pesanList = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPesan();
  }

  Future<void> _loadPesan() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final pesan = await _service.getPesanWarga();
      setState(() {
        _pesanList = pesan;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat pesan warga: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: const Text('Pesan Warga', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorView()
              : _pesanList.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: _loadPesan,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _pesanList.length,
                        itemBuilder: (context, index) {
                          final pesan = _pesanList[index];
                          return PesanTile(pesan: pesan);
                        },
                      ),
                    ),
      bottomNavigationBar: PesanInput(onSend: _loadPesan),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text("Terjadi kesalahan saat memuat pesan warga."),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadPesan,
            child: const Text("Coba Lagi"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        "Belum ada pesan dari warga.",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
