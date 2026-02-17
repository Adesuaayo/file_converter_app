import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/ads_datasource.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../../domain/usecases/monetization_usecases.dart';
import 'monetization_event.dart';
import 'monetization_state.dart';

/// BLoC for managing monetization state.
/// Handles premium status checks, purchases, and ad management.
class MonetizationBloc extends Bloc<MonetizationEvent, MonetizationState> {
  MonetizationBloc({
    required this.checkPremiumStatusUseCase,
    required this.purchasePremiumUseCase,
    required this.restorePurchasesUseCase,
    required this.monetizationRepository,
    required this.adsDatasource,
  }) : super(const MonetizationInitial()) {
    on<MonetizationStatusChecked>(_onStatusChecked);
    on<PremiumPurchaseRequested>(_onPurchaseRequested);
    on<PurchaseRestoreRequested>(_onRestoreRequested);
    on<AdsInitialized>(_onAdsInitialized);
    on<InterstitialAdRequested>(_onInterstitialAdRequested);
  }

  final CheckPremiumStatusUseCase checkPremiumStatusUseCase;
  final PurchasePremiumUseCase purchasePremiumUseCase;
  final RestorePurchasesUseCase restorePurchasesUseCase;
  final MonetizationRepository monetizationRepository;
  final AdsDatasource adsDatasource;

  Future<void> _onStatusChecked(
    MonetizationStatusChecked event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationLoading());

    final result = await checkPremiumStatusUseCase();
    result.fold(
      (failure) {
        // Default to free if check fails
        emit(const MonetizationFreeActive());
      },
      (status) {
        if (status.isActive) {
          emit(MonetizationPremiumActive(status));
        } else {
          emit(const MonetizationFreeActive());
          // Initialize ads for free users
          add(const AdsInitialized());
        }
      },
    );
  }

  Future<void> _onPurchaseRequested(
    PremiumPurchaseRequested event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationPurchasing());

    final result = await purchasePremiumUseCase(event.productId);
    result.fold(
      (failure) => emit(MonetizationError(failure.message)),
      (status) {
        if (status.isPremium) {
          emit(MonetizationPurchaseSuccess(status));
          emit(MonetizationPremiumActive(status));
        } else {
          emit(const MonetizationFreeActive());
        }
      },
    );
  }

  Future<void> _onRestoreRequested(
    PurchaseRestoreRequested event,
    Emitter<MonetizationState> emit,
  ) async {
    emit(const MonetizationLoading());

    final result = await restorePurchasesUseCase();
    result.fold(
      (failure) => emit(MonetizationError(failure.message)),
      (status) {
        if (status.isPremium) {
          emit(MonetizationPremiumActive(status));
        } else {
          emit(const MonetizationError('No previous purchases found.'));
          emit(const MonetizationFreeActive());
        }
      },
    );
  }

  Future<void> _onAdsInitialized(
    AdsInitialized event,
    Emitter<MonetizationState> emit,
  ) async {
    await monetizationRepository.initializeAds();
  }

  Future<void> _onInterstitialAdRequested(
    InterstitialAdRequested event,
    Emitter<MonetizationState> emit,
  ) async {
    final shouldShow = await monetizationRepository.shouldShowAds();
    shouldShow.fold(
      (_) {},
      (show) {
        if (show) {
          adsDatasource.showInterstitialAd();
        }
      },
    );
  }
}
