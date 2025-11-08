import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:talkspark/ads/ad_helper.dart';
import 'package:talkspark/app/talk_spark_app.dart';
import 'package:talkspark/favorites/favorites_scope.dart';
import 'package:talkspark/favorites/favorites_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AdHelper.isSupportedPlatform) {
    await MobileAds.instance.initialize();
  }
  final favorites = await FavoritesStore.create();
  runApp(
    FavoritesScope(
      notifier: favorites,
      child: const TalkSparkApp(),
    ),
  );
}
