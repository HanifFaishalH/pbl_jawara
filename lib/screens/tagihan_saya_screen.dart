import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/iuran_service.dart';

class TagihanSayaScreen extends StatefulWidget {
  const TagihanSayaScreen({super.key});

  @override
  State<TagihanSayaScreen> createState() => _TagihanSayaScreenState();
}

class _TagihanSayaScreenState extends State<TagihanSayaScreen> with SingleTickerProviderStateMixin {
  final IuranService _iuranService = IuranService.instance;
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  late TabController _tabController;
  List<dynamic> _allTagihan = [];
  List<dynamic> _filteredTagihan = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  final List<String> _statusFilters = ['Semua', 'Belum Bayar', 'Menunggu Verifikasi', 'Lunas'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTagihan();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _filterTagihan();
    }
  }
  
  Future<void> _loadTagihan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await _iuranService.tagihanSaya();
      
      if (response['success']) {
        setState(() {
          _allTagihan = response['data'] ?? [];
          _filterTagihan();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat tagihan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }
  
  void _filterTagihan() {
    setState(() {
      final selectedStatus = _statusFilters[_tabController.index];
      if (selectedStatus == 'Semua') {
        _filteredTagihan = _allTagihan;
      } else {
        _filteredTagihan = _allTagihan.where((tagihan) => tagihan['status'] == selectedStatus).toList();
      }
    });
  }
  
  Future<void> _refreshTagihan() async {
    await _loadTagihan();
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Belum Bayar':
        return Colors.red;
      case 'Menunggu Verifikasi':
        return Colors.orange;
      case 'Lunas':
        return Colors.green;
      case 'Ditolak':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
  
  bool _isOverdue(dynamic tagihan) {
    if (tagihan['status'] == 'Lunas' || tagihan['jatuh_tempo'] == null) {
      return false;
    }
    
    try {
      final jatuhTempo = DateTime.parse(tagihan['jatuh_tempo']);
      return DateTime.now().isAfter(jatuhTempo);
    } catch (e) {
      return false;
    }
  }
  
  void _navigateToPayment(dynamic tagihan) {
    // Navigate to payment screen - will be implemented next
    Navigator.pushNamed(
      context,
      '/bayar-tagihan',
      arguments: tagihan,
    ).then((_) => _refreshTagihan());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _statusFilters.map((status) {
            final count = status == 'Semua' 
                ? _allTagihan.length 
                : _allTagihan.where((t) => t['status'] == status).length;
            return Tab(text: '$status ($count)');
          }).toList(),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
                : _buildTagihanList(),
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTagihan,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTagihanList() {
    if (_filteredTagihan.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _refreshTagihan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTagihan.length,
        itemBuilder: (context, index) {
          final tagihan = _filteredTagihan[index];
          return _buildTagihanCard(tagihan);
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tagihan',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Tarik ke bawah untuk menyegarkan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTagihanCard(dynamic tagihan) {
    final isOverdue = _isOverdue(tagihan);
    final status = tagihan['status'] ?? 'Unknown';
    final canPay = status == 'Belum Bayar';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: canPay ? () => _navigateToPayment(tagihan) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tagihan['kode_tagihan'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _getStatusColor(status), width: 1),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Kategori
              Row(
                children: [
                  Icon(Icons.category_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tagihan['kategori']?['nama_kategori'] ?? 'Kategori tidak diketahui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Nominal
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    currencyFormatter.format(tagihan['nominal'] ?? 0),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Tanggal Tagihan
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Tagihan: ${_formatDate(tagihan['tanggal_tagihan'])}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Jatuh Tempo with overdue indicator
              Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.event_outlined,
                    size: 18,
                    color: isOverdue ? Colors.red : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Jatuh Tempo: ${_formatDate(tagihan['jatuh_tempo'])}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isOverdue ? Colors.red : Colors.grey.shade700,
                        fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'TERLAMBAT',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              
              // Keterangan if exists
              if (tagihan['keterangan'] != null && tagihan['keterangan'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tagihan['keterangan'],
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action button for unpaid bills
              if (canPay) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPayment(tagihan),
                    icon: const Icon(Icons.payment),
                    label: const Text('Bayar Sekarang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }
}
