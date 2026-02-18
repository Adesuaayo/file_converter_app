/// Application-wide constants.
/// Centralized to avoid hard-coded values throughout the codebase.

class AppConstants {
  AppConstants._(); // Prevent instantiation

  // App Info
  static const String appName = 'FileConverter Pro';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Storage Keys
  static const String hiveBoxConversionHistory = 'conversion_history';
  static const String hiveBoxSettings = 'app_settings';
  static const String hiveBoxPremium = 'premium_status';
  static const String keyDailyConversionCount = 'daily_conversion_count';
  static const String keyLastConversionDate = 'last_conversion_date';
  static const String keyIsPremium = 'is_premium';
  static const String keyThemeMode = 'theme_mode';

  // Free Tier Limits
  static const int maxFreeConversionsPerDay = 5;

  // File Size Limits (in bytes)
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50 MB
  static const int maxBatchFileCount = 10;

  // Supported Extensions
  static const List<String> supportedInputExtensions = [
    'pdf', 'docx', 'txt', 'jpg', 'jpeg', 'png',
  ];

  static const List<String> supportedOutputExtensions = [
    'pdf', 'txt', 'jpg', 'png',
  ];

  // Output Directory Name
  static const String outputDirectoryName = 'FileConverterPro';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);

  // Ads — Google's official test ad unit IDs (work on any device)
  // Replace with your real AdMob IDs before publishing to production
  static const String admobAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String bannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialAdUnitIdIos = 'ca-app-pub-3940256099942544/4411468910';

  // In-App Purchase Product IDs — Subscription tiers
  static const String premiumProductId = 'premium_upgrade';
  static const String weeklySubscriptionId = 'premium_weekly';
  static const String monthlySubscriptionId = 'premium_monthly';
  static const String yearlySubscriptionId = 'premium_yearly';
}
