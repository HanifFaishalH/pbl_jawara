import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../services/iuran_service.dart';

class BayarTagihanScreen extends StatefulWidget {
  final dynamic tagihan;
  
  const BayarTagihanScreen({super.key, required this.tagihan});

  @override
  State<BayarTagihanScreen> createState() => _BayarTagihanScreenState();
}

class _BayarTagihanScreenState extends State<BayarTagihanScreen> {
  final _formKey = GlobalKey<FormState>();
  final IuranService _iuranService = IuranService.instance;
  final ImagePicker _picker = ImagePicker();
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  
  File? _selectedImage;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Pre-fill with tagihan nominal
    _jumlahController.text = currencyFormatter.format(widget.tagihan['nominal'] ?? 0);
    _tanggalController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);
  }
  
  @override
  void dispose() {
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Sumber Gambar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
      });
    }
  }
  
  int _parseAmount(String text) {
    // Remove currency symbol and formatting
    String cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleanText) ?? 0;
  }
  
  void _formatCurrency() {
    int amount = _parseAmount(_jumlahController.text);
    _jumlahController.text = currencyFormatter.format(amount);
    _jumlahController.selection = TextSelection.fromPosition(
      TextPosition(offset: _jumlahController.text.length),
    );
  }
  
  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan unggah bukti transfer'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final jumlahDibayar = _parseAmount(_jumlahController.text);
      final tanggalBayar = DateFormat('yyyy-MM-dd').format(_selectedDate);
      
      final success = await _iuranService.bayarTagihan(
        tagihanId: widget.tagihan['tagihan_id'],
        buktiTransfer: _selectedImage!,
        jumlahDibayar: jumlahDibayar,
        tanggalBayar: tanggalBayar,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil dikirim. Menunggu verifikasi bendahara.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayar Tagihan'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tagihan Info Card
                  _buildTagihanInfoCard(),
                  const SizedBox(height: 24),
                  
                  // Payment Form
                  const Text(
                    'Detail Pembayaran',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Jumlah Dibayar
                  TextFormField(
                    controller: _jumlahController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Dibayar',
                      prefixIcon: const Icon(Icons.payments),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) => _formatCurrency(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah tidak boleh kosong';
                      }
                      final amount = _parseAmount(value);
                      if (amount <= 0) {
                        return 'Jumlah harus lebih dari 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Tanggal Bayar
                  TextFormField(
                    controller: _tanggalController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Bayar',
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
                        return 'Tanggal tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Upload Bukti Transfer
                  const Text(
                    'Bukti Transfer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  
                  _selectedImage == null
                      ? _buildUploadButton()
                      : _buildImagePreview(),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Kirim Pembayaran',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  
  Widget _buildTagihanInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Tagihan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Kode Tagihan', widget.tagihan['kode_tagihan'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow('Kategori', widget.tagihan['kategori']?['nama_kategori'] ?? '-'),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Nominal',
              currencyFormatter.format(widget.tagihan['nominal'] ?? 0),
              valueStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Jatuh Tempo', _formatDate(widget.tagihan['jatuh_tempo'])),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
  
  Widget _buildUploadButton() {
    return InkWell(
      onTap: _showImageSourceDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'Unggah Bukti Transfer',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketuk untuk memilih gambar',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
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
