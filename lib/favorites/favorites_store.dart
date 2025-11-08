import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A simple persistent store that tracks a user's favorite prompts.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore._();

  static const _prefsKey = 'favorites';
  final Set<String> _ids = {};

  static Future<FavoritesStore> create() async {
    final store = FavoritesStore._();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? const <String>[];
    store._ids.addAll(saved);
    return store;
  }

  List<String> get ids => _ids.toList()..sort();
  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (_ids.remove(id)) {
      // removed
    } else {
      _ids.add(id);
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    _ids.remove(id);
    await _persist();
  }

  Future<void> clear() async {
    _ids.clear();
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _ids.toList());
    notifyListeners();
  }
}
