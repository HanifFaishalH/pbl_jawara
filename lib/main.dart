import 'package:flutter/material.dart';
import 'theme/AppTheme.dart';
import 'app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jawara Apps',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Gunakan tema ungu kamu
      routerConfig: appRouter,
    );
  }
}
