import 'package:flutter/material.dart';

class TagihIuranActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onTagih;

  const TagihIuranActions({
    super.key,
    required this.onReset,
    required this.onTagih,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildResetButton()),
        const SizedBox(width: 12),
        Expanded(child: _buildTagihButton(context)),
      ],
    );
  }

  Widget _buildResetButton() {
    return OutlinedButton(
      onPressed: onReset,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Reset"),
    );
  }

  Widget _buildTagihButton(BuildContext context) {
    return ElevatedButton(
      onPressed: onTagih,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: const Text("Tagih Iuran", style: TextStyle(color: Colors.white)),
    );
  }
}
