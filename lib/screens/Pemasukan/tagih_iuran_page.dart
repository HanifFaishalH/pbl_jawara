import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/pemasukan/tagih_iuran/tagih_iuran_header.dart';
import '../../widgets/pemasukan/tagih_iuran/jenis_iuran_section.dart';
import '../../widgets/pemasukan/tagih_iuran/tanggal_section.dart';
import '../../widgets/pemasukan/tagih_iuran/tagih_iuran_actions.dart';

class TagihIuranPage extends StatefulWidget {
  const TagihIuranPage({super.key});

  @override
  State<TagihIuranPage> createState() => _TagihIuranPageState();
}

class _TagihIuranPageState extends State<TagihIuranPage> {
  String? _selectedIuran;
  DateTime? _selectedDate;

  final List<Map<String, String>> _availableIuran = [
    {
      "no": "1",
      "nama": "Bersih Desa",
      "jenis": "Iuran Bulanan",
      "nominal": "Rp 10.000",
    },
    {
      "no": "2",
      "nama": "Sumbangan Acara",
      "jenis": "Iuran Khusus",
      "nominal": "Rp 20.000",
    },
    {
      "no": "3",
      "nama": "Sewa Lapangan",
      "jenis": "Iuran Khusus",
      "nominal": "Rp 10.000",
    },
  ];

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _tagihIuran() {
    if (_selectedIuran == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harap pilih jenis iuran dan tanggal"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Iuran berhasil ditagih ke semua keluarga aktif"),
        backgroundColor: Colors.green,
      ),
    );

    // Future.delayed(const Duration(seconds: 1), () {
    //   context.pop();
    // });
  }

  void _resetForm() {
    setState(() {
      _selectedIuran = null;
      _selectedDate = null;
    });
  }

  Map<String, String>? get _selectedIuranData {
    if (_selectedIuran == null) return null;
    return _availableIuran.firstWhere((iuran) => iuran['no'] == _selectedIuran);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: Text(
          "Tagih Iuran",
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/menu-pemasukan'),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TagihIuranHeader(),
            const SizedBox(height: 24),
            JenisIuranSection(
              availableIuran: _availableIuran,
              selectedIuran: _selectedIuran,
              selectedIuranData: _selectedIuranData,
              onIuranChanged: (value) {
                setState(() {
                  _selectedIuran = value;
                });
              },
              onIuranCleared: () {
                setState(() {
                  _selectedIuran = null;
                });
              },
            ),
            const SizedBox(height: 24),
            TanggalSection(
              selectedDate: _selectedDate,
              onDateSelected: () => _selectDate(context),
            ),
            const SizedBox(height: 32),
            TagihIuranActions(onReset: _resetForm, onTagih: _tagihIuran),
          ],
        ),
      ),
    );
  }
}
