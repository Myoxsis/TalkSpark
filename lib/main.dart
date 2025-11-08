import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:talkspark/ads/ad_helper.dart';
import 'package:talkspark/app/talk_spark_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AdHelper.isSupportedPlatform) {
    await MobileAds.instance.initialize();
  }
  runApp(const TalkSparkApp());
}
