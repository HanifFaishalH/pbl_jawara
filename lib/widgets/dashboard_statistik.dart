import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardStatistik extends StatelessWidget {
  const DashboardStatistik({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = [
      {'label': 'Keuangan', 'icon': FontAwesomeIcons.wallet},
      {'label': 'Kegiatan', 'icon': FontAwesomeIcons.calendarDays},
      {'label': 'Kependudukan', 'icon': FontAwesomeIcons.peopleGroup},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Statistik', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((e) {
              return Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: FaIcon(
                        e['icon'] as IconData,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(e['label'] as String,
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
