import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MutasiPage extends StatelessWidget {
  final List<Map<String, dynamic>> dataMutasi = [
    {
      "no": 1,
      "keluarga": "Keluarga Ijat",
      "tanggal": "15 Oktober 2025",
      "jenis": "Keluar Wilayah",
    },
    {
      "no": 2,
      "keluarga": "Keluarga Mara Nunez",
      "tanggal": "30 September 2025",
      "jenis": "Pindah Rumah",
    },
    {
      "no": 3,
      "keluarga": "Keluarga Ijat",
      "tanggal": "24 Oktober 2026",
      "jenis": "Pindah Rumah",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Daftar Mutasi Warga",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DataTableTheme(
                  data: DataTableThemeData(
                    headingRowColor: WidgetStateProperty.all(
                      colorScheme.primary.withOpacity(0.1),
                    ),
                    dataRowColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 0,
                      horizontalMargin: 16,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      columns: const [
                        DataColumn(label: Text("No")),
                        DataColumn(label: Text("Nama Keluarga")),
                        DataColumn(label: Text("Aksi")),
                      ],
                      rows: dataMutasi.map((item) {
                        return DataRow(
                          cells: [
                            DataCell(Text(item['no'].toString())),
                            DataCell(Text(item['keluarga'])),
                            DataCell(
                              Align(
                                alignment: Alignment.centerLeft,
                                child: IconButton(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.eye,
                                    size: 18,
                                    color: Colors.blueGrey,
                                  ),
                                  tooltip: 'Lihat Detail',
                                  onPressed: () {
                                    context.pushNamed(
                                      'mutasi-detail',
                                      extra: item,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
