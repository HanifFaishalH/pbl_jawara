import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../services/iuran_service.dart';
import '../services/kategori_service.dart';

class TarikIuranScreen extends StatefulWidget {
  const TarikIuranScreen({super.key});

  @override
  State<TarikIuranScreen> createState() => _TarikIuranScreenState();
}

class _TarikIuranScreenState extends State<TarikIuranScreen> {
  final _formKey = GlobalKey<FormState>();
  final IuranService _iuranService = IuranService.instance;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  final TextEditingController _nominalController = TextEditingController();
  final TextEditingController _jatuhTempoController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  
  List<dynamic> _kategoriList = [];
  int? _selectedKategoriId;
  String _selectedTargetType = 'all';
  List<int> _selectedTargetIds = [];
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  bool _isLoadingKategori = true;
  
  final List<Map<String, String>> _targetTypes = [
    {'value': 'all', 'label': 'Semua Warga'},
    {'value': 'rt', 'label': 'Per RT'},
    {'value': 'keluarga', 'label': 'Per Keluarga'},
    {'value': 'warga', 'label': 'Per Warga'},
  ];
  
  @override
  void initState() {
    super.initState();
    _jatuhTempoController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
    _loadKategori();
  }
  
  @override
  void dispose() {
    _nominalController.dispose();
    _jatuhTempoController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }
  
  Future<void> _loadKategori() async {
    setState(() {
      _isLoadingKategori = true;
    });
    
    try {
      final response = await KategoriService.fetchKategori();

      // Filter hanya kategori iuran sesuai kode yang dipakai untuk penarikan iuran
      const allowedCodes = {'IUR-WARGA', 'SUM-ACARA', 'SEWA-LAP'};
      final filtered = response.where((k) {
        final code = k['kategori_kode'] as String?;
        return code != null && allowedCodes.contains(code);
      }).toList();

      setState(() {
        _kategoriList = filtered;
        _isLoadingKategori = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingKategori = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _jatuhTempoController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }
  
  int _parseAmount(String text) {
    String cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanText) ?? 0;
  }
  
  void _formatCurrency() {
    int amount = _parseAmount(_nominalController.text);
    _nominalController.text = currencyFormatter.format(amount);
    _nominalController.selection = TextSelection.fromPosition(
      TextPosition(offset: _nominalController.text.length),
    );
  }
  
  void _showConfirmationDialog() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final nominal = _parseAmount(_nominalController.text);
    final kategoriNama = _kategoriList.firstWhere(
      (k) => k['kategori_id'] == _selectedKategoriId,
        orElse: () => {'kategori_nama': 'Unknown'},
      )['kategori_nama'] as String? ?? 'Unknown';
    
    final targetLabel = _targetTypes.firstWhere(
      (t) => t['value'] == _selectedTargetType,
      orElse: () => {'label': 'Unknown'},
    )['label'] ?? 'Unknown';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Tarik Iuran'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildConfirmationRow('Kategori', kategoriNama),
              _buildConfirmationRow('Nominal', currencyFormatter.format(nominal)),
              _buildConfirmationRow('Jatuh Tempo', _jatuhTempoController.text),
              _buildConfirmationRow('Target', targetLabel),
              if (_keteranganController.text.isNotEmpty)
                _buildConfirmationRow('Keterangan', _keteranganController.text),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tagihan akan dikirim ke $targetLabel. Pastikan data sudah benar.',
                        style: TextStyle(fontSize: 13, color: Colors.orange.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitTarikIuran();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim Tagihan'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _submitTarikIuran() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    
    try {
      final nominal = _parseAmount(_nominalController.text);
      final jatuhTempo = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final success = await _iuranService.tarikIuran(
        kategoriId: _selectedKategoriId!,
        nominal: nominal,
        jatuhTempo: jatuhTempo,
        targetType: _selectedTargetType,
        targetIds: _selectedTargetIds.isNotEmpty ? _selectedTargetIds : null,
        keterangan: _keteranganController.text.isNotEmpty ? _keteranganController.text : null,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tagihan berhasil dikirim!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate tanpa delay, SnackBar tetap visible selama 2 detik
        if (!mounted) return;
        GoRouter.of(context).go('/menu-pemasukan');
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim tagihan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarik Iuran'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).go('/menu-pemasukan'),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: _isLoadingKategori
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tagihan yang dibuat akan otomatis dikirim ke warga sesuai target yang dipilih.',
                                  style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Kategori Dropdown
                        const Text(
                          'Kategori Iuran',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedKategoriId,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          hint: const Text('Pilih Kategori'),
                          items: _kategoriList.map<DropdownMenuItem<int>>((kategori) {
                            final id = kategori['kategori_id'] as int?;
                              final nama = kategori['kategori_nama'] as String? ?? 'Unknown';
                            
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(nama),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedKategoriId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Kategori harus dipilih';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Nominal
                        const Text(
                          'Nominal Tagihan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nominalController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.payments),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText: 'Masukkan nominal',
                          ),
                          onChanged: (value) => _formatCurrency(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nominal tidak boleh kosong';
                            }
                            final amount = _parseAmount(value);
                            if (amount <= 0) {
                              return 'Nominal harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Jatuh Tempo
                        const Text(
                          'Jatuh Tempo',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _jatuhTempoController,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          onTap: _selectDate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jatuh tempo harus dipilih';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        
                        // Target Type
                        const Text(
                          'Target Tagihan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._targetTypes.map((type) {
                          return RadioListTile<String>(
                            title: Text(type['label']!),
                            value: type['value']!,
                            groupValue: _selectedTargetType,
                            onChanged: (value) {
                              setState(() {
                                _selectedTargetType = value!;
                                _selectedTargetIds.clear();
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          );
                        }),
                        
                        // Target Selection (if not 'all')
                        if (_selectedTargetType != 'all') ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade700, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Fitur pemilihan target spesifik akan segera hadir.',
                                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Keterangan
                        const Text(
                          'Keterangan (Opsional)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _keteranganController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText: 'Tambahkan catatan atau keterangan...',
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _showConfirmationDialog,
                            icon: _isLoading
                                ? const SizedBox()
                                : const Icon(Icons.send),
                            label: _isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Kirim Tagihan',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
}
