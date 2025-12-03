import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jawaramobile_1/services/channel_transfer_service.dart';

class TambahChannelScreen extends StatefulWidget {
  final int? channelId;
  const TambahChannelScreen({super.key, this.channelId});

  @override
  State<TambahChannelScreen> createState() => _TambahChannelScreenState();
}

class _TambahChannelScreenState extends State<TambahChannelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nomorCtrl = TextEditingController();
  final _pemilikCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  final _service = ChannelTransferService();
  final _picker = ImagePicker();
  
  String? _tipe;
  String _status = 'aktif';
  XFile? _qrFile;
  XFile? _thumbnailFile;
  String? _existingQr;
  String? _existingThumbnail;
  bool _loading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.channelId != null;
    if (_isEdit) _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final data = await _service.getChannelById(widget.channelId!);
      if (mounted) {
        setState(() {
          _namaCtrl.text = data['channel_nama'] ?? '';
          _nomorCtrl.text = data['channel_nomor'] ?? '';
          _pemilikCtrl.text = data['channel_pemilik'] ?? '';
          _catatanCtrl.text = data['channel_catatan'] ?? '';
          _tipe = data['channel_tipe'];
          _status = data['channel_status'] ?? 'aktif';
          _existingQr = data['channel_qr'];
          _existingThumbnail = data['channel_thumbnail'];
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

  void _reset() {
    _formKey.currentState?.reset();
    _namaCtrl.clear();
    _nomorCtrl.clear();
    _pemilikCtrl.clear();
    _catatanCtrl.clear();
    setState(() {
      _tipe = null;
      _status = 'aktif';
      _qrFile = null;
      _thumbnailFile = null;
    });
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    final fields = {
      'channel_nama': _namaCtrl.text,
      'channel_tipe': _tipe!,
      'channel_nomor': _nomorCtrl.text,
      'channel_pemilik': _pemilikCtrl.text,
      'channel_catatan': _catatanCtrl.text,
      'channel_status': _status,
    };

    final success = await _service.saveChannel(
      fields: fields,
      qrFile: _qrFile,
      thumbnailFile: _thumbnailFile,
      id: widget.channelId,
    );

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Channel berhasil disimpan'
              : 'Gagal menyimpan channel'),
        ),
      );
      if (success) Navigator.of(context).pop();
    }
  }

  Future<void> _pickImage(bool isQr) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isQr) {
          _qrFile = image;
        } else {
          _thumbnailFile = image;
        }
      });
    }
  }

  Widget _field(String label, TextEditingController c,
      {TextInputType keyboard = TextInputType.text, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _uploadPlaceholder(String label, bool isQr) {
    final file = isQr ? _qrFile : _thumbnailFile;
    final existing = isQr ? _existingQr : _existingThumbnail;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(isQr),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: Center(
              child: file != null
                  ? Text("File dipilih: ${file.name}")
                  : existing != null
                      ? Text("File tersimpan: ${existing.split('/').last}")
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tap untuk upload gambar"),
                          ],
                        ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? "Edit Channel Transfer" : "Tambah Channel Transfer"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field("Nama Channel", _namaCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Wajib diisi" : null),
                    DropdownButtonFormField<String>(
                      value: _tipe,
                      hint: const Text("-- Pilih Tipe --"),
                      items: const [
                        DropdownMenuItem(value: 'bank', child: Text('Bank')),
                        DropdownMenuItem(
                            value: 'ewallet', child: Text('E-Wallet')),
                        DropdownMenuItem(value: 'qris', child: Text('QRIS')),
                      ],
                      onChanged: (v) => setState(() => _tipe = v),
                      decoration: const InputDecoration(
                        labelText: "Tipe",
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null ? "Pilih tipe" : null,
                    ),
                    const SizedBox(height: 16),
                    _field("Nomor Rekening / Akun", _nomorCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Wajib diisi" : null),
                    _field("Nama Pemilik", _pemilikCtrl,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? "Wajib diisi" : null),
                    DropdownButtonFormField<String>(
                      value: _status,
                      items: const [
                        DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                        DropdownMenuItem(
                            value: 'nonaktif', child: Text('Non-Aktif')),
                      ],
                      onChanged: (v) => setState(() => _status = v!),
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _uploadPlaceholder("QR Code", true),
                    _uploadPlaceholder("Thumbnail", false),
                    TextFormField(
                      controller: _catatanCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Catatan (Opsional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _loading ? null : _simpan,
                            child: Text(_isEdit ? "Update" : "Simpan"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _loading ? null : _reset,
                            child: const Text("Reset"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
