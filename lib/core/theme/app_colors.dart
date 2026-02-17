import 'package:flutter/material.dart';

/// Application color palette.
/// Centralized color definitions for consistent theming.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Colors
  static const Color secondary = Color(0xFF7C3AED);
  static const Color secondaryLight = Color(0xFFA78BFA);

  // Surface Colors - Light
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF1F5F9);

  // Surface Colors - Dark
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Conversion Type Colors (for visual differentiation)
  static const Color docxColor = Color(0xFF2563EB);
  static const Color pdfColor = Color(0xFFDC2626);
  static const Color txtColor = Color(0xFF059669);
  static const Color imageColor = Color(0xFF7C3AED);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
