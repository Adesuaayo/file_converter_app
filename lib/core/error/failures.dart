import 'package:equatable/equatable.dart';

/// Failure types following functional error handling pattern.
/// Used with dartz Either<Failure, Success> for predictable error propagation.
/// Extends Equatable for value-based equality in BLoC state comparisons.

abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// File system operation failure (read/write/delete)
class FileFailure extends Failure {
  const FileFailure(super.message);
}

/// File conversion process failure
class ConversionFailure extends Failure {
  const ConversionFailure(super.message);
}

/// Unsupported file format failure
class FormatFailure extends Failure {
  const FormatFailure(super.message);
}

/// Local storage (Hive) failure
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Daily conversion limit exceeded (free tier)
class LimitExceededFailure extends Failure {
  const LimitExceededFailure(super.message);
}

/// Permission denied failure
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// In-app purchase failure
class PurchaseFailure extends Failure {
  const PurchaseFailure(super.message);
}

/// Generic unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
