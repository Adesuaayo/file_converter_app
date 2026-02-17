import 'package:equatable/equatable.dart';

/// Domain entity representing the user's premium status.
class PremiumStatus extends Equatable {
  const PremiumStatus({
    required this.isPremium,
    this.purchaseDate,
    this.productId,
    this.expiresAt,
  });

  final bool isPremium;
  final DateTime? purchaseDate;
  final String? productId;
  final DateTime? expiresAt;

  /// Check if premium is still valid (for subscriptions).
  bool get isActive {
    if (!isPremium) return false;
    if (expiresAt == null) return true; // Lifetime purchase
    return DateTime.now().isBefore(expiresAt!);
  }

  @override
  List<Object?> get props => [isPremium, purchaseDate, productId, expiresAt];
}
