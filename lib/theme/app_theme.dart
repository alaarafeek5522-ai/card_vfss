import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color redVF    = Color(0xFFE60028);
  static const Color darkRed  = Color(0xFF8B0000);
  static const Color black    = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);
  static const Color cardBg   = Color(0xFF1C1C1C);
  static const Color gold     = Color(0xFFFFD700);
  static const Color white    = Color(0xFFFFFFFF);
  static const Color grey     = Color(0xFF888888);

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
