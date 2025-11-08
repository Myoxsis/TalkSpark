import 'package:flutter/material.dart';

import 'package:talkspark/app/brand.dart';
import 'package:talkspark/screens/home/home_screen.dart';

class TalkSparkApp extends StatelessWidget {
  const TalkSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Brand.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Brand.primary),
        scaffoldBackgroundColor: Brand.bg,
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontWeight: FontWeight.w700,
            color: Brand.textDark,
          ),
          bodyLarge: TextStyle(
            color: Brand.textDark,
            height: 1.3,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
