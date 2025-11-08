import 'package:flutter/material.dart';

import 'package:talkspark/app/brand.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '${Brand.appName} ',
        style: Theme.of(context).textTheme.headlineMedium,
        children: const [
          TextSpan(
            text: '· ',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(
            text: Brand.tagline,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
