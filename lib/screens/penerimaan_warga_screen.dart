import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/AppTheme.dart';
import '../services/man_pengguna_service.dart';
import '../models/pengguna_model.dart';

class PenerimaanWargaScreen extends StatefulWidget {
  const PenerimaanWargaScreen({super.key});

  @override
  State<PenerimaanWargaScreen> createState() => _PenerimaanWargaScreenState();
}

class _PenerimaanWargaScreenState extends State<PenerimaanWargaScreen> {
  final PenggunaService _service = PenggunaService();
  List<PenggunaModel> _allUsers = [];
  bool _loading = true;
  String? _error;

  String? _filterNama;
  String? _filterJenisKelamin;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await _service.getPengguna();
      final pending = users.where((u) => (u.status).toLowerCase() == 'pending').toList();
      setState(() {
        _allUsers = pending;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data';
        _loading = false;
      });
    }
  }

  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? currentNama = _filterNama;
        String? currentJK = _filterJenisKelamin;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final maxH = MediaQuery.of(context).size.height * 0.7;
            final maxW = MediaQuery.of(context).size.width * 0.9;
            return AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Filter Penerimaan Warga',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.secondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxH, maxWidth: maxW),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari nama...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.search),
                        ),
                        onChanged: (v) => currentNama = v,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: currentJK,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          labelText: 'Jenis Kelamin',
                        ),
                        items: const [
                          DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                        ],
                        onChanged: (v) => setModalState(() => currentJK = v),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _filterNama = null;
                                _filterJenisKelamin = null;
                              });
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.primary)),
                            child: const Text('Reset', style: TextStyle(color: AppTheme.primary)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _filterNama = currentNama;
                                _filterJenisKelamin = currentJK;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.third),
                            child: const Text('Terapkan'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<PenggunaModel> get _filteredList {
    return _allUsers.where((u) {
      final byNama = _filterNama == null || u.nama.toLowerCase().contains((_filterNama ?? '').toLowerCase());
      final jk = (u.jenisKelamin ?? '').toLowerCase();
      final byJK = _filterJenisKelamin == null || jk == (_filterJenisKelamin ?? '').toLowerCase();
      return byNama && byJK;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.goNamed('aspirasi');
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.primary,
          title: const Text('Penerimaan Warga', style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.goNamed('aspirasi');
              }
            },
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.filter_list, color: Colors.white),
                      onPressed: () => _showFilterModal(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text('Filter', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                            : _filteredList.isEmpty
                                ? const Center(child: Text('Tidak ada permintaan pending'))
                                : ListView.builder(
                                    itemCount: _filteredList.length,
                                    itemBuilder: (context, index) {
                                      final d = _filteredList[index];
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () => showDialog(
                                                      context: context,
                                                      builder: (_) => Dialog(
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius: BorderRadius.circular(16),
                                                              child: Image.network(
                                                                d.fotoIdentitasUrl ?? 'https://placehold.co/400x280/cccccc/000000?text=Tidak+ada+foto',
                                                                fit: BoxFit.cover,
                                                                errorBuilder: (context, error, stackTrace) {
                                                                  return Container(
                                                                    height: 280,
                                                                    color: Colors.grey[300],
                                                                    child: const Center(
                                                                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                                                                    ),
                                                                  );
                                                                },
                                                                loadingBuilder: (context, child, loadingProgress) {
                                                                  if (loadingProgress == null) return child;
                                                                  return Container(
                                                                    height: 280,
                                                                    color: Colors.grey[200],
                                                                    child: const Center(child: CircularProgressIndicator()),
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                            const SizedBox(height: 12),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                                              child: Text(
                                                                d.nama,
                                                                textAlign: TextAlign.center,
                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 16),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        d.fotoIdentitasUrl ?? 'https://placehold.co/80x80/cccccc/000000?text=Foto',
                                                        width: 80,
                                                        height: 80,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color: Colors.grey[300],
                                                            child: const Icon(Icons.person, size: 40, color: Colors.grey),
                                                          );
                                                        },
                                                        loadingBuilder: (context, child, loadingProgress) {
                                                          if (loadingProgress == null) return child;
                                                          return Container(
                                                            width: 80,
                                                            height: 80,
                                                            color: Colors.grey[200],
                                                            child: const Center(
                                                              child: SizedBox(
                                                                width: 20,
                                                                height: 20,
                                                                child: CircularProgressIndicator(strokeWidth: 2),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          d.nama,
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 16,
                                                            color: AppTheme.primary,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'NIK: ${d.nik ?? '-'}',
                                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          d.email,
                                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          'JK: ${(d.jenisKelamin ?? '').toUpperCase() == 'L' ? 'Laki-laki' : 'Perempuan'}',
                                                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(height: 24),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      icon: const Icon(Icons.check, size: 18),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppTheme.third,
                                                        foregroundColor: Colors.white,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onPressed: () async {
                                                        print('=== BUTTON TERIMA PRESSED ===');
                                                        print('User ID: ${d.userId}');
                                                        print('User Name: ${d.nama}');
                                                        
                                                        final ok = await _confirm(context, 'Terima warga ini?');
                                                        print('Confirmation result: $ok');
                                                        if (!ok) return;
                                                        
                                                        try {
                                                          // Show loading
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Memproses...'), duration: Duration(seconds: 1)),
                                                            );
                                                          }
                                                          
                                                          print('Calling updateStatus...');
                                                          final success = await _service.updateStatus(d.userId, 'Diterima');
                                                          print('updateStatus result: $success');
                                                          
                                                          if (success) {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(content: Text('Warga diterima'), backgroundColor: Colors.green),
                                                              );
                                                            }
                                                            await _fetchData();
                                                          } else {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(content: Text('Gagal memperbarui status'), backgroundColor: Colors.red),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          print('ERROR in button handler: $e');
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                                            );
                                                          }
                                                        }
                                                        print('=== BUTTON TERIMA END ===');
                                                      },
                                                      label: const Text('Terima'),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: OutlinedButton.icon(
                                                      icon: const Icon(Icons.close, size: 18),
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: AppTheme.secondary,
                                                        side: const BorderSide(color: AppTheme.secondary),
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      ),
                                                      onPressed: () async {
                                                        final ok = await _confirm(context, 'Tolak warga ini?');
                                                        if (!ok) return;
                                                        
                                                        try {
                                                          // Show loading
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              const SnackBar(content: Text('Memproses...'), duration: Duration(seconds: 1)),
                                                            );
                                                          }
                                                          
                                                          final success = await _service.updateStatus(d.userId, 'Ditolak');
                                                          
                                                          if (success) {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(content: Text('Warga ditolak'), backgroundColor: Colors.orange),
                                                              );
                                                            }
                                                            await _fetchData();
                                                          } else {
                                                            if (mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(content: Text('Gagal memperbarui status'), backgroundColor: Colors.red),
                                                              );
                                                            }
                                                          }
                                                        } catch (e) {
                                                          if (mounted) {
                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      label: const Text('Tolak'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirm(BuildContext context, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );
    return result ?? false;
  }
}
