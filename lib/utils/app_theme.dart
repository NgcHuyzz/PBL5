import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_sizes.dart';

class AppTheme {
  // Primary Colors - Modern Teal
  static const Color primary = Color(0xFF006D5B);
  static const Color primaryLight = Color(0xFFE0F2F1);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color accent = Color(0xFFFF8F00);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color success = Color(0xFF2E7D32);
  static const Color info = Color(0xFF1976D2);

  // Background
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardColor = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  static const Color outlineVariant = Color(0xFFE3BEBB);

  static const Color surfaceContainerLow = Color(0xFFF6F3F2);
  static const Color tertiaryContainer = Color(0xFFB40B3C);
  static const Color secondary = Color(0xFF3B6934);

  // Gradients
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static final LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark, Color(0xFF00332A)],
  );

  static final LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFF6F00)],
  );

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 15,
      offset: const Offset(0, 2),
    ),
  ];

  // Text Styles
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: AppSizes.fontHeadlineLarge,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: AppSizes.fontHeadlineMedium,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: AppSizes.fontTitleLarge,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: AppSizes.fontTitleMedium,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: AppSizes.fontBody,
    color: textSecondary,
  );

  static TextStyle bodySmall = GoogleFonts.inter(fontSize: AppSizes.fontCaption, color: textHint);

  static TextStyle caption = GoogleFonts.inter(
    fontSize: AppSizes.fontCaption,
    color: textHint,
    letterSpacing: 0.5,
  );

  static TextStyle buttonText = GoogleFonts.poppins(
    fontSize: AppSizes.fontTitleMedium,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
