import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/pesan_warga_service.dart';

class PesanInput extends StatefulWidget {
  final VoidCallback onSend;

  const PesanInput({super.key, required this.onSend});

  @override
  State<PesanInput> createState() => _PesanInputState();
}

class _PesanInputState extends State<PesanInput> {
  final TextEditingController _controller = TextEditingController();
  final PesanWargaService _service = PesanWargaService();

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    // Untuk uji coba, kirim ke penerima_id = 2
    await _service.kirimPesan(_controller.text.trim(), 2);
    _controller.clear();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).colorScheme.primary,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
