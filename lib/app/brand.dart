import 'package:flutter/material.dart';

/// Brand-specific visual constants reused across the app.
class Brand {
  static const appName = 'TalkSpark';
  static const tagline = 'Ignite any conversation.';

  static const primary = Color(0xFFEF5B25);
  static const secondary = Color(0xFF4C5BF9);
  static const accent = Color(0xFFF95D9B);

  static const textDark = Color(0xFF1F1F26);
  static const textMuted = Color(0xFF5A6072);

  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3F4F8);

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFFFF3EA), Color(0xFFF4F3FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const heroGradient = LinearGradient(
    colors: [Color(0xFFFFB775), Color(0xFFFF7A95)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardShadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x15000000),
      blurRadius: 26,
      offset: Offset(0, 12),
    ),
  ];
}
