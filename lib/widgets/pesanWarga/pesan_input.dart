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

    await _service.kirimPesan(_controller.text.trim(), 2);
    _controller.clear();
    widget.onSend();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,

      maintainBottomViewPadding: true,

      child: Material(
        elevation: 12,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
