import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

/// Datasource for ad operations using Google Mobile Ads SDK.
/// Manages banner ads, interstitial ads, and ad initialization.
class AdsDatasource {
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInitialized = false;

  /// Initialize the Google Mobile Ads SDK.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
    } catch (e) {
      throw PurchaseException('Failed to initialize ads: $e');
    }
  }

  /// Get the banner ad unit ID for the current platform.
  String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.bannerAdUnitIdIos;
    }
    throw const PurchaseException('Unsupported platform for ads');
  }

  /// Get the interstitial ad unit ID for the current platform.
  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.interstitialAdUnitIdIos;
    }
    throw const PurchaseException('Unsupported platform for ads');
  }

  /// Load a banner ad. Returns the loaded BannerAd instance.
  Future<BannerAd> loadBannerAd({
    AdSize adSize = AdSize.banner,
  }) async {
    final completer = Future<BannerAd>.delayed(Duration.zero, () async {
      _bannerAd?.dispose();

      final ad = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            // Ad loaded successfully
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
      );

      await ad.load();
      _bannerAd = ad;
      return ad;
    });

    return completer;
  }

  /// Load and show an interstitial ad.
  Future<void> showInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _interstitialAd = null;
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _interstitialAd = null;
              },
            );
            ad.show();
          },
          onAdFailedToLoad: (error) {
            // Silently fail — interstitial ads are not critical
          },
        ),
      );
    } catch (e) {
      // Non-fatal: don't crash if ad fails
    }
  }

  /// Dispose all loaded ads to prevent memory leaks.
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
  }
}
