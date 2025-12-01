import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_admin.dart';
import 'dashboard_bendahara.dart';
import 'dashboard_sekretaris.dart';
import 'dashboard_rw.dart';
import 'dashboard_rt.dart';
import 'dashboard_warga.dart';

class DashboardSelector extends StatefulWidget {
  const DashboardSelector({super.key});

  @override
  State<DashboardSelector> createState() => _DashboardSelectorState();
}

class _DashboardSelectorState extends State<DashboardSelector> {
  int? roleId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roleId = prefs.getInt('auth_role_id');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    switch (roleId) {
      case 1:
        return const DashboardAdminScreen();
      case 2:
        return const DashboardRwScreen();
      case 3:
        return const DashboardRtScreen();
      case 4:
        return const DashboardSekretarisScreen();
      case 5:
        return const DashboardBendaharaScreen();
      case 6:
        return const DashboardWargaScreen();
      default:
        return Scaffold(
          body: Center(child: Text('Role tidak dikenali: $roleId')),
        );
    }
  }
}
