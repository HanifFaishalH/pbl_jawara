import 'package:flutter/material.dart';
import '../../widgets/broadcast/tambah_broadcast_form.dart';

class TambahBroadcastScreen extends StatelessWidget {
  const TambahBroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: const Text("Tambah Broadcast", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: color.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: TambahBroadcastForm(), // mode tambah
        ),
      ),
    );
  }
}
