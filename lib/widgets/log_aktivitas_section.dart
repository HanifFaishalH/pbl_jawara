import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LogAktivitasSection extends StatelessWidget {
  const LogAktivitasSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final logs = [
      'Admin menambahkan kegiatan baru',
      'User A melaporkan masalah air',
      'Teknisi memperbarui status perbaikan',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Log Aktifitas', style: theme.textTheme.titleLarge),
            Text('Detail',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: logs.map((e) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Row(
                children: [
                  FaIcon(FontAwesomeIcons.clockRotateLeft, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(e, style: theme.textTheme.bodyMedium)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
