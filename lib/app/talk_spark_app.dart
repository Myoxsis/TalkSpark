import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:talkspark/app/brand.dart';
import 'package:talkspark/screens/home/home_screen.dart';

class TalkSparkApp extends StatelessWidget {
  const TalkSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Brand.primary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: Brand.textDark,
        height: 1.1,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w800,
        color: Brand.textDark,
        height: 1.2,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: Brand.textDark,
      ),
      titleLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        color: Brand.textDark,
      ),
      titleMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w600,
        color: Brand.textDark,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
        color: Brand.textDark,
        height: 1.35,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontWeight: FontWeight.w500,
        color: Brand.textMuted,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.manrope(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
    );

    return MaterialApp(
      title: Brand.appName,
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          foregroundColor: Brand.textDark,
          titleTextStyle: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
          centerTitle: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Brand.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Brand.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          labelStyle: textTheme.bodyMedium,
          backgroundColor: Brand.surfaceMuted,
        ),
        dividerColor: Brand.surfaceMuted,
        splashFactory: InkSparkle.splashFactory,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
