import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';

/// Abstract repository for monetization operations.
/// Defines contract for premium status, purchases, and ad management.
abstract class MonetizationRepository {
  /// Check if the user currently has premium access.
  Future<Either<Failure, bool>> isPremium();

  /// Get detailed premium status information.
  Future<Either<Failure, PremiumStatus>> getPremiumStatus();

  /// Purchase premium (one-time or subscription).
  Future<Either<Failure, PremiumStatus>> purchasePremium(String productId);

  /// Restore previous purchases (e.g., after reinstall).
  Future<Either<Failure, PremiumStatus>> restorePurchases();

  /// Initialize ad SDK.
  Future<Either<Failure, void>> initializeAds();

  /// Check if ads should be shown (free tier only).
  Future<Either<Failure, bool>> shouldShowAds();

  /// Record that an interstitial ad was shown.
  Future<Either<Failure, void>> recordAdImpression();
}
