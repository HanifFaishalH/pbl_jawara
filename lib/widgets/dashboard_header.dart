import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardHeader extends StatefulWidget {
  final String? title;       // opsional: untuk role-specific title
  final String? subtitle;    // opsional: untuk keterangan tambahan

  const DashboardHeader({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String userName = 'User';
  String userRole = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final namaDepan = prefs.getString('user_nama_depan') ?? 'User';
    final roleId = prefs.getInt('auth_role_id') ?? 0;

    setState(() {
      userName = namaDepan;
      userRole = _getRoleName(roleId);
    });
  }

  String _getRoleName(int id) {
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: color.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.shadow.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 👤 Avatar dan Sapaan
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.primary.withOpacity(0.1),
                    ),
                    child: Icon(
                      FontAwesomeIcons.user,
                      color: color.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nama dan peran
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hai, $userName 👋',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.title ?? userRole,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // 🔔 Ikon Notifikasi
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifikasi dalam pengembangan'),
                        ),
                      );
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.bell,
                      color: color.primary,
                      size: 22,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
