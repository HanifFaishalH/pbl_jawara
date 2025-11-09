import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';
import '../widgets/status_chip.dart';
import 'edit_pesan_screen.dart';

// Model data untuk simulasi
class PesanWarga {
  final int no;
  final String pengirim;
  final String judul;
  final String status;
  final String tanggalDibuat;

  PesanWarga({
    required this.no,
    required this.pengirim,
    required this.judul,
    required this.status,
    required this.tanggalDibuat,
  });
}

class DashboardAspirasi extends StatefulWidget {
  const DashboardAspirasi({super.key});

  @override
  State<DashboardAspirasi> createState() => _DashboardAspirasiState();
}

class _DashboardAspirasiState extends State<DashboardAspirasi> {
  // Data simulasi
  final List<PesanWarga> _pesanList = [
    PesanWarga(
      no: 1,
      pengirim: 'Varizky Naldiba Rimra',
      judul: 'titootit',
      status: 'Diterima',
      tanggalDibuat: '16 Oktober 2025',
    ),
    PesanWarga(
      no: 2,
      pengirim: 'Habibie Ed Dien',
      judul: 'tes',
      status: 'Pending',
      tanggalDibuat: '28 September 2025',
    ),
    PesanWarga(
      no: 3,
      pengirim: 'Ahmad Fulan',
      judul: 'Aspirasi RT 05',
      status: 'Pending',
      tanggalDibuat: '01 Oktober 2025',
    ),
    PesanWarga(
      no: 4,
      pengirim: 'Siti Aminah',
      judul: 'Usul Perbaikan Jalan',
      status: 'Diterima',
      tanggalDibuat: '10 September 2025',
    ),
  ];

  String? _filterJudul;
  String? _filterStatus;

  // =========================================================================
  // MODAL FILTER
  // =========================================================================
  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? currentJudul = _filterJudul;
        String? currentStatus = _filterStatus;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: const EdgeInsets.all(24),
              contentPadding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Pesan Warga',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Filter
                  Text(
                    'Judul',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: currentJudul,
                    decoration: InputDecoration(
                      hintText: 'Cari judul...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      currentJudul = value.isEmpty ? null : value;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Status Filter
                  Text(
                    'Status',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentStatus,
                    hint: const Text('-- Pilih Status --'),
                    items: ['Diterima', 'Pending', 'Ditolak'].map((
                      String status,
                    ) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setStateModal(() {
                        currentStatus = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          // Reset filter
                          setState(() {
                            _filterJudul = null;
                            _filterStatus = null;
                          });
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryOrange,
                          side: BorderSide(color: AppTheme.primaryOrange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reset Filter'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Terapkan filter
                          setState(() {
                            _filterJudul = currentJudul;
                            _filterStatus = currentStatus;
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.highlightYellow,
                          foregroundColor: AppTheme.darkBrown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // FUNGSI UTAMA
  // =========================================================================
  List<PesanWarga> get _filteredPesanList {
    if (_filterJudul == null && _filterStatus == null) {
      return _pesanList;
    }

    return _pesanList.where((pesan) {
      final matchesJudul =
          _filterJudul == null ||
          pesan.judul.toLowerCase().contains(_filterJudul!.toLowerCase());
      final matchesStatus =
          _filterStatus == null ||
          pesan.status.toLowerCase() == _filterStatus!.toLowerCase();
      return matchesJudul && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredList = _filteredPesanList;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Gradient background
          gradient: LinearGradient(
            colors: [AppTheme.darkBrown, AppTheme.warmCream],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Dashboard Warga',
                style: theme.textTheme.displayLarge!.copyWith(
                  color: AppTheme.darkBrown,
                ),
              ),
              backgroundColor: AppTheme.primaryOrange,
              floating: true,
              pinned: true,
              expandedHeight: 0, // No expansion needed for this screen
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryOrange.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => _showFilterModal(context),
                          icon: const Icon(
                            Icons.filter_list,
                            color: AppTheme.darkBrown,
                          ),
                          label: const Text(
                            'Filter',
                            style: TextStyle(color: AppTheme.darkBrown),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.highlightYellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Data Table (Responsive/Scrollable)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 8,
                          headingRowColor: MaterialStateProperty.all(
                            AppTheme.warmCream,
                          ),
                          headingTextStyle: theme.textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryOrange,
                          ),
                          columns: const [
                            DataColumn(label: Text('NO')),
                            DataColumn(label: Text('PENGIRIM')),
                            DataColumn(label: Text('JUDUL')),
                            DataColumn(label: Text('STATUS')),
                            DataColumn(label: Text('TANGGAL DIBUAT')),
                            DataColumn(label: Text('AKSI')),
                          ],
                          rows: filteredList.map((pesan) {
                            return DataRow(
                              cells: [
                                DataCell(Text(pesan.no.toString())),
                                DataCell(Text(pesan.pengirim)),
                                DataCell(Text(pesan.judul)),
                                DataCell(StatusChip(status: pesan.status)),
                                DataCell(Text(pesan.tanggalDibuat)),
                                DataCell(
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: AppTheme.primaryOrange,
                                    ),
                                    onSelected: (String result) {
                                      if (result == 'Edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const EditPesanScreen(),
                                          ),
                                        );
                                      } else if (result == 'Detail') {
                                        // TODO: Implement Detail Screen
                                        print(
                                          'Lihat Detail Pesan ${pesan.judul}',
                                        );
                                      } else if (result == 'Hapus') {
                                        // TODO: Implement Delete Confirmation
                                        print('Hapus Pesan ${pesan.judul}');
                                      }
                                    },
                                    itemBuilder: (BuildContext context) =>
                                        <PopupMenuEntry<String>>[
                                          const PopupMenuItem<String>(
                                            value: 'Detail',
                                            child: Text('Detail'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'Edit',
                                            child: Text('Edit'),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'Hapus',
                                            child: Text('Hapus'),
                                          ),
                                        ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Pagination (Simplified)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              size: 16,
                              color: AppTheme.warmCream,
                            ),
                            onPressed: () {}, // Logic for previous page
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.highlightYellow,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: AppTheme.darkBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppTheme.warmCream,
                            ),
                            onPressed: () {}, // Logic for next page
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
