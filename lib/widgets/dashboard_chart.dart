import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 📈 DashboardChart Widget
/// Menampilkan data kegiatan per kategori dalam bentuk pie chart.
/// Bagian dari tampilan utama Dashboard.
class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧾 Judul Widget
          Text(
            "📊 Statistik Kegiatan Warga",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Distribusi kegiatan berdasarkan kategori RW",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 16),

          // 🍩 Pie Chart
          AspectRatio(
            aspectRatio: 1.4,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: colorScheme.primary,
                    title: '40%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 30,
                    color: colorScheme.secondary,
                    title: '30%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 10,
                    color: colorScheme.tertiary,
                    title: '10%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PieChartSectionData(
                    value: 10,
                    color: colorScheme.onError,
                    title: '10%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 🔘 Keterangan Warna
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _LegendDot(color: Colors.blue, label: 'Komunitas & Sosial'),
              _LegendDot(color: Colors.orange, label: 'Keagamaan'),
              _LegendDot(color: Colors.purple, label: 'Pendidikan'),
              _LegendDot(color: Colors.red, label: 'Kesehatan & Olahraga'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
