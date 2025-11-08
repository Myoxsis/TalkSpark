import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:talkspark/ads/ad_helper.dart';

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
            onAdDismissedFullScreenContent: (ad) => ad.dispose(),
            onAdFailedToShowFullScreenContent: (ad, err) => ad.dispose(),
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
