import 'dart:math';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:talkspark/ads/banner_ad_widget.dart';
import 'package:talkspark/ads/interstitial_controller.dart';
import 'package:talkspark/app/brand.dart';
import 'package:talkspark/data/prompts.dart';
import 'package:talkspark/favorites/favorites_scope.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key, required this.category});

  final String category;

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  late final List<String> _items;
  late final Random _rng;
  late final InterstitialController _interstitial;

  int _index = 0;
  int _nextCount = 0;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(kPrompts[widget.category] ?? const []);
    _rng = Random();
    _index = _items.isNotEmpty ? _rng.nextInt(_items.length) : 0;
    _interstitial = InterstitialController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _interstitial.load(context);
    });
  }

  @override
  void dispose() {
    _interstitial.dispose();
    super.dispose();
  }

  Future<void> _nextPrompt() async {
    if (_items.isEmpty) return;

    _nextCount++;
    setState(() {
      _index = (_index + 1 + _rng.nextInt(3)) % _items.length;
    });

    if (_nextCount % 5 == 0) {
      await _interstitial.showIfAvailable();
      _interstitial.load(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final id = promptId(widget.category, _index);
    final prompt = _items.isEmpty ? 'No prompts found.' : _items[_index];
    final isFavorite = favorites.contains(id);
    final mediaPadding = MediaQuery.of(context).padding;
    final topOffset = mediaPadding.top + kToolbarHeight + 12;
    final bottomOffset = mediaPadding.bottom + 20;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 24,
        title: Text(widget.category),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remove favorite' : 'Save to favorites',
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            ),
            onPressed: () => favorites.toggle(id),
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => Share.share('"$prompt" — via TalkSpark'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: Brand.backgroundGradient,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            topOffset,
            20,
            bottomOffset,
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  decoration: BoxDecoration(
                    gradient: Brand.cardGradient,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: Brand.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              widget.category.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: Brand.secondary,
                                  ),
                            ),
                            backgroundColor:
                                Brand.secondary.withOpacity(0.1),
                          ),
                          IconButton(
                            tooltip: 'Shuffle prompt',
                            onPressed: _nextPrompt,
                            icon: const Icon(Icons.casino_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          ),
                          child: SingleChildScrollView(
                            key: ValueKey(_index),
                            physics: const BouncingScrollPhysics(),
                            child: Text(
                              prompt,
                              textAlign: TextAlign.start,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontSize: 26,
                                    height: 1.4,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.flash_on_rounded),
                label: const Text('Next prompt'),
                onPressed: _nextPrompt,
              ),
              const SizedBox(height: 12),
              const BannerAdWidget(),
              ],
            ),
          ),
        ),
    );
  }
}
