import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// SESUAIKAN IMPORT INI
import 'kegiatan/kegiatan_card.dart'; 

class KegiatanSection extends StatelessWidget {
  final bool showAddButton;
  final String? roleFilter;
  final String? title;
  final String? subtitle;
  
  // Parameter tambahan untuk data
  final List<dynamic>? dataList;
  final bool isLoading;

  const KegiatanSection({
    super.key,
    this.showAddButton = false,
    this.roleFilter,
    this.title,
    this.subtitle,
    this.dataList,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final list = dataList ?? [];
    // Batasi 5 item saja untuk dashboard
    final displayList = list.length > 5 ? list.sublist(0, 5) : list;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title ?? 'Kegiatan Warga',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle ?? 'Kegiatan terbaru minggu ini',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (showAddButton)
               IconButton(
                icon: const Icon(FontAwesomeIcons.plusCircle),
                color: color.primary,
                onPressed: () { /* Logic Tambah */ },
              )
            else
              TextButton(
                onPressed: () => context.push('/kegiatan'),
                child: const Text("Lihat Semua"),
              ),
          ],
        ),
        
        const SizedBox(height: 16),

        // --- BODY ---
        
        // 1. Loading
        if (isLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: color.primary),
            ),
          )
        
        // 2. Kosong
        else if (displayList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.outline.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(
                  FontAwesomeIcons.clipboardList,
                  size: 40,
                  color: color.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "Belum ada kegiatan saat ini.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        
        // 3. Ada Data
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true, // Wajib agar tidak error layout
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return KegiatanCard(
                item: displayList[index],
                onRefreshNeeded: () {}, 
              );
            },
          ),
      ],
    );
  }
}