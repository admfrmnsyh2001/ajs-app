import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1A3A5C); // Deep Navy
  static const Color primaryLight = Color(0xFF2C5282);
  static const Color primaryDark = Color(0xFF0F253E);
  static const Color accent = Color(0xFF00A896); // Vibrant Teal
  static const Color secondary = Color(0xFF4A5568);

  // Background & Surface
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status Colors
  static const Color statusDraft = Color(0xFFD97706); // Amber
  static const Color statusDraftBg = Color(0xFFFEF3C7);
  
  static const Color statusSent = Color(0xFF2563EB); // Blue
  static const Color statusSentBg = Color(0xFFDBEAFE);

  static const Color statusApproved = Color(0xFF059669); // Green
  static const Color statusApprovedBg = Color(0xFFD1FAE5);

  static const Color statusRejected = Color(0xFFDC2626); // Red
  static const Color statusRejectedBg = Color(0xFFFEE2E2);

  // Additional Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A3A5C), Color(0xFF2C5282)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F253E), Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
