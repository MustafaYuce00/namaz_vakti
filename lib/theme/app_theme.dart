import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ana renkler
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF26A69A);
  static const Color accentColor = Color(0xFFFFA000);
  
  // Arkaplan ve metin renkleri
  static const Color darkBgColor = Color(0xFF121212);
  static const Color lightBgColor = Color(0xFFF5F5F5);
  static const Color darkTextColor = Color(0xFF212121);
  static const Color lightTextColor = Color(0xFFFFFFFF);
  
  // Namaz vakitleri için renkler
  static const Color fajrColor = Color(0xFF5E35B1);
  static const Color sunriseColor = Color(0xFFFFB300);
  static const Color dhuhrColor = Color(0xFF43A047);
  static const Color asrColor = Color(0xFF26A69A);
  static const Color maghribColor = Color(0xFFEC407A);
  static const Color ishaColor = Color(0xFF3949AB);
  
  // Tema seçenekleri
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightBgColor,
      background: lightBgColor,
      error: Colors.red.shade700,
    ),
    scaffoldBackgroundColor: lightBgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkBgColor,
      background: darkBgColor,
      error: Colors.red.shade300,
    ),
    scaffoldBackgroundColor: darkBgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBgColor,
      foregroundColor: lightTextColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkBgColor.withOpacity(0.7),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: lightTextColor,
        backgroundColor: primaryColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
  );
  
  // Namaz vakti rengi al
  static Color getPrayerTimeColor(String prayerName) {
    switch (prayerName) {
      case 'İmsak':
        return fajrColor;
      case 'Güneş':
        return sunriseColor;
      case 'Öğle':
        return dhuhrColor;
      case 'İkindi':
        return asrColor;
      case 'Akşam':
        return maghribColor;
      case 'Yatsı':
        return ishaColor;
      default:
        return primaryColor;
    }
  }
}