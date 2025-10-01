import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color secondaryLight = Color(0xFF42A5F5);
  static const Color secondaryDark = Color(0xFF0D47A1);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF9800); // Orange
  static const Color accentLight = Color(0xFFFFB74D);
  static const Color accentDark = Color(0xFFE65100);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF424242);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );
  
  // Tier Colors
  static const Color studentColor = Color(0xFF4CAF50);
  static const Color graduateColor = Color(0xFF2196F3);
  static const Color professionalColor = Color(0xFF9C27B0);
  static const Color adminColor = Color(0xFFFF5722);
  
  // Career Industry Colors
  static const Map<String, Color> industryColors = {
    'Information Technology': Color(0xFF2196F3),
    'Healthcare': Color(0xFF4CAF50),
    'Design': Color(0xFFE91E63),
    'Agriculture': Color(0xFF8BC34A),
    'Finance': Color(0xFFFF9800),
    'Education': Color(0xFF9C27B0),
    'Engineering': Color(0xFF607D8B),
    'Marketing': Color(0xFFFF5722),
    'Media': Color(0xFF795548),
    'Law': Color(0xFF3F51B5),
    'Science': Color(0xFF00BCD4),
    'Arts': Color(0xFFE91E63),
    'Sports': Color(0xFFFFC107),
    'Hospitality': Color(0xFFFF9800),
    'Real Estate': Color(0xFF8BC34A),
    'Manufacturing': Color(0xFF607D8B),
    'Transportation': Color(0xFF9E9E9E),
    'Energy': Color(0xFFFFC107),
    'Government': Color(0xFF3F51B5),
    'Non-Profit': Color(0xFF4CAF50),
  };
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}
