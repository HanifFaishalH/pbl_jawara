import 'package:flutter/material.dart';

class KegiatanSection extends StatelessWidget {
  const KegiatanSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Kegiatan Warga', style: theme.textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Kegiatan Terbaru', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: Text(
            'Belum ada kegiatan',
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
