import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KegiatanSection extends StatelessWidget {
  final bool showAddButton; // apakah ada tombol tambah
  final String? roleFilter; // RW, RT, Warga, dll
  final String? title;      // judul utama
  final String? subtitle;   // deskripsi tambahan

  const KegiatanSection({
    super.key,
    this.showAddButton = false,
    this.roleFilter,
    this.title,
    this.subtitle,
  });

  String _getRoleMessage() {
    switch (roleFilter) {
      case "RW":
        return "Lihat dan kelola kegiatan seluruh RT di wilayah RW Anda.";
      case "RT":
        return "Kegiatan terbaru yang diadakan oleh RT Anda.";
      case "Warga":
        return "Ikuti kegiatan lingkungan dan gotong royong di sekitar Anda.";
      case "Admin":
        return "Pantau semua kegiatan di tingkat RW dan RT.";
      default:
        return "Belum ada kegiatan untuk ditampilkan.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ Judul
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title ?? 'Kegiatan Warga',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color.onSurface,
              ),
            ),
            if (showAddButton)
              IconButton(
                icon: const Icon(FontAwesomeIcons.plusCircle),
                color: color.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tambah kegiatan coming soon!'),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle ?? 'Kegiatan terbaru minggu ini',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        // 🧱 Kartu kegiatan
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.primaryContainer,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                FontAwesomeIcons.peopleGroup,
                size: 30,
              ),
              const SizedBox(height: 12),
              Text(
                _getRoleMessage(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Belum ada kegiatan terdaftar.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
