import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Health & Trust
  static const Color primaryTeal = Color(0xFF00BFA5);
  static const Color primaryTealDark = Color(0xFF008E76);
  static const Color primaryTealLight = Color(0xFF5DF2D6);

  // Secondary Colors - Professional & Tech
  static const Color secondaryBlue = Color(0xFF0D47A1);
  static const Color secondaryBlueDark = Color(0xFF002171);
  static const Color secondaryBlueLight = Color(0xFF5472D3);

  // Accent Colors - Highlights & AI
  static const Color accentLightBlue = Color(0xFF4FC3F7);
  static const Color accentLightBlueDark = Color(0xFF0093C4);
  static const Color accentLightBlueLight = Color(0xFF8BF6FF);

  // Background Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundGrey = Color(0xFFEEEEEE);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Alert & Status Colors
  static const Color alertRed = Color(0xFFF44336);
  static const Color alertRedDark = Color(0xFFBA000D);
  static const Color alertRedLight = Color(0xFFFF7961);

  static const Color warningOrange = Color(0xFFFF9800);
  static const Color warningAmber = Color(0xFFFFC107);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenDark = Color(0xFF087F23);
  static const Color successGreenLight = Color(0xFF80E27E);

  static const Color infoBlue = Color(0xFF2196F3);

  // Emergency Button Colors
  static const Color emergencyButton = Color(0xFFD32F2F);
  static const Color emergencyButtonLight = Color(0xFFFF6659);

  // Shadow & Overlay
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // Gradient Colors
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryTeal, accentLightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient emergencyGradient = const LinearGradient(
    colors: [alertRed, alertRedLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient blueGradient = const LinearGradient(
    colors: [secondaryBlue, accentLightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Blood Group Colors
  static const Color bloodAPositive = Color(0xFFE57373);
  static const Color bloodANegative = Color(0xFFEF5350);
  static const Color bloodBPositive = Color(0xFF64B5F6);
  static const Color bloodBNegative = Color(0xFF42A5F5);
  static const Color bloodOPositive = Color(0xFF81C784);
  static const Color bloodONegative = Color(0xFF66BB6A);
  static const Color bloodABPositive = Color(0xFFFFB74D);
  static const Color bloodABNegative = Color(0xFFFF9800);

  // Vitals Colors
  static const Color bpNormal = Color(0xFF4CAF50);
  static const Color bpWarning = Color(0xFFFFC107);
  static const Color bpDanger = Color(0xFFFF5252);

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}


// import 'package:flutter/material.dart';
//
// class AppColors {
//   // 🌿 Primary Theme Colors
//   static const Color primary = Color(0xFF00C9A7); // Futuristic teal-green
//   static const Color secondary = Color(0xFF0078FF); // Blue accent
//   static const Color accent = Color(0xFF00E5B0); // Bright mint green
//
//   // 🌈 Gradients
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [Color(0xFF00C9A7), Color(0xFF0078FF)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//
//   static const LinearGradient accentGradient = LinearGradient(
//     colors: [Color(0xFF00E5B0), Color(0xFF00C9A7)],
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//   );
//
//   // 🌿 Backgrounds
//   static const Color background = Color(0xFFF8F9FA);
//   static const Color cardBackground = Colors.white;
//   static const Color darkBackground = Color(0xFF121212);
//
//   // 📝 Text Colors
//   static const Color textPrimary = Color(0xFF1B1B1B);
//   static const Color textSecondary = Color(0xFF555555);
//   static const Color textLight = Color(0xFF9E9E9E);
//
//   // 🌟 Status Colors
//   static const Color successGreen = Color(0xFF4CAF50);
//   static const Color errorRed = Color(0xFFF44336);
//   static const Color warningYellow = Color(0xFFFFC107);
//   static const Color infoBlue = Color(0xFF2196F3);
//
//   // 🎨 Buttons & Borders
//   static const Color button = primary;
//   static const Color border = Color(0xFFE0E0E0);
//
//   // ☁️ Shadows
//   static const Color shadow = Color(0x29000000); // Slight transparent black
//
//   // 🌊 Additional Accents
//   static const Color primaryTeal = Color(0xFF00BFA6);
//   static const Color lightTeal = Color(0xFF66FFE0);
// }






