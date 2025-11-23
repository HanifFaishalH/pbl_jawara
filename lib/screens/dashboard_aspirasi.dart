import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';
import '../widgets/status_chip.dart';
import 'edit_pesan_screen.dart';

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
  final List<PesanWarga> _pesanList = [
    PesanWarga(no: 1, pengirim: 'Varizky Naldiba Rimra', judul: 'Titootit', status: 'Diterima', tanggalDibuat: '16 Oktober 2025'),
    PesanWarga(no: 2, pengirim: 'Habibie Ed Dien', judul: 'Tes', status: 'Pending', tanggalDibuat: '28 September 2025'),
    PesanWarga(no: 3, pengirim: 'Ahmad Fulan', judul: 'Aspirasi RT 05', status: 'Pending', tanggalDibuat: '01 Oktober 2025'),
    PesanWarga(no: 4, pengirim: 'Siti Aminah', judul: 'Usul Perbaikan Jalan', status: 'Diterima', tanggalDibuat: '10 September 2025'),
  ];

  String? _filterJudul;
  String? _filterStatus;

  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? currentJudul = _filterJudul;
        String? currentStatus = _filterStatus;

        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter Pesan Warga', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(icon: const Icon(Icons.close, color: AppTheme.primary), onPressed: () => Navigator.pop(context)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Judul', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: currentJudul,
                    decoration: InputDecoration(
                      hintText: 'Cari judul...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (v) => currentJudul = v.isEmpty ? null : v,
                  ),
                  const SizedBox(height: 20),
                  Text('Status', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: currentStatus,
                    hint: const Text('-- Pilih Status --'),
                    items: ['Diterima', 'Pending', 'Ditolak'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setStateModal(() => currentStatus = v),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _filterJudul = null;
                            _filterStatus = null;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Reset Filter', style: TextStyle(color: AppTheme.primary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterJudul = currentJudul;
                            _filterStatus = currentStatus;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.third,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  List<PesanWarga> get _filteredPesanList {
    return _pesanList.where((p) {
      final byJudul = _filterJudul == null || p.judul.toLowerCase().contains(_filterJudul!.toLowerCase());
      final byStatus = _filterStatus == null || p.status.toLowerCase() == _filterStatus!.toLowerCase();
      return byJudul && byStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredPesanList;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Dashboard Aspirasi Warga'),
        backgroundColor: AppTheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _showFilterModal(context),
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    label: const Text('Filter', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(AppTheme.primary.withOpacity(0.1)),
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
                      dataRowColor: MaterialStateProperty.all(Colors.white),
                      columns: const [
                        DataColumn(label: Text('NO')),
                        DataColumn(label: Text('PENGIRIM')),
                        DataColumn(label: Text('JUDUL')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('TANGGAL')),
                        DataColumn(label: Text('AKSI')),
                      ],
                      rows: filteredList.map((pesan) {
                        return DataRow(
                          cells: [
                            DataCell(Text(pesan.no.toString(), style: const TextStyle(color: AppTheme.primary))),
                            DataCell(Text(pesan.pengirim, style: const TextStyle(color: AppTheme.primary))),
                            DataCell(Text(pesan.judul, style: const TextStyle(color: AppTheme.primary))),
                            DataCell(StatusChip(status: pesan.status)),
                            DataCell(Text(pesan.tanggalDibuat, style: const TextStyle(color: AppTheme.primary))),
                            DataCell(
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, color: AppTheme.secondary),
                                onSelected: (value) {
                                  if (value == 'Edit') {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditPesanScreen()));
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'Detail', child: Text('Detail')),
                                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'Hapus', child: Text('Hapus')),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
