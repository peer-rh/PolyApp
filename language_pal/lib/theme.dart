import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  textTheme: textTheme,
  splashFactory: NoSplash.splashFactory,
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme, // TODO
  textTheme: textTheme,
);

final textTheme = TextTheme(
  displayLarge: GoogleFonts.nunito(
    fontSize: 32,
    fontWeight: FontWeight.w500,
  ),
  displayMedium: GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w500,
  ),
  displaySmall: GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  ),
  labelLarge: GoogleFonts.nunito(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  ),
  titleSmall: GoogleFonts.notoSans(
    fontSize: 20,
    fontWeight: FontWeight.w400,
  ),
  bodyLarge: GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  ),
  bodyMedium: GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  ),
  bodySmall: GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  ),
  labelSmall: GoogleFonts.notoSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
  ),
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFFF5154),
  onPrimary: Color(0xFFF7F7F7),
  secondary: Color(0xFFA80003),
  onSecondary: Color(0xFFF7F7F7),
  error: Color(0xFFFF5154),
  onError: Color(0xFFF7F7F7),
  outline: Color(0xFFDBDBDB),
  background: Color(0xFFF7F7F7),
  onBackground: Color(0xFF27474E),
  surface: Color(0xFFDBDBDB),
  onSurface: Color(0xFF27474E),
  surfaceVariant: Color(0xFFDEE5D9),
  onSurfaceVariant: Color(0xFFF7F7F7),
  inverseSurface: Color(0xFFDBDBDB),
  onInverseSurface: Color(0xFFF7F7F7),
);
