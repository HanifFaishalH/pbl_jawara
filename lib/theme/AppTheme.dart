import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Palet Warna
  static const Color primaryOrange = Color(0xFFFF8100); // Tombol utama, header
  static const Color highlightYellow = Color(0xFFFFE381); // Aksen
  static const Color warmCream = Color(0xFFFFFDE7); // Background
  static const Color darkBrown = Color(0xFF4E342E); // Teks utama

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // 🌿 Warna latar belakang lembut
    scaffoldBackgroundColor: warmCream,

    colorScheme: ColorScheme(
      primary: primaryOrange,
      onPrimary: Colors.white,
      primaryContainer: highlightYellow,
      onPrimaryContainer: darkBrown,
      secondary: highlightYellow,
      onSecondary: darkBrown,
      secondaryContainer: warmCream,
      onSecondaryContainer: darkBrown,
      background: warmCream,
      onBackground: darkBrown,
      surface: warmCream,
      onSurface: darkBrown,
      surfaceVariant: highlightYellow.withOpacity(0.2),
      onSurfaceVariant: darkBrown,
      error: Colors.red.shade700,
      onError: Colors.white,
      errorContainer: Colors.red.shade100,
      onErrorContainer: Colors.red.shade900,
      brightness: Brightness.light,
    ),

    // 🧭 AppBar (header)
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // 🔘 Tombol utama (CTA)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    // 📄 Teks
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: darkBrown),
      titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: darkBrown),
      bodyLarge: TextStyle(fontSize: 16.0, color: darkBrown),
      bodyMedium: TextStyle(fontSize: 14.0, color: darkBrown),
      labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: darkBrown),
    ),

    // 🔔 Chip, Badge, dan elemen kecil
    chipTheme: ChipThemeData(
      backgroundColor: highlightYellow.withOpacity(0.8),
      labelStyle: const TextStyle(color: darkBrown),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
