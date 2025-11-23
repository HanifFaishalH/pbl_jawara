import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // 🎨 Warna chip sesuai status
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'diterima':
        backgroundColor = AppTheme.third.withOpacity(0.2); // hijau lembut
        textColor = AppTheme.third;
        break;
      case 'pending':
        backgroundColor = AppTheme.fourth.withOpacity(0.3); // kuning lembut
        textColor = AppTheme.primary; // teks biru tua agar kontras
        break;
      case 'ditolak':
        backgroundColor = AppTheme.secondary.withOpacity(0.2); // merah muda lembut
        textColor = AppTheme.secondary;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.toLowerCase() == 'diterima'
                ? Icons.check_circle
                : status.toLowerCase() == 'pending'
                ? Icons.hourglass_bottom
                : Icons.cancel,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
