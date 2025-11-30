import 'package:flutter/material.dart';
import 'package:jawaramobile_1/services/auth_service.dart'; // Pastikan import ini ada
import 'theme/AppTheme.dart';
import 'app_router.dart';

void main() async {
  // 1. Wajib dipanggil jika main() menjadi async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load Token dari penyimpanan HP ke variabel static aplikasi
  await AuthService.loadSession(); 

  // 3. Jalankan aplikasi setelah sesi dimuat
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jawara Apps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}