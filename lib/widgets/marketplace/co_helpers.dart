import 'package:flutter/material.dart';

class CheckoutDivider extends StatelessWidget {
  const CheckoutDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: Colors.grey[100]);
  }
}

class CheckoutSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;

  const CheckoutSectionHeader({
    super.key, 
    required this.title, 
    required this.icon,
    this.iconColor = const Color(0xFF26547C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}

class CheckoutClickableRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const CheckoutClickableRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[700])),
            Row(
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            )
          ],
        ),
      ),
    );
  }
}