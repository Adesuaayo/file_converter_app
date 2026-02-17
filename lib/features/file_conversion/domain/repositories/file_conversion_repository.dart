import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversion_task.dart';
import '../entities/conversion_result.dart';

/// Abstract repository contract for file conversion operations.
/// Defines the interface that the data layer must implement.
/// This ensures the domain layer has no dependency on data layer details.
abstract class FileConversionRepository {
  /// Execute a single file conversion task.
  /// Returns Either<Failure, ConversionResult> for explicit error handling.
  Future<Either<Failure, ConversionResult>> convertFile(
    ConversionTask task,
  );

  /// Execute batch conversion of multiple files.
  /// Emits progress updates via the [onProgress] callback.
  Future<Either<Failure, List<ConversionResult>>> batchConvert(
    List<ConversionTask> tasks, {
    void Function(int completed, int total)? onProgress,
  });

  /// Retrieve conversion history from local storage.
  Future<Either<Failure, List<ConversionResult>>> getConversionHistory();

  /// Clear all conversion history.
  Future<Either<Failure, void>> clearConversionHistory();

  /// Delete a specific history entry.
  Future<Either<Failure, void>> deleteHistoryEntry(String id);

  /// Check remaining free conversions for today.
  Future<Either<Failure, int>> getRemainingFreeConversions();

  /// Increment the daily conversion counter.
  Future<Either<Failure, void>> incrementConversionCount();

  /// Save a conversion result to history.
  Future<Either<Failure, void>> saveConversionResult(
    ConversionResult result,
  );
}
