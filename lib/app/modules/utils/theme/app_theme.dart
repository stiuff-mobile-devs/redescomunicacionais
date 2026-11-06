import 'package:flutter/material.dart';

// ============================================================
// TEMA BRANCO
// ============================================================

final ThemeData appThemeDataLight = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  scaffoldBackgroundColor: Colors.white,

  colorScheme: ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.cyan.shade600,

    surface: Colors.white,
    onSurface: Colors.black,

    primaryContainer: Colors.black,
    onPrimaryContainer: Colors.white,

    surfaceContainerHighest: Colors.grey.shade100,
    onSurfaceVariant: Colors.grey.shade700,

    outline: Colors.grey.shade400,
    outlineVariant: Colors.grey.shade300,

    onPrimary: Colors.white,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,

    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      color: Colors.black,
    ),
    titleLarge: TextStyle(
      color: Colors.black,
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(
      color: Colors.black,
    ),

    hintStyle: TextStyle(
      color: Colors.grey.shade600,
    ),

    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.shade400,
      ),
    ),

    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.black,
        width: 2,
      ),
    ),
  ),
);

// ============================================================
// TEMA CLÁSSICO
// AZUL / PRETO
// ============================================================

final ThemeData appThemeDataClassic = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // ----------------------------------------------------------
  // FUNDO PRINCIPAL
  // ----------------------------------------------------------

  scaffoldBackgroundColor: const Color(0xFF121212),

  // ----------------------------------------------------------
  // CORES
  // ----------------------------------------------------------

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF2563EB),
    onPrimary: Colors.white,

    primaryContainer: Color(0xFF1E3A8A),
    onPrimaryContainer: Colors.white,

    secondary: Color(0xFF06B6D4),
    onSecondary: Colors.white,

    surface: Color(0xFF1E1E1E),
    onSurface: Colors.white,

    surfaceContainer: Color(0xFF1E1E1E),
    surfaceContainerHigh: Color(0xFF242424),
    surfaceContainerHighest: Color(0xFF2A2A2A),

    onSurfaceVariant: Color(0xFFBDBDBD),

    outline: Color(0xFF555555),
    outlineVariant: Color(0xFF3A3A3A),

    inverseSurface: Colors.white,
    onInverseSurface: Colors.black,
  ),

  // ----------------------------------------------------------
  // APP BAR
  // ----------------------------------------------------------

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,

    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),

  // ----------------------------------------------------------
  // TEXTOS
  // ----------------------------------------------------------

  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: Colors.white,
    ),

    bodyMedium: TextStyle(
      color: Colors.white,
    ),

    bodySmall: TextStyle(
      color: Color(0xFFBDBDBD),
    ),

    titleLarge: TextStyle(
      color: Colors.white,
    ),

    titleMedium: TextStyle(
      color: Colors.white,
    ),

    titleSmall: TextStyle(
      color: Color(0xFFBDBDBD),
    ),
  ),

  // ----------------------------------------------------------
  // CAMPOS DE TEXTO
  // ----------------------------------------------------------

  inputDecorationTheme: const InputDecorationTheme(
    labelStyle: TextStyle(
      color: Colors.white,
    ),

    hintStyle: TextStyle(
      color: Color(0xFF9E9E9E),
    ),

    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF555555),
      ),
    ),

    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Color(0xFF2563EB),
        width: 2,
      ),
    ),

    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
      ),
    ),

    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.red,
        width: 2,
      ),
    ),
  ),

  // ----------------------------------------------------------
  // CARD
  // ----------------------------------------------------------

  cardTheme: const CardThemeData(
    color: Color(0xFF1E1E1E),
    elevation: 0,
  ),

  // ----------------------------------------------------------
  // DIVISOR
  // ----------------------------------------------------------

  dividerTheme: const DividerThemeData(
    color: Color(0xFF3A3A3A),
    thickness: 1,
    space: 1,
  ),

  // ----------------------------------------------------------
  // CHECKBOX
  // ----------------------------------------------------------

  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xFF2563EB);
        }

        return Colors.transparent;
      },
    ),

    checkColor: const WidgetStatePropertyAll<Color>(
      Colors.white,
    ),

    side: const BorderSide(
      color: Color(0xFF777777),
      width: 2,
    ),
  ),

  // ----------------------------------------------------------
  // BOTÃO ELEVATED
  // ----------------------------------------------------------

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,

      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  // ----------------------------------------------------------
  // BOTÃO OUTLINED
  // ----------------------------------------------------------

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,

      side: const BorderSide(
        color: Color(0xFF777777),
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
);