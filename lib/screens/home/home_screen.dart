import 'package:flutter/material.dart';

import 'package:talkspark/ads/banner_ad_widget.dart';
import 'package:talkspark/app/brand.dart';
import 'package:talkspark/data/prompts.dart';
import 'package:talkspark/screens/favorites/favorites_screen.dart';
import 'package:talkspark/screens/prompt/prompt_screen.dart';
import 'package:talkspark/widgets/app_header.dart';

import 'widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = kPrompts.keys.toList();
    final mediaPadding = MediaQuery.of(context).padding;
    final topOffset = mediaPadding.top + 84;
    final bottomOffset = mediaPadding.bottom;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 84,
        titleSpacing: 24,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Brand.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Find your next spark',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton.filledTonal(
              tooltip: 'View favorites',
              icon: const Icon(Icons.star_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.45),
                foregroundColor: Brand.primary,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: Brand.backgroundGradient,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: topOffset,
            bottom: bottomOffset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: AppHeader(),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    itemCount: categories.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CategoryCard(
                          label: 'Favorites',
                          subtitle: 'Saved sparks',
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
                      final prompts = kPrompts[category]?.length ?? 0;
                      final subtitle = prompts == 0
                          ? 'Fresh prompts soon'
                          : '$prompts curated ideas';

                      return CategoryCard(
                        label: category,
                        subtitle: subtitle,
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
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Center(
                  child: BannerAdWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
