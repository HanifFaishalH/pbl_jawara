import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Palet Warna
  static const Color primary = Color(0xFF26547C); // Warna teks utama & AppBar
  static const Color secondary = Color(0xFFEF476F); // Warna aksen
  static const Color third = Color(0xFF06D6A0); // Warna tombol utama
  static const Color fourth = Color(0xFFFFD166); // Warna ikon / highlight
  static const Color background = Color(0xFFFCFCFC); // Latar utama

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: background,

    // 🎨 Skema warna utama
    colorScheme: const ColorScheme.light(
      primary: primary, // untuk teks dan elemen utama
      onPrimary: Colors.white, // teks di atas warna primary
      secondary: secondary, // warna aksen (misal untuk floating button)
      onSecondary: Colors.white,
      tertiary: third, // tombol utama
      onTertiary: Colors.white,
      background: background,
      onBackground: primary,
      surface: Colors.white,
      onSurface: primary,
      error: Colors.red,
      onError: Colors.white,
    ),

    // 🧭 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 3,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // 🔘 Tombol utama
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: third,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // 📄 Teks
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primary),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
      bodyLarge: TextStyle(fontSize: 16, color: primary),
      bodyMedium: TextStyle(fontSize: 14, color: primary),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    ),

    // 🧩 Icon
    iconTheme: const IconThemeData(
      color: fourth,
      size: 24,
    ),

    // 🔔 Chip / Badge
    chipTheme: ChipThemeData(
      backgroundColor: secondary.withOpacity(0.9),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
