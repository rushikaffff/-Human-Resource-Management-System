import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Brand Colors
  static const Color lightBlue = Color(0xFFC1E8FF);
  static const Color softBlue = Color(0xFF7DA0CA);
  static const Color steelBlue = Color(0xFF5483B3);
  static const Color deepNavy = Color(0xFF052659);
  static const Color darkestNavy = Color(0xFF021024);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // 🎨 Color Scheme (Material 3 safe)
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepNavy,
        primary: deepNavy,
        secondary: steelBlue,
        tertiary: softBlue,
        surface: Colors.white,
        background: lightBlue.withOpacity(0.1),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkestNavy,
        onBackground: darkestNavy,
      ),

      scaffoldBackgroundColor: Colors.grey.shade50,

      // ✍️ Typography
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: darkestNavy,
        displayColor: deepNavy,
      ),

      // 🧭 AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: deepNavy,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // 🔘 Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // 📝 TextFields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: deepNavy, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: Colors.grey),
      ),

      
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      ),
    );
  }
}
