import 'package:equatable/equatable.dart';

/// Events for MonetizationBloc.
abstract class MonetizationEvent extends Equatable {
  const MonetizationEvent();

  @override
  List<Object?> get props => [];
}

/// Check current premium/monetization status.
class MonetizationStatusChecked extends MonetizationEvent {
  const MonetizationStatusChecked();
}

/// User initiated premium purchase.
class PremiumPurchaseRequested extends MonetizationEvent {
  const PremiumPurchaseRequested(this.productId);
  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// User requested purchase restoration.
class PurchaseRestoreRequested extends MonetizationEvent {
  const PurchaseRestoreRequested();
}

/// Initialize ads for free tier.
class AdsInitialized extends MonetizationEvent {
  const AdsInitialized();
}

/// Show an interstitial ad (after conversion on free tier).
class InterstitialAdRequested extends MonetizationEvent {
  const InterstitialAdRequested();
}
