import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversion_task.dart';
import '../entities/conversion_result.dart';
import '../repositories/file_conversion_repository.dart';

/// Use case: Batch convert multiple files.
/// Validates batch size, checks limits, processes sequentially with progress.
class BatchConvertUseCase {
  const BatchConvertUseCase(this._repository);
  final FileConversionRepository _repository;

  /// Execute batch conversion.
  /// [onProgress] reports (completedCount, totalCount) for UI progress tracking.
  Future<Either<Failure, List<ConversionResult>>> call({
    required List<ConversionTask> tasks,
    required bool isPremium,
    void Function(int completed, int total)? onProgress,
  }) async {
    if (tasks.isEmpty) {
      return const Left(
        ConversionFailure('No files selected for conversion.'),
      );
    }

    // Business rule: batch limit validation
    if (tasks.length > 10) {
      return const Left(
        ConversionFailure('Maximum 10 files per batch conversion.'),
      );
    }

    // Business rule: check remaining conversions for free users
    if (!isPremium) {
      final remainingResult = await _repository.getRemainingFreeConversions();
      final remaining = remainingResult.fold(
        (failure) => 0,
        (count) => count,
      );

      if (remaining < tasks.length) {
        return Left(
          LimitExceededFailure(
            'Only $remaining conversions remaining today. '
            'Need ${tasks.length}. Upgrade to Premium for unlimited.',
          ),
        );
      }
    }

    // Execute batch conversion with progress tracking
    final result = await _repository.batchConvert(
      tasks,
      onProgress: onProgress,
    );

    // Save results and increment counter
    return result.fold(
      (failure) => Left(failure),
      (results) async {
        for (final conversionResult in results) {
          await _repository.saveConversionResult(conversionResult);
        }

        if (!isPremium) {
          for (int i = 0; i < results.where((r) => r.success).length; i++) {
            await _repository.incrementConversionCount();
          }
        }

        return Right(results);
      },
    );
  }
}
