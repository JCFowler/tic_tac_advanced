import 'package:google_mobile_ads/google_mobile_ads.dart';

const int minutesBetweenAds = 3;
const int gamesBetweenAds = 3;

class AdProvider {
  Future<InitializationStatus> initialization;
  InterstitialAd? _interstitialAd;
  late DateTime _lastShownInterstitialAd;
  int _betweenGameCounter = 0;

  AdProvider(this.initialization) {
    initialization.then((_) => _loadInterstitialAd());
  }

  String get bannerAdUnitId {
    return '';
    // if (kReleaseMode) {
    //   return Platform.isAndroid
    //       ? 'ca-app-pub-4356884138821246/1048479592'
    //       : 'ca-app-pub-4356884138821246/5567143259';
    // } else {
    //   // return BannerAd.testAdUnitId;
    // }
  }

  String get interstitialAdUnitId {
    return '';
    // if (kReleaseMode) {
    //   return Platform.isAndroid
    //       ? 'ca-app-pub-4356884138821246/1892649791'
    //       : 'ca-app-pub-4356884138821246/9658980243';
    // } else {
    //   // return InterstitialAd.testAdUnitId;
    // }
  }

  InterstitialAd? get interstitialAd {
    if (_interstitialAd != null) return _interstitialAd;

    _loadInterstitialAd();
    return null;
  }

  _loadInterstitialAd() {
    if (_interstitialAd != null) _interstitialAd!.dispose();

    _lastShownInterstitialAd = DateTime.now();
    _betweenGameCounter = 0;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          // print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  showInterstitialAd() {
    if (_canShowAd()) {
      _interstitialAd!.show().then((_) {
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            _loadInterstitialAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            _loadInterstitialAd();
          },
        );
      });
    }
  }

  bool _canShowAd() {
    if (_interstitialAd != null) {
      _betweenGameCounter++;
      if (DateTime.now().difference(_lastShownInterstitialAd).inMinutes >=
              minutesBetweenAds ||
          _betweenGameCounter >= gamesBetweenAds) {
        return true;
      }
    }
    return false;
  }
}
