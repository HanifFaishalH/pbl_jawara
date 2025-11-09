import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Tentukan warna berdasarkan status
    Color backgroundColor;
    Color foregroundColor;

    if (status.toLowerCase() == 'diterima') {
      backgroundColor = Colors.lightGreen.shade200;
      foregroundColor = Colors.green.shade900;
    } else if (status.toLowerCase() == 'pending') {
      backgroundColor = Colors.yellow.shade200;
      foregroundColor = Colors.orange.shade900;
    } else {
      backgroundColor = AppTheme.warmCream.withOpacity(0.5);
      foregroundColor = AppTheme.primaryOrange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
