import 'package:flutter/material.dart';
import '../theme/AppTheme.dart';
import 'package:go_router/go_router.dart';

class PermintaanAkun {
  final int no;
  final String nama;
  final String nik;
  final String email;
  final String jenisKelamin;
  final String fotoIdentitasUrl;

  PermintaanAkun({
    required this.no,
    required this.nama,
    required this.nik,
    required this.email,
    required this.jenisKelamin,
    required this.fotoIdentitasUrl,
  });
}

class PenerimaanWargaScreen extends StatefulWidget {
  const PenerimaanWargaScreen({super.key});

  @override
  State<PenerimaanWargaScreen> createState() => _PenerimaanWargaScreenState();
}

class _PenerimaanWargaScreenState extends State<PenerimaanWargaScreen> {
  final List<PermintaanAkun> _permintaanList = [
    PermintaanAkun(
      no: 1,
      nama: 'Rendha Putra Rahmadya',
      nik: '3505111512040002',
      email: 'rendhazupez@gmail.com',
      jenisKelamin: 'L',
      fotoIdentitasUrl:
      'https://placehold.co/100x70/06D6A0/FFFFFF?text=Identitas+1',
    ),
    PermintaanAkun(
      no: 2,
      nama: 'Anti Micin',
      nik: '1234567890987654',
      email: 'antimicin3@gmail.com',
      jenisKelamin: 'L',
      fotoIdentitasUrl:
      'https://placehold.co/100x70/26547C/FFFFFF?text=Identitas+2',
    ),
    PermintaanAkun(
      no: 3,
      nama: 'Ijat',
      nik: '2025202520252025',
      email: 'ijat1@gmail.com',
      jenisKelamin: 'P',
      fotoIdentitasUrl:
      'https://placehold.co/100x70/EF476F/FFFFFF?text=Identitas+3',
    ),
  ];

  String? _filterNama;
  String? _filterJenisKelamin;

  void _showFilterModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String? currentNama = _filterNama;
        String? currentJK = _filterJenisKelamin;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppTheme.background,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filter Penerimaan Warga',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.secondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari nama...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => currentNama = v,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: currentJK,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      labelText: 'Jenis Kelamin',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                      DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                    ],
                    onChanged: (v) => setModalState(() => currentJK = v),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _filterNama = null;
                            _filterJenisKelamin = null;
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary)),
                        child: const Text('Reset',
                            style: TextStyle(color: AppTheme.primary)),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterNama = currentNama;
                            _filterJenisKelamin = currentJK;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.third,
                        ),
                        child: const Text('Terapkan'),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<PermintaanAkun> get _filteredList {
    return _permintaanList.where((data) {
      final byNama = _filterNama == null ||
          data.nama.toLowerCase().contains(_filterNama!.toLowerCase());
      final byJK = _filterJenisKelamin == null ||
          data.jenisKelamin.toLowerCase() ==
              _filterJenisKelamin!.toLowerCase();
      return byNama && byJK;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredList;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: const Text('Penerimaan Warga',
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.goNamed('aspirasi'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () => _showFilterModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    label: const Text('Filter',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          AppTheme.primary.withOpacity(0.1)),
                      headingTextStyle: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold),
                      columns: const [
                        DataColumn(label: Text('NO')),
                        DataColumn(label: Text('NAMA')),
                        DataColumn(label: Text('NIK')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('JENIS KELAMIN')),
                        DataColumn(label: Text('FOTO IDENTITAS')),
                      ],
                      rows: filteredList.map((d) {
                        return DataRow(
                          cells: [
                            DataCell(Text(d.no.toString())),
                            DataCell(Text(d.nama)),
                            DataCell(Text(d.nik)),
                            DataCell(Text(d.email)),
                            DataCell(Text(
                                d.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan')),
                            DataCell(
                              InkWell(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16)),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          child: Image.network(
                                            d.fotoIdentitasUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(d.nama,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    d.fotoIdentitasUrl,
                                    width: 70,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
