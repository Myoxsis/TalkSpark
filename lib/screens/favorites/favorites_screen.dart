import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:talkspark/ads/banner_ad_widget.dart';
import 'package:talkspark/app/brand.dart';
import 'package:talkspark/data/prompts.dart';
import 'package:talkspark/favorites/favorites_scope.dart';

import 'widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = FavoritesScope.of(context);
    final ids = store.ids;

    final entries = ids
        .map(_FavEntry.fromId)
        .whereType<_FavEntry>()
        .toList(growable: false);
    final mediaPadding = MediaQuery.of(context).padding;
    final topOffset = mediaPadding.top + kToolbarHeight + 12;
    final bottomOffset = mediaPadding.bottom + 16;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        titleSpacing: 24,
        title: const Text('Favorites'),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear all favorites?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await store.clear();
                }
              },
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
            0,
            topOffset,
            0,
            bottomOffset,
          ),
          child: entries.isEmpty
              ? const EmptyFavoritesState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == entries.length) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: BannerAdWidget(),
                      );
                    }

                    final entry = entries[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Dismissible(
                        key: ValueKey(entry.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 26),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8686), Color(0xFFFF5F5F)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => store.remove(entry.id),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 14, 18),
                          decoration: BoxDecoration(
                            gradient: Brand.cardGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: Brand.cardShadow,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Brand.secondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.format_quote_rounded,
                                  color: Brand.secondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.text,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.category,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Share prompt',
                                icon: const Icon(Icons.share_rounded),
                                onPressed: () => Share.share(
                                  '"${entry.text}" — via TalkSpark',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _FavEntry {
  _FavEntry({required this.id, required this.category, required this.text});

  final String id;
  final String category;
  final String text;

  static _FavEntry? fromId(String id) {
    final parts = id.split('|');
    if (parts.length != 2) return null;

    final category = parts[0];
    final index = int.tryParse(parts[1]) ?? -1;
    final prompts = kPrompts[category] ?? const [];
    if (index < 0 || index >= prompts.length) return null;

    return _FavEntry(
      id: id,
      category: category,
      text: prompts[index],
    );
  }
}
