import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:talkspark/ads/ad_helper.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class BannerAdBottomBar extends StatelessWidget {
  const BannerAdBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: 12, top: 8),
        child: Center(
          child: BannerAdWidget(),
        ),
      ),
    );
  }
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
