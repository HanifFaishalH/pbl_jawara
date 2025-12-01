import 'package:flutter/material.dart';
import 'package:jawaramobile_1/models/pesan_warga.dart';

class PesanTile extends StatelessWidget {
  final PesanWarga pesan;

  const PesanTile({super.key, required this.pesan});

  @override
  Widget build(BuildContext context) {
    final isMe = pesan.pengirimNama == "Saya";
    final colors = Theme.of(context).colorScheme;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? colors.primaryContainer : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          pesan.isiPesan,
          style: TextStyle(color: isMe ? colors.onPrimaryContainer : colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
