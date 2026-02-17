import 'package:equatable/equatable.dart';

/// Domain entity representing a completed conversion result.
/// Stored in conversion history for user reference.
class ConversionResult extends Equatable {
  const ConversionResult({
    required this.id,
    required this.inputFileName,
    required this.outputFileName,
    required this.inputFilePath,
    required this.outputFilePath,
    required this.conversionTypeLabel,
    required this.inputFileSize,
    required this.outputFileSize,
    required this.timestamp,
    required this.durationMs,
    required this.success,
    this.errorMessage,
  });

  final String id;
  final String inputFileName;
  final String outputFileName;
  final String inputFilePath;
  final String outputFilePath;
  final String conversionTypeLabel;
  final int inputFileSize;
  final int outputFileSize;
  final DateTime timestamp;
  final int durationMs;
  final bool success;
  final String? errorMessage;

  /// Human-readable compression ratio (e.g., "2.5x smaller").
  String get compressionRatio {
    if (outputFileSize == 0 || inputFileSize == 0) return 'N/A';
    final ratio = inputFileSize / outputFileSize;
    if (ratio > 1) {
      return '${ratio.toStringAsFixed(1)}x smaller';
    } else {
      return '${(1 / ratio).toStringAsFixed(1)}x larger';
    }
  }

  @override
  List<Object?> get props => [
        id,
        inputFileName,
        outputFileName,
        inputFilePath,
        outputFilePath,
        conversionTypeLabel,
        inputFileSize,
        outputFileSize,
        timestamp,
        durationMs,
        success,
        errorMessage,
      ];
}
