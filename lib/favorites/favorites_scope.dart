import 'package:flutter/widgets.dart';

import 'package:talkspark/favorites/favorites_store.dart';

/// Inherited widget that exposes the [FavoritesStore] to the subtree.
class FavoritesScope extends InheritedNotifier<FavoritesStore> {
  const FavoritesScope({
    super.key,
    required FavoritesStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static FavoritesStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope not found in context');
    return scope!.notifier!;
  }
}
