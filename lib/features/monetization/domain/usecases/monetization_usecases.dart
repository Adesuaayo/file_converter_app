import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/premium_status.dart';
import '../repositories/monetization_repository.dart';

/// Use case: Check if user has premium status.
class CheckPremiumStatusUseCase {
  const CheckPremiumStatusUseCase(this._repository);
  final MonetizationRepository _repository;

  Future<Either<Failure, PremiumStatus>> call() async {
    return _repository.getPremiumStatus();
  }
}

/// Use case: Purchase premium upgrade.
class PurchasePremiumUseCase {
  const PurchasePremiumUseCase(this._repository);
  final MonetizationRepository _repository;

  Future<Either<Failure, PremiumStatus>> call(String productId) async {
    return _repository.purchasePremium(productId);
  }
}

/// Use case: Restore previous purchases.
class RestorePurchasesUseCase {
  const RestorePurchasesUseCase(this._repository);
  final MonetizationRepository _repository;

  Future<Either<Failure, PremiumStatus>> call() async {
    return _repository.restorePurchases();
  }
}
