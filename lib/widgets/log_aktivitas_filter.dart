import 'package:flutter/material.dart';

class LogAktivitasFilter extends StatefulWidget {
  const LogAktivitasFilter({super.key});

  @override
  State<LogAktivitasFilter> createState() => _LogAktivitasFilterState();
}

class _LogAktivitasFilterState extends State<LogAktivitasFilter> {
  final _cariController = TextEditingController();
  DateTime? _from;
  DateTime? _to;

  Future<void> _pickDate(BuildContext context, bool isFrom) async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (selected != null) {
      setState(() {
        if (isFrom) {
          _from = selected;
        } else {
          _to = selected;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _cariController,
          decoration: const InputDecoration(
            labelText: "Cari deskripsi / aktor",
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, true),
                icon: const Icon(Icons.date_range),
                label: Text(_from == null
                    ? "Dari Tanggal"
                    : "${_from!.day}-${_from!.month}-${_from!.year}"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickDate(context, false),
                icon: const Icon(Icons.event),
                label: Text(_to == null
                    ? "Sampai Tanggal"
                    : "${_to!.day}-${_to!.month}-${_to!.year}"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Catatan: tombol Terapkan di dialog akan memanggil logika filter.",
            style:
                theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        )
      ],
    );
  }
}
