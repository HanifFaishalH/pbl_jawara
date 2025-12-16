import 'package:flutter/material.dart';
import '../../services/pesan_warga_service.dart';
import '../../services/auth_service.dart';

class ChatPesanWargaScreen extends StatefulWidget {
  final int penerimaId;
  final String penerimaNama;

  const ChatPesanWargaScreen({
    super.key,
    required this.penerimaId,
    required this.penerimaNama,
  });

  @override
  State<ChatPesanWargaScreen> createState() => _ChatPesanWargaScreenState();
}

class _ChatPesanWargaScreenState extends State<ChatPesanWargaScreen> {
  final PesanWargaService _service = PesanWargaService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _pesanController = TextEditingController();

  List<Map<String, dynamic>> _pesanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPesan();
  }

  Future<void> _loadPesan() async {
    try {
      final data = await _service.getChatWith(widget.penerimaId);
      setState(() {
        _pesanList = data;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat chat: $e")),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  Future<void> _kirimPesan() async {
    final isi = _pesanController.text.trim();
    if (isi.isEmpty) return;

    final success = await _service.kirimPesan(isi, widget.penerimaId);
    if (success) {
      _pesanController.clear();
      _loadPesan();
    }
  }

  Widget _buildChatBubble(Map<String, dynamic> pesan) {
    final bool isMe = pesan['pengirim_id'] == AuthService.userId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          pesan['isi_pesan'] ?? '',
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true, // 🔑 WAJIB
      appBar: AppBar(
        backgroundColor: colors.primary,
        title: Text(
          widget.penerimaNama,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // ================= LIST CHAT =================
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _pesanList.length,
                    itemBuilder: (context, index) =>
                        _buildChatBubble(_pesanList[index]),
                  ),
          ),

          // ================= INPUT (KUNCI UTAMA) =================
          SafeArea(
            top: false, // ❗ hanya lindungi bagian bawah
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pesanController,
                      decoration: const InputDecoration(
                        hintText: "Tulis pesan...",
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _kirimPesan(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.blueAccent,
                    ),
                    onPressed: _kirimPesan,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
