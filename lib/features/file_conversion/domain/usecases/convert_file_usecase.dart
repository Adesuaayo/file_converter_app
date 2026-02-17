import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversion_task.dart';
import '../entities/conversion_result.dart';
import '../repositories/file_conversion_repository.dart';

/// Use case: Convert a single file.
/// Encapsulates the business rule: check conversion limit → convert → save result.
/// Each use case has a single responsibility (SRP) and a single public method.
class ConvertFileUseCase {
  const ConvertFileUseCase(this._repository);
  final FileConversionRepository _repository;

  /// Execute the conversion.
  /// Checks free tier limits before proceeding.
  Future<Either<Failure, ConversionResult>> call({
    required ConversionTask task,
    required bool isPremium,
  }) async {
    // Business rule: enforce daily limit for free users
    if (!isPremium) {
      final remainingResult = await _repository.getRemainingFreeConversions();
      final remaining = remainingResult.fold(
        (failure) => 0,
        (count) => count,
      );

      if (remaining <= 0) {
        return const Left(
          LimitExceededFailure(
            'Daily conversion limit reached. Upgrade to Premium for unlimited conversions.',
          ),
        );
      }
    }

    // Perform the conversion
    final result = await _repository.convertFile(task);

    // On success: save to history and increment counter
    return result.fold(
      (failure) => Left(failure),
      (conversionResult) async {
        // Save to history
        await _repository.saveConversionResult(conversionResult);

        // Increment daily counter (only for free users)
        if (!isPremium) {
          await _repository.incrementConversionCount();
        }

        return Right(conversionResult);
      },
    );
  }
}
