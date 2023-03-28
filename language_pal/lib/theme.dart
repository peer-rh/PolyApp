import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: lightColorScheme,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.nunito(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: darkColorScheme,
  textTheme: TextTheme(
    headlineLarge: GoogleFonts.nunito(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.nunito(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.nunito(
      fontSize: 24,
      fontWeight: FontWeight.w300,
    ),
    titleMedium: GoogleFonts.nunito(
      fontSize: 20,
      fontWeight: FontWeight.w400,
    ),
  ),
);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF006E28),
  primaryContainer: Color(0xFF72FE88),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryContainer: Color(0xFF002107),
  secondary: Color(0xFF516350),
  secondaryContainer: Color(0xFFD4E8D0),
  onSecondary: Color(0xFFFFFFFF),
  onSecondaryContainer: Color(0xFF0F1F10),
  tertiary: Color(0xFF006E1E),
  tertiaryContainer: Color(0xFF99F896),
  onTertiary: Color(0xFFFFFFFF),
  onTertiaryContainer: Color(0xFF002204),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  outline: Color(0xFF72796F),
  background: Color(0xFFFCFDF7),
  onBackground: Color(0xFF1A1C19),
  surface: Color(0xFFFCFDF7),
  onSurface: Color(0xFF1A1C19),
  surfaceVariant: Color(0xFFDEE5D9),
  onSurfaceVariant: Color(0xFF424940),
  inverseSurface: Color(0xFF2F312D),
  onInverseSurface: Color(0xFFF0F1EB),
  inversePrimary: Color(0xFF53E16F),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF006E28),
  outlineVariant: Color(0xFFC2C9BD),
  scrim: Color(0xFF000000),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF53E16F),
  primaryContainer: Color(0xFF00531C),
  onPrimary: Color(0xFF003911),
  onPrimaryContainer: Color(0xFF72FE88),
  secondary: Color(0xFFB8CCB5),
  secondaryContainer: Color(0xFF3A4B39),
  onSecondary: Color(0xFF243424),
  onSecondaryContainer: Color(0xFFD4E8D0),
  tertiary: Color(0xFF7EDB7D),
  tertiaryContainer: Color(0xFF005314),
  onTertiary: Color(0xFF00390B),
  onTertiaryContainer: Color(0xFF99F896),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  outline: Color(0xFF8C9389),
  background: Color(0xFF1A1C19),
  onBackground: Color(0xFFE2E3DD),
  surface: Color(0xFF1A1C19),
  onSurface: Color(0xFFC6C7C1),
  surfaceVariant: Color(0xFF424940),
  onSurfaceVariant: Color(0xFFC2C9BD),
  inverseSurface: Color(0xFFE2E3DD),
  onInverseSurface: Color(0xFF1A1C19),
  inversePrimary: Color(0xFF006E28),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF53E16F),
  outlineVariant: Color(0xFF424940),
  scrim: Color(0xFF000000),
);
