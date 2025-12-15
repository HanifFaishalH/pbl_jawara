import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

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
        _buildTableHeader(theme, colorScheme),
        const SizedBox(height: 16),
        // Tabel data
        _buildDataTable(theme, colorScheme),
      ],
    );
  }

  Widget _buildTableHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daftar Kategori Iuran",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${kategoriIuran.length} kategori terdaftar",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                label: const Text("Tambah", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme, ColorScheme colorScheme) {
    return Expanded(
      child: DataTable2(
        columnSpacing: 16,
        horizontalMargin: 16,
        minWidth: 300,
        headingRowHeight: 56,
        dataRowHeight: 64,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.primary.withOpacity(0.1), width: 2),
          ),
        ),
        headingRowColor: MaterialStateProperty.all(
          colorScheme.primary.withOpacity(0.15),
        ),
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: colorScheme.primary,
          letterSpacing: 0.5,
        ),
        columns: const [
          DataColumn2(label: Text('NO'), size: ColumnSize.S),
          DataColumn2(label: Text('NAMA KATEGORI'), size: ColumnSize.L),
          DataColumn2(
            label: Text('NOMINAL'),
            numeric: true,
            size: ColumnSize.L,
          ),
        ],
        rows: kategoriIuran.map((item) {
          return DataRow2(
            onTap: () => onViewPressed(item),
            color: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return colorScheme.primary.withOpacity(0.05);
                }
                return null;
              },
            ),
            cells: [
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['no']!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['nama']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[400]!, Colors.green[600]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item['nominal']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // DataCell(_buildActionButtons(item, theme), onTap: null),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, String> item, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          onPressed: () => onViewPressed(item),
        ),
        IconButton(
          icon: Icon(Icons.delete, size: 20, color: Colors.red[400]),
          onPressed: () => onDeletePressed(item),
        ),
      ],
    );
  }
}
