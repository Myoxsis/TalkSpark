import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AdHelper.isSupportedPlatform) {
    // Initialize Google Mobile Ads (uses test IDs below)
    await MobileAds.instance.initialize();
  }
  runApp(const TalkSparkApp());
}

/// Brand constants
class Brand {
  static const appName = 'TalkSpark';
  static const tagline = 'Ignite any conversation.';
  static const primary = Color(0xFFFF7A00); // warm orange
  static const textDark = Color(0xFF2F2F2F);
  static const bg = Color(0xFFFAFAFA);
}

/// Simple local dataset (offline)
/// Format: { category: [prompts...] }
const Map<String, List<String>> kPrompts = {
  'Dating': [
    "What’s your go-to comfort food?",
    "What movie could you rewatch forever?",
    "What’s something you’ve learned recently about relationships?",
    "What kind of first date feels perfect to you?",
    "What’s a tiny thing that makes your day better?",
  ],
  'Friends': [
    "What’s a hobby you wish you started earlier?",
    "What’s your favorite low-effort weekend plan?",
    "What song instantly boosts your mood?",
    "What’s a small win from this week?",
    "What’s the funniest thing that’s happened to you recently?",
  ],
  'Work': [
    "What’s one project you’re proud of—and why?",
    "What’s a productivity trick that actually works for you?",
    "If you could fix one thing about office culture, what would it be?",
    "What did you learn from a recent mistake?",
    "What kind of work makes you lose track of time?",
  ],
  'Family': [
    "What’s a family tradition you love?",
    "What’s your earliest happy memory?",
    "Which family recipe needs to be passed on forever?",
    "What’s something you admire about a family member?",
    "What’s a story you hope your family keeps telling?",
  ],
  'Random': [
    "What’s your current tiny obsession?",
    "If today had a title, what would it be?",
    "What’s a hill you’ll playfully die on?",
    "What’s a purchase under €20 that changed your routine?",
    "What’s a question you wish people asked you more?",
  ],
};

/// Each prompt gets a stable ID: "$category|$index"
String promptId(String category, int index) => '$category|$index';

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

/// --------------------------- DATA / STATE ---------------------------

class FavoritesStore extends ChangeNotifier {
  static const _prefsKey = 'favorites';
  final Set<String> _ids = {};

  FavoritesStore._();

  static Future<FavoritesStore> create() async {
    final s = FavoritesStore._();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? <String>[];
    s._ids.addAll(saved);
    return s;
  }

  List<String> get ids => _ids.toList()..sort();
  bool contains(String id) => _ids.contains(id);

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _ids.toList());
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _ids.remove(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _ids.toList());
    notifyListeners();
  }

  Future<void> clear() async {
    _ids.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, []);
    notifyListeners();
  }
}

/// Lightweight dependency container for Favorites
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

/// --------------------------- ADS HELPERS ---------------------------

/// Official Google test unit IDs:
/// Android Banner: ca-app-pub-3940256099942544/6300978111
/// Android Interstitial: ca-app-pub-3940256099942544/1033173712
/// iOS Banner: ca-app-pub-3940256099942544/2934735716
/// iOS Interstitial: ca-app-pub-3940256099942544/4411468910
///
/// Replace with your real AdMob unit IDs before publishing.
class AdHelper {
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => true,
      _ => false,
    };
  }

  static String get bannerAdUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
      default:
        throw UnsupportedError('AdMob banners are only supported on mobile.');
    }
  }

  static String get interstitialUnitId {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/4411468910';
      default:
        throw UnsupportedError('AdMob interstitials are only supported on mobile.');
    }
  }
}

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!AdHelper.isSupportedPlatform || _ad != null) return;
    _ad = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => setState(() => _loaded = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          setState(() => _loaded = false);
        },
      ),
    )
      ..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdHelper.isSupportedPlatform || !_loaded || _ad == null) {
      return const SizedBox(height: 0);
    }
    return SizedBox(
      height: _ad!.size.height.toDouble(),
      width: _ad!.size.width.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}

