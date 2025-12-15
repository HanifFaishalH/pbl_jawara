import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class DashboardStatistik extends StatelessWidget {
  const DashboardStatistik({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final items = const [
      {'label': 'Keuangan', 'icon': FontAwesomeIcons.wallet, 'route': '/laporan-keuangan'},
      {'label': 'Kegiatan', 'icon': FontAwesomeIcons.calendarDays, 'route': '/kegiatan'},
      {'label': 'Kependudukan', 'icon': FontAwesomeIcons.peopleGroup, 'route': '/data-warga-rumah'},
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Dashboard Statistik',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Akses cepat ke menu utama',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
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
                  return _StatistikItem(
                    icon: e['icon'] as IconData,
                    label: e['label'] as String,
                    route: e['route'] as String,
                    width: constraints.maxWidth / 3 - (spacing * 0.8),
                    iconSize: iconSize,
                    boxSize: boxSize,
                    spacing: spacing,
                    labelStyle: labelStyle,
                    colorScheme: colorScheme,
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

class _StatistikItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final double width;
  final double iconSize;
  final double boxSize;
  final double spacing;
  final TextStyle labelStyle;
  final ColorScheme colorScheme;

  const _StatistikItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.width,
    required this.iconSize,
    required this.boxSize,
    required this.spacing,
    required this.labelStyle,
    required this.colorScheme,
  });

  @override
  State<_StatistikItem> createState() => _StatistikItemState();
}

class _StatistikItemState extends State<_StatistikItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(widget.route),
      onHover: (hovering) => setState(() => _isHovered = hovering),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: widget.width,
        padding: const EdgeInsets.all(8),
        transform: Matrix4.identity()..scale(_isHovered ? 1.05 : 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: widget.boxSize,
              width: widget.boxSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.colorScheme.primary,
                    widget.colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.colorScheme.primary.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Center(
                child: FaIcon(
                  widget.icon,
                  color: Colors.white,
                  size: widget.iconSize,
                ),
              ),
            ),
            SizedBox(height: widget.spacing / 2),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: widget.labelStyle.copyWith(
                fontWeight: _isHovered ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
