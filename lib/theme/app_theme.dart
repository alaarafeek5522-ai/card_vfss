import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color redVF    = Color(0xFFE60028);
  static const Color darkRed  = Color(0xFF8B0000);
  static const Color black    = Color(0xFF080808);
  static const Color darkCard = Color(0xFF111111);
  static const Color cardBg   = Color(0xFF1A1A1A);
  static const Color gold     = Color(0xFFFFD700);
  static const Color white    = Color(0xFFFFFFFF);
  static const Color grey     = Color(0xFF777777);
  static const Color accent   = Color(0xFF4A90D9);

  static BoxDecoration glassCard({Color? borderColor}) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.05),
        Colors.white.withOpacity(0.02),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: (borderColor ?? redVF).withOpacity(0.25),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: (borderColor ?? redVF).withOpacity(0.08),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: redVF,
      secondary: gold,
      surface: darkCard,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.cairo(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
