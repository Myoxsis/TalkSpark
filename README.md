# TalkSpark
Help users find conversation prompts and social confidence through offline, bite-sized inspiration.

## AdMob testing

The app ships with AdMob already wired up for banners and interstitials. It
initialises the Google Mobile Ads SDK on supported mobile platforms and uses the
official Google sample ad unit IDs so that only test ads are shown during
development. Before releasing to production, replace these IDs with your own and
update the platform configuration files:

- **Android:** set the `com.google.android.gms.ads.APPLICATION_ID` meta-data
  entry in `android/app/src/main/AndroidManifest.xml`.
- **iOS:** set the `GADApplicationIdentifier` key in `ios/Runner/Info.plist`.

Refer to the [Google Mobile Ads SDK documentation](https://developers.google.com/admob)
for full integration guidance.
