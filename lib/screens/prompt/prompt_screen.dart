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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => Share.share('"$prompt" — via TalkSpark'),
          ),
          IconButton(
            tooltip: isFavorite ? 'Remove favorite' : 'Save to favorites',
            icon: Icon(isFavorite
                ? Icons.star_rounded
                : Icons.star_outline_rounded),
            onPressed: () => favorites.toggle(id),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    prompt,
                    key: ValueKey(_index),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                          height: 1.35,
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            FilledButton.icon(
              icon: const Icon(Icons.flash_on_rounded),
              label: const Text('Next prompt'),
              style: FilledButton.styleFrom(
                backgroundColor: Brand.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _nextPrompt,
            ),
            const SizedBox(height: 8),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
