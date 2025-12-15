import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';

class TagihanTable extends StatelessWidget {
  final List<Map<String, String>> daftarTagihan;
  // final VoidCallback onAddPressed;
  // final Function(Map<String, String>) onDeletePressed;
  final Function(Map<String, String>) onViewPressed;

  const TagihanTable({
    super.key,
    required this.daftarTagihan,
    // required this.onAddPressed,
    // required this.onDeletePressed,
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
    final belumLunas = daftarTagihan.where((item) => item['status'] == 'Belum Lunas').length;
    final lunas = daftarTagihan.length - belumLunas;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary.withOpacity(0.1), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daftar Tagihan",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(
                icon: Icons.pending_actions,
                label: "Belum Lunas",
                count: belumLunas,
                color: Colors.orange,
              ),
              _buildStatusChip(
                icon: Icons.check_circle,
                label: "Lunas",
                count: lunas,
                color: Colors.green,
              ),
              _buildStatusChip(
                icon: Icons.list_alt,
                label: "Total",
                count: daftarTagihan.length,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
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
        dataRowHeight: 68,
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
          DataColumn2(label: Text('NAMA KELUARGA'), size: ColumnSize.L),
          DataColumn2(
            label: Text('NOMINAL'),
            numeric: true,
            size: ColumnSize.L,
          ),
          DataColumn2(label: Text('STATUS'), size: ColumnSize.L),
        ],
        rows: daftarTagihan.map((item) {
          final isLunas = item['status'] == 'Lunas';
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
                        Icons.family_restroom,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['namaKeluarga']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            item['periode']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isLunas ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isLunas ? Colors.green : Colors.orange,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLunas ? Icons.check_circle : Icons.pending_outlined,
                        size: 14,
                        color: isLunas ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item['status']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: isLunas ? Colors.green[700] : Colors.orange[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
      ],
    );
  }
}
