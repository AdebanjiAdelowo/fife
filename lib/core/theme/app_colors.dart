import 'package:flutter/material.dart';

/// FiFe brand palette — sourced from the Fit & Feline logo and the
/// reference dark-mode app screens. The signature look is a near-black
/// canvas with a glowing electric-lime accent.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0A0B0D);
  static const Color surface = Color(0xFF14161A);
  static const Color surfaceElevated = Color(0xFF1B1E23);
  static const Color surfaceMuted = Color(0xFF22262C);
  static const Color border = Color(0xFF2A2F36);

  // Brand greens
  static const Color limeAccent = Color(0xFFC8F751); // primary CTA glow
  static const Color limeBright = Color(0xFFB6FF3A);
  static const Color limeSoft = Color(0xFFD9F88A);
  static const Color forestGreen = Color(0xFF0E5A2D);
  static const Color logoCharcoal = Color(0xFF2D2D2D);

  // Text
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color textSecondary = Color(0xFFB7BEC8);
  static const Color textMuted = Color(0xFF7C8492);
  static const Color textOnAccent = Color(0xFF0A0B0D);

  // Status
  static const Color success = Color(0xFF7BD66B);
  static const Color warning = Color(0xFFE8B23A);
  static const Color danger = Color(0xFFD25A4F);
  static const Color info = Color(0xFF55A8E8);

  // Mood colors (for journal)
  static const Color moodHappy = Color(0xFFFFD75A);
  static const Color moodSad = Color(0xFF6FA8DC);
  static const Color moodAngry = Color(0xFFE36B5A);
  static const Color moodConfused = Color(0xFFB48BD8);
  static const Color moodHopeful = Color(0xFF7BD66B);
  static const Color moodSkeptical = Color(0xFF9DA3AE);

  // Body progress avatar overlays
  static const Color avatarFirst = Color(0xFF55A8E8);   // first measurements
  static const Color avatarGoal = Color(0xFFE36B5A);    // goal measurements
  static const Color avatarCurrent = Color(0xFF7BD66B); // current measurements

  // Gradients
  static const LinearGradient limeGlow = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC8F751), Color(0xFFB6FF3A)],
  );

  static const LinearGradient surfaceSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B1E23), Color(0xFF14161A)],
  );

  static const LinearGradient ambientGlow = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0x33C8F751), Color(0x000A0B0D)],
  );
}
