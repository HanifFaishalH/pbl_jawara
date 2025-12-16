import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jawaramobile_1/services/pesan_warga_service.dart';

class DaftarPenggunaChatScreen extends StatefulWidget {
  const DaftarPenggunaChatScreen({super.key});

  @override
  State<DaftarPenggunaChatScreen> createState() =>
      _DaftarPenggunaChatScreenState();
}

class _DaftarPenggunaChatScreenState extends State<DaftarPenggunaChatScreen> {
  final PesanWargaService _service = PesanWargaService();
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final data = await _service.getUserList();
      setState(() {
        _users = data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Pengguna'),
        backgroundColor: color.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user['user_nama_depan'][0]),
                  ),
                  title: Text(user['user_nama_depan']),
                  trailing: const Icon(Icons.chat),
                  onTap: () {
                    context.push(
                      '/chat-pesan-warga',
                      extra: {
                        'penerimaId': user['user_id'],
                        'penerimaNama': user['user_nama_depan'],
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
