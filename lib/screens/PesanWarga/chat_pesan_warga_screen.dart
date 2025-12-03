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
    setState(() => _isLoading = true);
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
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _kirimPesan() async {
    final isi = _pesanController.text.trim();
    if (isi.isEmpty) return;

    final success = await _service.kirimPesan(isi, widget.penerimaId);
    if (success) {
      _pesanController.clear();
      _loadPesan(); // reload list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim pesan")),
      );
    }
  }


  Widget _buildChatBubble(Map<String, dynamic> pesan) {
    final currentUserId = AuthService.userId;
    final isMe = pesan['pengirim_id'] == currentUserId;

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
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              pesan['isi_pesan'] ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              pesan['waktu'] ?? '',
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: Text(widget.penerimaNama,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadPesan,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: _pesanList.length,
                      itemBuilder: (context, index) =>
                          _buildChatBubble(_pesanList[index]),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
                  icon: const Icon(Icons.send_rounded, color: Colors.blueAccent),
                  onPressed: _kirimPesan,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
