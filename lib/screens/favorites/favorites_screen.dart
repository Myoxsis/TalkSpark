import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:talkspark/ads/banner_ad_widget.dart';
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

    return Scaffold(
      appBar: AppBar(
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
        ],
      ),
      body: entries.isEmpty
          ? const EmptyFavoritesState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: entries.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                if (index == entries.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: BannerAdWidget(),
                  );
                }

                final entry = entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) => store.remove(entry.id),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      title: Text(entry.text),
                      subtitle: Text(entry.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () =>
                            Share.share('"${entry.text}" — via TalkSpark'),
                      ),
                    ),
                  ),
                );
              },
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
