import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/premium_status.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../datasources/ads_datasource.dart';

/// Concrete monetization repository implementation.
/// Manages in-app purchases and ad display logic.
class MonetizationRepositoryImpl implements MonetizationRepository {
  MonetizationRepositoryImpl({
    required this.adsDatasource,
    required this.premiumBox,
  });

  final AdsDatasource adsDatasource;
  final Box<dynamic> premiumBox;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  Future<Either<Failure, bool>> isPremium() async {
    try {
      final isPremium = premiumBox.get(
        AppConstants.keyIsPremium,
        defaultValue: false,
      ) as bool;
      return Right(isPremium);
    } catch (e) {
      return Left(PurchaseFailure('Failed to check premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> getPremiumStatus() async {
    try {
      final isPremiumValue = premiumBox.get(
        AppConstants.keyIsPremium,
        defaultValue: false,
      ) as bool;

      final purchaseDateMs = premiumBox.get('purchase_date') as int?;
      final productId = premiumBox.get('product_id') as String?;

      return Right(PremiumStatus(
        isPremium: isPremiumValue,
        purchaseDate: purchaseDateMs != null
            ? DateTime.fromMillisecondsSinceEpoch(purchaseDateMs)
            : null,
        productId: productId,
      ));
    } catch (e) {
      return Left(PurchaseFailure('Failed to get premium status: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> purchasePremium(
    String productId,
  ) async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        return const Left(
          PurchaseFailure('In-app purchases are not available on this device.'),
        );
      }

      // Query product details
      final Set<String> productIds = {productId};
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        return const Left(
          PurchaseFailure('Product not found. Please try again later.'),
        );
      }

      if (response.productDetails.isEmpty) {
        return const Left(
          PurchaseFailure('No product details available.'),
        );
      }

      // Initiate purchase
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // For non-consumable (one-time purchase)
      final bool purchaseInitiated = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!purchaseInitiated) {
        return const Left(
          PurchaseFailure('Purchase could not be initiated.'),
        );
      }

      // Listen for purchase updates
      await for (final List<PurchaseDetails> purchaseDetailsList
          in _inAppPurchase.purchaseStream) {
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.purchased ||
              purchaseDetails.status == PurchaseStatus.restored) {
            // Verify and grant premium
            await _grantPremium(productId);

            // Complete the purchase
            if (purchaseDetails.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchaseDetails);
            }

            return Right(PremiumStatus(
              isPremium: true,
              purchaseDate: DateTime.now(),
              productId: productId,
            ));
          }

          if (purchaseDetails.status == PurchaseStatus.error) {
            return Left(
              PurchaseFailure(
                purchaseDetails.error?.message ?? 'Purchase failed.',
              ),
            );
          }
        }
      }

      return const Left(PurchaseFailure('Purchase was not completed.'));
    } catch (e) {
      return Left(PurchaseFailure('Purchase failed: $e'));
    }
  }

  @override
  Future<Either<Failure, PremiumStatus>> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();

      // Check if any purchases were restored via the stream
      await for (final List<PurchaseDetails> purchaseDetailsList
          in _inAppPurchase.purchaseStream) {
        for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.status == PurchaseStatus.restored) {
            await _grantPremium(purchaseDetails.productID);

            if (purchaseDetails.pendingCompletePurchase) {
              await _inAppPurchase.completePurchase(purchaseDetails);
            }

            return Right(PremiumStatus(
              isPremium: true,
              purchaseDate: DateTime.now(),
              productId: purchaseDetails.productID,
            ));
          }
        }
        break; // Only process first batch
      }

      // No purchases found to restore
      return const Right(PremiumStatus(isPremium: false));
    } catch (e) {
      return Left(PurchaseFailure('Restore failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> initializeAds() async {
    try {
      await adsDatasource.initialize();
      return const Right(null);
    } catch (e) {
      return Left(PurchaseFailure('Failed to initialize ads: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> shouldShowAds() async {
    final premiumResult = await isPremium();
    return premiumResult.fold(
      (failure) => const Right(true), // Show ads on error (safe default)
      (isPremium) => Right(!isPremium),
    );
  }

  @override
  Future<Either<Failure, void>> recordAdImpression() async {
    // Could track ad impressions for analytics
    return const Right(null);
  }

  /// Grant premium status by saving to local storage.
  Future<void> _grantPremium(String productId) async {
    await premiumBox.put(AppConstants.keyIsPremium, true);
    await premiumBox.put(
      'purchase_date',
      DateTime.now().millisecondsSinceEpoch,
    );
    await premiumBox.put('product_id', productId);
  }
}
