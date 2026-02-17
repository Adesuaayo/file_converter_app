import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

import 'features/file_conversion/presentation/bloc/conversion_bloc.dart';
import 'features/file_conversion/presentation/bloc/history_bloc.dart';
import 'features/file_conversion/presentation/bloc/theme_cubit.dart';
import 'features/file_conversion/presentation/pages/home_page.dart';

import 'features/monetization/presentation/bloc/monetization_bloc.dart';
import 'features/monetization/presentation/bloc/monetization_event.dart';

/// Custom BLoC Observer for debugging and logging.
///
/// Logs all BLoC events and state transitions in debug mode.
/// In production, this can be replaced with analytics-based logging
/// (e.g., Firebase Analytics or Sentry).
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('📘 ${bloc.runtimeType} Event: $event');
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
      '📗 ${bloc.runtimeType} Transition: '
      '${transition.currentState.runtimeType} → '
      '${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('📕 ${bloc.runtimeType} Error: $error');
    debugPrint('📕 StackTrace: $stackTrace');
  }
}

/// Application entry point.
///
/// Initialization sequence:
/// 1. Ensure Flutter binding is initialized
/// 2. Lock orientation to portrait (mobile UX decision)
/// 3. Set system UI overlay style
/// 4. Initialize dependency injection (Hive, services, repos, blocs)
/// 5. Set BLoC observer for debugging
/// 6. Launch app
void main() {
  runZonedGuarded(
    () async {
      // Ensure Flutter binding before any platform channel calls
      WidgetsFlutterBinding.ensureInitialized();

      // Lock to portrait orientation for optimal mobile UX
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      // Set system UI style (status bar, navigation bar)
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );

      // Initialize all dependencies via get_it
      await di.initDependencies();

      // Set BLoC observer for debug-mode logging
      Bloc.observer = AppBlocObserver();

      // Launch the app
      runApp(const FileConverterApp());
    },
    (error, stackTrace) {
      // Global error handler — catches unhandled async errors
      // In production, send these to Crashlytics/Sentry
      debugPrint('🔴 Unhandled Error: $error');
      debugPrint('🔴 StackTrace: $stackTrace');
    },
  );
}

/// Root application widget.
///
/// Provides all BLoCs at the top of the widget tree so they are
/// accessible from any screen via BlocProvider.of<T>(context).
///
/// Architecture note: BLoCs are provided here (not in individual pages)
/// because they need to persist state across navigation. For example,
/// the ConversionBloc maintains the current conversion task state
/// even when navigating to the history or settings tab.
class FileConverterApp extends StatelessWidget {
  const FileConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme management (light/dark/system)
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),

        // File conversion workflow
        BlocProvider<ConversionBloc>(
          create: (_) => sl<ConversionBloc>(),
        ),

        // Conversion history
        BlocProvider<HistoryBloc>(
          create: (_) => sl<HistoryBloc>(),
        ),

        // Monetization (premium status, ads, IAP)
        BlocProvider<MonetizationBloc>(
          create: (_) => sl<MonetizationBloc>()
            ..add(const MonetizationStatusChecked())
            ..add(const AdsInitialized()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'File Converter Pro',
            debugShowCheckedModeBanner: false,

            // Theme configuration using Material 3
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // Entry point screen
            home: const HomePage(),

            // Custom page transitions for smooth navigation
            builder: (context, child) {
              // Apply global text scaling limits for accessibility
              // while preventing layout overflow on extreme settings
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
