import 'package:flutter/material.dart';
import '../../theme/AppTheme.dart';
import '../../models/aspirasi_models.dart';
import '../../services/auth_service.dart';
import '../../services/aspirasi_service.dart';
import '../../widgets/status_chip.dart';

class DetailAspirasiScreen extends StatefulWidget {
  final AspirasiModel aspirasi;
  const DetailAspirasiScreen({super.key, required this.aspirasi});

  @override
  State<DetailAspirasiScreen> createState() => _DetailAspirasiScreenState();
}

class _DetailAspirasiScreenState extends State<DetailAspirasiScreen> {
  final TextEditingController _tanggapanController = TextEditingController();
  String? _selectedStatus;
  bool _isProcessing = false;
  
  // Logic Auth: Role 6 (Warga) tidak boleh edit, selain itu (Pejabat) boleh.
  bool get _isAuthorized => AuthService.currentRoleId != 6;

  @override
  void initState() {
    super.initState();
    // Set status awal di dropdown
    if (['Pending', 'Diterima'].contains(widget.aspirasi.status)) {
       _selectedStatus = widget.aspirasi.status;
    } else {
       _selectedStatus = 'Pending';
    }
    // Set text tanggapan jika sudah ada sebelumnya
    _tanggapanController.text = widget.aspirasi.tanggapan ?? '';
  }

  @override
  void dispose() {
    _tanggapanController.dispose();
    super.dispose();
  }

  // --- FUNGSI POP-UP SUKSES ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus klik tombol OK
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppTheme.secondary, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Berhasil Disimpan!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Status aspirasi dan tanggapan telah diperbarui.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Tutup Dialog
                  Navigator.of(context).pop(true); // Kembali ke Dashboard & Refresh Data
                },
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) return;
    
    // Validasi sederhana: Jika status diterima tapi tanggapan kosong
    if (_selectedStatus == 'Diterima' && _tanggapanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap berikan tanggapan jika status Diterima')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      final success = await AspirasiService().updateStatus(
        widget.aspirasi.aspirasiId, 
        _selectedStatus!, 
        _tanggapanController.text
      );
      
      if (success) {
        if (!mounted) return;
        // Panggil Dialog Pop-up
        _showSuccessDialog();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupdate status.'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Aspirasi'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === SECTION 1: INFORMASI ASPIRASI (READ ONLY) ===
            Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul
                    Text(
                      widget.aspirasi.judul, 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                    ),
                    const SizedBox(height: 12),
                    
                    // Info Pengirim & Tanggal
                    Row(
                      children: [
                        const Icon(Icons.account_circle, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.aspirasi.pengirim, 
                            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)
                          ),
                        ),
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.aspirasi.tanggalDibuat, 
                          style: const TextStyle(color: Colors.grey, fontSize: 12)
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1),
                    
                    // Deskripsi
                    const Text('Isi Aspirasi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      widget.aspirasi.deskripsi, 
                      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)
                    ),
                    const SizedBox(height: 20),
                    
                    // Status Badge
                    Row(
                      children: [
                        const Text('Status Saat Ini: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        StatusChip(status: widget.aspirasi.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === SECTION 2: AREA PEJABAT VS AREA WARGA ===
            
            if (_isAuthorized) ...[
              // --- FORM KHUSUS PEJABAT (ADMIN/RT/RW) ---
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text('Tindakan Pejabat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100)
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Dropdown Status
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Update Status',
                        prefixIcon: const Icon(Icons.flag, color: AppTheme.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
                      ),
                      items: ['Pending', 'Diterima']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _selectedStatus = v),
                    ),
                    const SizedBox(height: 16),
                    
                    // Input Tanggapan
                    TextField(
                      controller: _tanggapanController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Berikan Tanggapan / Balasan',
                        hintText: 'Tulis pesan balasan untuk warga...',
                        prefixIcon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primary),
                        alignLabelWithHint: true, // Label di atas untuk multiline
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 2,
                        ),
                        child: _isProcessing 
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : const Text('Simpan & Konfirmasi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
              ),
            ] else ...[
              // --- TAMPILAN BALASAN UNTUK WARGA ---
              if (widget.aspirasi.tanggapan != null && widget.aspirasi.tanggapan!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Balasan Resmi:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.secondary,
                            child: Icon(Icons.verified_user, size: 18, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // NAMA PENANGGAP SPESIFIK
                                Text(
                                  widget.aspirasi.namaPenanggap ?? "Pejabat Berwenang", 
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary, fontSize: 15)
                                ),
                                const SizedBox(height: 2),
                                const Text("Menanggapi aspirasi Anda", style: TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        widget.aspirasi.tanggapan!, 
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4)
                      ),
                    ],
                  ),
                )
              ] else ...[
                 // Info Belum Ada Tanggapan
                 Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200)
                  ),
                  child: const Row(
                    children: [
                       Icon(Icons.info_outline, color: Colors.orange),
                       SizedBox(width: 12),
                       Expanded(child: Text("Aspirasi ini belum mendapatkan tanggapan dari pejabat terkait.", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500))),
                    ],
                  )
                )
              ]
            ]
          ],
        ),
      ),
    );
  }
}