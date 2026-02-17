import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversion_history_model.dart';

/// Local datasource for conversion history and usage tracking.
/// Uses Hive for fast, lightweight local persistence.
class LocalConversionDatasource {
  LocalConversionDatasource(this._historyBox, this._settingsBox);

  final Box<ConversionHistoryModel> _historyBox;
  final Box<dynamic> _settingsBox;

  /// Save a conversion result to local history.
  Future<void> saveConversionResult(ConversionHistoryModel model) async {
    try {
      await _historyBox.put(model.id, model);
    } catch (e) {
      throw StorageException('Failed to save conversion result: $e');
    }
  }

  /// Retrieve all conversion history, sorted by timestamp descending.
  List<ConversionHistoryModel> getConversionHistory() {
    try {
      final results = _historyBox.values.toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    } catch (e) {
      throw StorageException('Failed to retrieve conversion history: $e');
    }
  }

  /// Delete a specific history entry by ID.
  Future<void> deleteHistoryEntry(String id) async {
    try {
      await _historyBox.delete(id);
    } catch (e) {
      throw StorageException('Failed to delete history entry: $e');
    }
  }

  /// Clear all conversion history.
  Future<void> clearConversionHistory() async {
    try {
      await _historyBox.clear();
    } catch (e) {
      throw StorageException('Failed to clear conversion history: $e');
    }
  }

  /// Get the number of conversions performed today.
  int getDailyConversionCount() {
    try {
      final lastDateStr = _settingsBox.get(
        AppConstants.keyLastConversionDate,
      ) as String?;
      final today = _formatDate(DateTime.now());

      // Reset counter if it's a new day
      if (lastDateStr != today) {
        return 0;
      }

      return _settingsBox.get(
            AppConstants.keyDailyConversionCount,
            defaultValue: 0,
          ) as int;
    } catch (e) {
      return 0;
    }
  }

  /// Increment today's conversion count.
  Future<void> incrementConversionCount() async {
    try {
      final today = _formatDate(DateTime.now());
      final lastDateStr = _settingsBox.get(
        AppConstants.keyLastConversionDate,
      ) as String?;

      int currentCount;
      if (lastDateStr != today) {
        // New day: reset counter
        currentCount = 1;
      } else {
        currentCount = (_settingsBox.get(
                  AppConstants.keyDailyConversionCount,
                  defaultValue: 0,
                ) as int) +
            1;
      }

      await _settingsBox.put(
        AppConstants.keyDailyConversionCount,
        currentCount,
      );
      await _settingsBox.put(AppConstants.keyLastConversionDate, today);
    } catch (e) {
      throw StorageException('Failed to increment conversion count: $e');
    }
  }

  /// Get remaining free conversions for today.
  int getRemainingFreeConversions() {
    final used = getDailyConversionCount();
    final remaining = AppConstants.maxFreeConversionsPerDay - used;
    return remaining > 0 ? remaining : 0;
  }

  /// Save theme mode preference.
  Future<void> saveThemeMode(String mode) async {
    await _settingsBox.put(AppConstants.keyThemeMode, mode);
  }

  /// Get saved theme mode preference.
  String getThemeMode() {
    return _settingsBox.get(
      AppConstants.keyThemeMode,
      defaultValue: 'system',
    ) as String;
  }

  /// Format date as YYYY-MM-DD string for daily tracking.
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
