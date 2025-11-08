import 'package:flutter/material.dart';

import 'package:talkspark/ads/banner_ad_widget.dart';
import 'package:talkspark/app/brand.dart';
import 'package:talkspark/data/prompts.dart';
import 'package:talkspark/favorites/favorites_scope.dart';
import 'package:talkspark/favorites/favorites_store.dart';
import 'package:talkspark/screens/favorites/favorites_screen.dart';
import 'package:talkspark/screens/prompt/prompt_screen.dart';
import 'package:talkspark/widgets/app_header.dart';

import 'widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FavoritesStore? _favorites;

  @override
  void initState() {
    super.initState();
    FavoritesStore.create().then((store) {
      if (!mounted) return;
      setState(() => _favorites = store);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = kPrompts.keys.toList();

    final scaffold = Scaffold(
      appBar: AppBar(
        title: const Text(Brand.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CategoryCard(
                      label: 'Favorites',
                      icon: Icons.star_rounded,
                      color: Colors.amber.shade600,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoritesScreen(),
                        ),
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  return CategoryCard(
                    label: category,
                    icon: _iconFor(category),
                    color: _colorFor(category),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromptScreen(category: category),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const BannerAdWidget(),
          ],
        ),
      ),
    );

    final store = _favorites;
    if (store == null) return scaffold;
    return FavoritesScope(notifier: store, child: scaffold);
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Dating':
        return Icons.favorite_rounded;
      case 'Friends':
        return Icons.groups_rounded;
      case 'Work':
        return Icons.work_rounded;
      case 'Family':
        return Icons.family_restroom_rounded;
      default:
        return Icons.waves_rounded;
    }
  }

  Color _colorFor(String category) {
    switch (category) {
      case 'Dating':
        return Colors.pink.shade400;
      case 'Friends':
        return Colors.blue.shade400;
      case 'Work':
        return Colors.teal.shade500;
      case 'Family':
        return Colors.purple.shade400;
      default:
        return Colors.orange.shade500;
    }
  }
}
