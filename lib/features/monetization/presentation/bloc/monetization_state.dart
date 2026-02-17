import 'package:equatable/equatable.dart';
import '../../domain/entities/premium_status.dart';

/// States for the MonetizationBloc.
abstract class MonetizationState extends Equatable {
  const MonetizationState();

  @override
  List<Object?> get props => [];
}

/// Initial state — status not yet checked.
class MonetizationInitial extends MonetizationState {
  const MonetizationInitial();
}

/// Loading state during status check or purchase.
class MonetizationLoading extends MonetizationState {
  const MonetizationLoading();
}

/// Free tier active (ads shown, conversions limited).
class MonetizationFreeActive extends MonetizationState {
  const MonetizationFreeActive();
}

/// Premium tier active (no ads, unlimited conversions).
class MonetizationPremiumActive extends MonetizationState {
  const MonetizationPremiumActive(this.status);
  final PremiumStatus status;

  @override
  List<Object?> get props => [status];
}

/// Purchase in progress.
class MonetizationPurchasing extends MonetizationState {
  const MonetizationPurchasing();
}

/// Purchase completed successfully.
class MonetizationPurchaseSuccess extends MonetizationState {
  const MonetizationPurchaseSuccess(this.status);
  final PremiumStatus status;

  @override
  List<Object?> get props => [status];
}

/// Error during monetization operation.
class MonetizationError extends MonetizationState {
  const MonetizationError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
