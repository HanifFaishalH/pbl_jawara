import 'package:flutter/material.dart';

class IuranTable extends StatelessWidget {
  final List<Map<String, String>> kategoriIuran;
  final VoidCallback onAddPressed;
  final Function(Map<String, String>) onDeletePressed;
  final Function(Map<String, String>) onViewPressed;

  const IuranTable({
    super.key,
    required this.kategoriIuran,
    required this.onAddPressed,
    required this.onDeletePressed,
    required this.onViewPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Header dengan tombol tambah
        _buildHeader(theme, colorScheme),
        const SizedBox(height: 16),
        // List cards
        Expanded(
          child: kategoriIuran.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  itemCount: kategoriIuran.length,
                  itemBuilder: (context, index) {
                    return _buildKategoriCard(
                      context,
                      kategoriIuran[index],
                      theme,
                      colorScheme,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Daftar Kategori Iuran",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onAddPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            "Tambah",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildKategoriCard(
    BuildContext context,
    Map<String, String> item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onViewPressed(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "#${item['no']}",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.visibility_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    onPressed: () => onViewPressed(item),
                    tooltip: 'Lihat Detail',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    onPressed: () => onDeletePressed(item),
                    tooltip: 'Hapus',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['nama']!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item['jenis']!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 16,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        item['nominal']!,
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "Belum ada kategori iuran",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap tombol Tambah untuk membuat kategori baru",
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
