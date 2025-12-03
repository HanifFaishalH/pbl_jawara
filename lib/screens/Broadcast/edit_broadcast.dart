import 'package:flutter/material.dart';
import '../../widgets/broadcast/tambah_broadcast_form.dart';

class EditBroadcastScreen extends StatelessWidget {
  final Map<String, dynamic> broadcastData;
  const EditBroadcastScreen({super.key, required this.broadcastData});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color.primary,
        title: const Text("Edit Broadcast", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: color.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: TambahBroadcastForm(initialData: broadcastData),
        ),
      ),
    );
  }
}
