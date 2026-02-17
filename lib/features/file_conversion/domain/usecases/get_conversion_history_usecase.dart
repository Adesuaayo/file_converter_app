import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/conversion_result.dart';
import '../repositories/file_conversion_repository.dart';

/// Use case: Retrieve conversion history.
/// Simple query use case — no business rules to enforce.
class GetConversionHistoryUseCase {
  const GetConversionHistoryUseCase(this._repository);
  final FileConversionRepository _repository;

  /// Returns the full conversion history sorted by timestamp (newest first).
  Future<Either<Failure, List<ConversionResult>>> call() async {
    return _repository.getConversionHistory();
  }
}

/// Use case: Clear all conversion history.
class ClearConversionHistoryUseCase {
  const ClearConversionHistoryUseCase(this._repository);
  final FileConversionRepository _repository;

  Future<Either<Failure, void>> call() async {
    return _repository.clearConversionHistory();
  }
}

/// Use case: Delete a single history entry.
class DeleteHistoryEntryUseCase {
  const DeleteHistoryEntryUseCase(this._repository);
  final FileConversionRepository _repository;

  Future<Either<Failure, void>> call(String id) async {
    return _repository.deleteHistoryEntry(id);
  }
}

/// Use case: Get remaining free conversions for today.
class GetRemainingConversionsUseCase {
  const GetRemainingConversionsUseCase(this._repository);
  final FileConversionRepository _repository;

  Future<Either<Failure, int>> call() async {
    return _repository.getRemainingFreeConversions();
  }
}
