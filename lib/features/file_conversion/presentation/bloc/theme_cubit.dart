import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/local_conversion_datasource.dart';

/// Cubit for managing theme mode (light/dark/system).
/// Uses Cubit instead of full BLoC because theme switching is
/// simple toggle logic without complex event processing.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._localDatasource) : super(ThemeMode.system) {
    _loadTheme();
  }

  final LocalConversionDatasource _localDatasource;

  /// Load saved theme preference from local storage.
  void _loadTheme() {
    final savedMode = _localDatasource.getThemeMode();
    emit(_parseThemeMode(savedMode));
  }

  /// Toggle to the next theme mode: system → light → dark → system.
  void toggleTheme() {
    final nextMode = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };

    _localDatasource.saveThemeMode(_themeModeToString(nextMode));
    emit(nextMode);
  }

  /// Set a specific theme mode.
  void setTheme(ThemeMode mode) {
    _localDatasource.saveThemeMode(_themeModeToString(mode));
    emit(mode);
  }

  ThemeMode _parseThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
