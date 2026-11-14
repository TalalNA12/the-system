import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';





class AppTheme {
  
  static const Color background = Color(0xFF020610);
  static const Color windowGlass = Color(0xFF051124);
  static const Color windowGlassDeep = Color(0xFF030A18);
  static const Color electricCyan = Color(0xFF00C8FF);
  static const Color iceBlue = Color(0xFF4AAFFF);
  static const Color softBlue = Color(0xFF8AD4FF);
  static const Color textWhite = Color(0xFFEAF4FF);
  static const Color textMuted = Color(0xFF7E9DBE);
  static const Color textDim = Color(0xFF4D6D8E);
  static const Color warningRed = Color(0xFFFF3B69);
  static const Color successGreen = Color(0xFF40E0A0);

  
  static const Color primaryGlow = electricCyan;
  static const Color secondaryGlow = softBlue;
  static const Color primaryText = textWhite;
  static const Color secondaryText = textMuted;
  static const Color holographicPanel = windowGlass;
  static const Color panelOverlay = Color(0xFF081A36);

  
  static List<BoxShadow> get windowBloom => [
    BoxShadow(
      color: electricCyan.withValues(alpha: 0.15),
      blurRadius: 18,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x99000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  
  static List<BoxShadow> get warningBloom => [
    BoxShadow(
      color: warningRed.withValues(alpha: 0.20),
      blurRadius: 18,
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0x99000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  
  static List<Shadow> get headerGlow => [
    Shadow(color: electricCyan.withValues(alpha: 0.6), blurRadius: 8),
  ];

  static List<Shadow> get warningGlow => [
    Shadow(color: warningRed.withValues(alpha: 0.8), blurRadius: 8),
  ];

  
  static TextStyle sans({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = textWhite,
    double letterSpacing = 0.5,
    double? height,
    bool glow = false,
  }) {
    final shadows = glow ? headerGlow : null;
    try {
      return GoogleFonts.jost(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        shadows: shadows,
      );
    } catch (_) {
      try {
        return GoogleFonts.rajdhani(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
          shadows: shadows,
        );
      } catch (_) {
        return TextStyle(
          fontFamily: 'sans-serif',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          letterSpacing: letterSpacing,
          height: height,
          shadows: shadows,
        );
      }
    }
  }

  
  static TextStyle titleStyle({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w700,
    Color color = textWhite,
    double letterSpacing = 1.5,
    double? height,
    bool glow = true,
  }) {
    return sans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      glow: glow,
    );
  }

  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: electricCyan,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        secondary: iceBlue,
        surface: windowGlass,
        error: warningRed,
        onPrimary: background,
        onSecondary: textWhite,
        onSurface: textWhite,
        onError: textWhite,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: electricCyan,
        unselectedItemColor: textMuted.withValues(alpha: 0.6),
        selectedLabelStyle: sans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        unselectedLabelStyle: sans(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: windowGlass,
        contentTextStyle: sans(
          color: textWhite,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
          side: BorderSide(
            color: electricCyan.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