class InterstitialController {
  InterstitialAd? _ad;
  bool _loading = false;

  Future<void> load(BuildContext context) async {
    if (_loading || _ad != null) return;
    if (!AdHelper.isSupportedPlatform) return;
    _loading = true;
    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
          );
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (err) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  Future<void> showIfAvailable() async {
    final ad = _ad;
    if (ad == null) return;
    _ad = null;
    await ad.show();
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}

/// --------------------------- UI SCREENS ---------------------------

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
      setState(() => _favorites = store);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = kPrompts.keys.toList();

    final body = Scaffold(
      appBar: AppBar(
        title: const Text(Brand.appName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                itemCount: categories.length + 1, // + Favorites tile
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _CategoryCard(
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
                  final cat = categories[i - 1];
                  return _CategoryCard(
                    label: cat,
                    icon: _iconFor(cat),
                    color: _colorFor(cat),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PromptScreen(category: cat),
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

    // Wait until favorites are loaded to provide scope
    if (_favorites == null) return body;
    return FavoritesScope(notifier: _favorites!, child: body);
  }

  IconData _iconFor(String c) {
    switch (c) {
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

  Color _colorFor(String c) {
    switch (c) {
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

class _Header extends StatelessWidget {
  const _Header();

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
            text: 'Ignite any conversation.',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              const Spacer(),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PromptScreen extends StatefulWidget {
  final String category;
  const PromptScreen({super.key, required this.category});

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  late final List<String> _items;
  int _index = 0;
  late final Random _rng;
  late final InterstitialController _interstitial;
  int _nextCount = 0;

  @override
  void initState() {
    super.initState();
    _items = List<String>.from(kPrompts[widget.category] ?? const []);
    _rng = Random();
    _index = _rng.nextInt(_items.isNotEmpty ? _items.length : 1);
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

  void _nextPrompt() async {
    if (_items.isEmpty) return;
    _index = (_index + 1 + _rng.nextInt(3)) % _items.length;
    setState(() {});
    _nextCount++;
    // Show an interstitial every 5 "next" actions
    if (_nextCount % 5 == 0) {
      await _interstitial.showIfAvailable();
      // Preload the next interstitial
      _interstitial.load(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesScope.of(context);
    final id = promptId(widget.category, _index);
    final prompt = (_items.isEmpty) ? 'No prompts found.' : _items[_index];
    final isFav = favorites.contains(id);

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
            tooltip: isFav ? 'Remove favorite' : 'Save to favorites',
            icon: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded),
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
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
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
                    borderRadius: BorderRadius.circular(16)),
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

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = FavoritesScope.of(context);
    final ids = fav.ids;

    final entries = <_FavEntry>[];
    for (final id in ids) {
      final parts = id.split('|');
      if (parts.length != 2) continue;
      final category = parts[0];
      final idx = int.tryParse(parts[1]) ?? -1;
      final list = kPrompts[category] ?? const [];
      if (idx >= 0 && idx < list.length) {
        entries.add(_FavEntry(
          id: id,
          category: category,
          text: list[idx],
        ));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          if (entries.isNotEmpty)
            IconButton(
              tooltip: 'Clear all',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear all favorites?'),
                    content: const Text('This cannot be undone.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear')),
                    ],
                  ),
                );
                if (ok == true) {
                  await fav.clear();
                }
              },
            ),
        ],
      ),
      body: entries.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: entries.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                if (i == entries.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: BannerAdWidget(),
                  );
                }
                final e = entries[i];
                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child:
                        const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) => fav.remove(e.id),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      title: Text(e.text),
                      subtitle: Text(e.category),
                      trailing: IconButton(
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () =>
                            Share.share('"${e.text}" — via TalkSpark'),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_outline_rounded,
                size: 64, color: Colors.amber),
            const SizedBox(height: 12),
            Text(
              'No favorites yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Save prompts you like and they’ll show up here.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FavEntry {
  final String id;
  final String category;
  final String text;
  const _FavEntry(
      {required this.id, required this.category, required this.text});
}
