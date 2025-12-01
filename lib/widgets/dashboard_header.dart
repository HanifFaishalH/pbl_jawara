import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardHeader extends StatelessWidget {
  final String? title;
  final String? subtitle; // ✅ Tambahkan ini

  const DashboardHeader({
    super.key,
    this.title,
    this.subtitle, // ✅ Tambahkan juga di konstruktor
  });

  Future<Map<String, String>> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final nama = prefs.getString('user_nama_depan') ?? 'User';
    final roleId = prefs.getInt('auth_role_id') ?? 0;

    return {
      'nama': nama,
      'role': _getRoleName(roleId),
    };
  }

  static String _getRoleName(int id) {
    switch (id) {
      case 1:
        return "Admin";
      case 2:
        return "Ketua RW";
      case 3:
        return "Ketua RT";
      case 4:
        return "Sekretaris";
      case 5:
        return "Bendahara";
      case 6:
        return "Warga";
      default:
        return "Pengguna";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return FutureBuilder<Map<String, String>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        final userName = snapshot.data?['nama'] ?? 'User';
        final userRole = snapshot.data?['role'] ?? 'Pengguna';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.shadow.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🧍‍♂️ Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: color.primaryContainer,
                child: Icon(
                  FontAwesomeIcons.user,
                  color: color.onPrimaryContainer,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // 🧾 Nama, role, dan subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Halo, $userName",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title ?? userRole,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: color.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // 🔔 Notifikasi
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.bell,
                  color: color.primary,
                  size: 22,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifikasi sedang dikembangkan'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
