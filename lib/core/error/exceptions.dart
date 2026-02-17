/// Custom exception types for the application.
/// Each exception carries a descriptive message for debugging and logging.

/// Thrown when a file operation fails (read, write, delete, etc.)
class FileOperationException implements Exception {
  const FileOperationException(this.message);
  final String message;

  @override
  String toString() => 'FileOperationException: $message';
}

/// Thrown when a file conversion process fails
class ConversionException implements Exception {
  const ConversionException(this.message);
  final String message;

  @override
  String toString() => 'ConversionException: $message';
}

/// Thrown when file format is unsupported or unrecognized
class UnsupportedFormatException implements Exception {
  const UnsupportedFormatException(this.message);
  final String message;

  @override
  String toString() => 'UnsupportedFormatException: $message';
}

/// Thrown when local storage (Hive) operations fail
class StorageException implements Exception {
  const StorageException(this.message);
  final String message;

  @override
  String toString() => 'StorageException: $message';
}

/// Thrown when the user has exceeded their daily free conversion limit
class ConversionLimitExceededException implements Exception {
  const ConversionLimitExceededException(this.message);
  final String message;

  @override
  String toString() => 'ConversionLimitExceededException: $message';
}

/// Thrown when a required permission is denied by the user
class PermissionDeniedException implements Exception {
  const PermissionDeniedException(this.message);
  final String message;

  @override
  String toString() => 'PermissionDeniedException: $message';
}

/// Thrown when an in-app purchase operation fails
class PurchaseException implements Exception {
  const PurchaseException(this.message);
  final String message;

  @override
  String toString() => 'PurchaseException: $message';
}
