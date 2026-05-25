// lib/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HerressoTheme {
  static const Color primary = Color.fromARGB(255, 194, 117, 65);     
  static const Color primaryLight = Color.fromARGB(255, 237, 79, 51);
  static const Color primaryDark = Color.fromARGB(255, 224, 80, 41);
  static const Color secondary = Color(0xFFFFC107);   
  static const Color accent = Color(0xFFEF5350);      
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFF999999);
  static const Color border = Color(0xFFE0E0E0);
  static const Color success = Color.fromARGB(255, 185, 83, 40);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: secondary,
          surface: surface,
          // ignore: deprecated_member_use
          background: background,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: primary,
          unselectedItemColor: textLight,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: primaryLight.withValues(alpha: 0.15),
          selectedColor: primary,
          labelStyle: const TextStyle(fontSize: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}

class AppStrings {
  static const String appName = 'Herresso';
  static const String tagline = 'Trouvez votre logement au Burkina';

  // Villes
  static const List<String> villes = [
    'Ouagadougou',
    'Bobo-Dioulasso',
    'Koudougou',
    'Banfora',
    'Ouahigouya',
    'Tenkodogo',
    'Fada N\'Gourma',
  ];

  // Types de bien
  static const List<String> typesBien = [
    'Tous',
    'Villa',
    'Appartement',
    'Chambre salon ',
    'Cour commune',
    'Cour unique',
    'Résidence',
    'Boutique',
    'Bureau',
  ];
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
}

// Alias kept for older codebases that referenced AppTheme
class AppTheme {
  static const Color primary = HerressoTheme.primary;
  static const Color primaryLight = HerressoTheme.primaryLight;
  static const Color primaryDark = HerressoTheme.primaryDark;
  static const Color secondary = HerressoTheme.secondary;
  static const Color accent = HerressoTheme.accent;
  static const Color background = HerressoTheme.background;
  static const Color surface = HerressoTheme.surface;
  static const Color textPrimary = HerressoTheme.textPrimary;
  static const Color textSecondary = HerressoTheme.textSecondary;
  static const Color textLight = HerressoTheme.textLight;
  static const Color border = HerressoTheme.border;
  static const Color success = HerressoTheme.success;
  static const Color warning = HerressoTheme.warning;
  static const Color error = HerressoTheme.error;

  static ThemeData get theme => HerressoTheme.theme;
}
