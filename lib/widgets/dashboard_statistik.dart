import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
class DashboardStatistik extends StatelessWidget {
  const DashboardStatistik({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = const [
      {'label': 'Keuangan', 'icon': FontAwesomeIcons.wallet},
      {'label': 'Kegiatan', 'icon': FontAwesomeIcons.calendarDays},
      {'label': 'Kependudukan', 'icon': FontAwesomeIcons.peopleGroup},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Statistik', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final spacing = isNarrow ? 12.0 : 20.0;
              final iconSize = isNarrow ? 22.0 : 26.0;
              final boxSize = isNarrow ? 50.0 : 56.0;
              final labelStyle = textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              );

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.map((e) {
                  return SizedBox(
                    width: constraints.maxWidth / 3 - (spacing * 0.8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: boxSize,
                          width: boxSize,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: FaIcon(
                              e['icon'] as IconData,
                              color: colorScheme.onPrimary,
                              size: iconSize,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing / 2),
                        Text(
                          e['label'] as String,
                          textAlign: TextAlign.center,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: labelStyle,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
