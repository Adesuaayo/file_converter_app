import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/services/file_service.dart';
import 'core/services/permission_service.dart';

import 'features/file_conversion/data/datasources/file_conversion_datasource.dart';
import 'features/file_conversion/data/datasources/local_conversion_datasource.dart';
import 'features/file_conversion/data/models/conversion_history_model.dart';
import 'features/file_conversion/data/repositories/file_conversion_repository_impl.dart';
import 'features/file_conversion/domain/repositories/file_conversion_repository.dart';
import 'features/file_conversion/domain/usecases/convert_file_usecase.dart';
import 'features/file_conversion/domain/usecases/batch_convert_usecase.dart';
import 'features/file_conversion/domain/usecases/get_conversion_history_usecase.dart';
import 'features/file_conversion/presentation/bloc/conversion_bloc.dart';
import 'features/file_conversion/presentation/bloc/history_bloc.dart';
import 'features/file_conversion/presentation/bloc/theme_cubit.dart';

import 'features/monetization/data/datasources/ads_datasource.dart';
import 'features/monetization/data/repositories/monetization_repository_impl.dart';
import 'features/monetization/domain/repositories/monetization_repository.dart';
import 'features/monetization/domain/usecases/monetization_usecases.dart';
import 'features/monetization/presentation/bloc/monetization_bloc.dart';

/// Service Locator (Dependency Injection Container).
///
/// Architecture decision: Using get_it for DI because:
/// - Zero boilerplate (no code generation required)
/// - Supports lazy registration for performance
/// - Factory and singleton patterns supported
/// - Framework-agnostic (not coupled to Flutter)
///
/// Registration order matters: register dependencies bottom-up
/// (datasources → repositories → usecases → blocs).
final sl = GetIt.instance;

/// Initialize all dependencies.
/// Must be called before runApp() in main.dart.
Future<void> initDependencies() async {
  // ─── External Dependencies ──────────────────────────────────────────

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Register Hive type adapters
  Hive.registerAdapter(ConversionHistoryModelAdapter());

  // Open Hive boxes (persistent local storage)
  final historyBox = await Hive.openBox<ConversionHistoryModel>(
    AppConstants.hiveBoxConversionHistory,
  );
  final settingsBox = await Hive.openBox<dynamic>(
    AppConstants.hiveBoxSettings,
  );
  final premiumBox = await Hive.openBox<dynamic>(
    AppConstants.hiveBoxPremium,
  );

  // Register Hive boxes as singletons
  sl.registerSingleton<Box<ConversionHistoryModel>>(historyBox);
  sl.registerSingleton<Box<dynamic>>(settingsBox);

  // ─── Core Services ─────────────────────────────────────────────────

  sl.registerLazySingleton<FileService>(() => FileService());
  sl.registerLazySingleton<PermissionService>(() => PermissionService());

  // ─── Data Sources ──────────────────────────────────────────────────

  sl.registerLazySingleton<FileConversionDatasource>(
    () => FileConversionDatasource(),
  );

  sl.registerLazySingleton<LocalConversionDatasource>(
    () => LocalConversionDatasource(
      sl<Box<ConversionHistoryModel>>(),
      settingsBox,
    ),
  );

  sl.registerLazySingleton<AdsDatasource>(() => AdsDatasource());

  // ─── Repositories ─────────────────────────────────────────────────

  sl.registerLazySingleton<FileConversionRepository>(
    () => FileConversionRepositoryImpl(
      conversionDatasource: sl<FileConversionDatasource>(),
      localDatasource: sl<LocalConversionDatasource>(),
    ),
  );

  sl.registerLazySingleton<MonetizationRepository>(
    () => MonetizationRepositoryImpl(
      adsDatasource: sl<AdsDatasource>(),
      premiumBox: premiumBox,
    ),
  );

  // ─── Use Cases ────────────────────────────────────────────────────

  // File conversion use cases
  sl.registerLazySingleton(
    () => ConvertFileUseCase(sl<FileConversionRepository>()),
  );
  sl.registerLazySingleton(
    () => BatchConvertUseCase(sl<FileConversionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetConversionHistoryUseCase(sl<FileConversionRepository>()),
  );
  sl.registerLazySingleton(
    () => ClearConversionHistoryUseCase(sl<FileConversionRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteHistoryEntryUseCase(sl<FileConversionRepository>()),
  );
  sl.registerLazySingleton(
    () => GetRemainingConversionsUseCase(sl<FileConversionRepository>()),
  );

  // Monetization use cases
  sl.registerLazySingleton(
    () => CheckPremiumStatusUseCase(sl<MonetizationRepository>()),
  );
  sl.registerLazySingleton(
    () => PurchasePremiumUseCase(sl<MonetizationRepository>()),
  );
  sl.registerLazySingleton(
    () => RestorePurchasesUseCase(sl<MonetizationRepository>()),
  );

  // ─── BLoCs / Cubits ───────────────────────────────────────────────

  // ConversionBloc — factory so each screen gets a fresh instance if needed
  // Using singleton here to maintain state across navigation
  sl.registerLazySingleton(
    () => ConversionBloc(
      convertFileUseCase: sl<ConvertFileUseCase>(),
      batchConvertUseCase: sl<BatchConvertUseCase>(),
      getRemainingConversionsUseCase: sl<GetRemainingConversionsUseCase>(),
      monetizationRepository: sl<MonetizationRepository>(),
      fileService: sl<FileService>(),
    ),
  );

  sl.registerLazySingleton(
    () => HistoryBloc(
      getConversionHistoryUseCase: sl<GetConversionHistoryUseCase>(),
      clearConversionHistoryUseCase: sl<ClearConversionHistoryUseCase>(),
      deleteHistoryEntryUseCase: sl<DeleteHistoryEntryUseCase>(),
      fileService: sl<FileService>(),
    ),
  );

  sl.registerLazySingleton(
    () => ThemeCubit(sl<LocalConversionDatasource>()),
  );

  sl.registerLazySingleton(
    () => MonetizationBloc(
      checkPremiumStatusUseCase: sl<CheckPremiumStatusUseCase>(),
      purchasePremiumUseCase: sl<PurchasePremiumUseCase>(),
      restorePurchasesUseCase: sl<RestorePurchasesUseCase>(),
      monetizationRepository: sl<MonetizationRepository>(),
      adsDatasource: sl<AdsDatasource>(),
    ),
  );
}
