import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _theme(Brightness.light, DesignTokens.light);
  }

  static ThemeData get darkTheme {
    return _theme(Brightness.dark, DesignTokens.dark);
  }

  static ThemeData _theme(Brightness brightness, DesignTokens t) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: t.bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: t.accent,
        onPrimary: Colors.white,
        secondary: t.accentDeep,
        onSecondary: t.bg,
        error: t.danger,
        onError: t.bg,
        surface: t.surface,
        onSurface: t.text,
        onSurfaceVariant: t.text2,
        outline: t.border,
      ),
      textTheme:
          GoogleFonts.nunitoTextTheme(
            dark ? ThemeData.dark().textTheme : null,
          ).copyWith(
            displayLarge: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: t.text,
            ),
            titleLarge: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
            titleMedium: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
            bodyLarge: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
            bodyMedium: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: t.text2,
            ),
            bodySmall: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: t.muted,
            ),
          ),
      cardTheme: CardThemeData(
        color: t.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: t.bg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: t.text,
        ),
        iconTheme: IconThemeData(color: t.text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: t.faint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.accent, width: 1.5),
        ),
      ),
    );
  }
}
