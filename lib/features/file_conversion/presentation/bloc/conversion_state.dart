import 'package:equatable/equatable.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../domain/entities/conversion_task.dart';
import '../../domain/entities/conversion_result.dart';

/// States for the ConversionBloc.
/// Each state represents a distinct UI configuration.
abstract class ConversionState extends Equatable {
  const ConversionState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no conversion type selected yet.
class ConversionInitial extends ConversionState {
  const ConversionInitial();
}

/// Conversion type selected, waiting for file selection.
class ConversionTypeReady extends ConversionState {
  const ConversionTypeReady({
    required this.conversionType,
    required this.settings,
    required this.remainingConversions,
  });

  final ConversionType conversionType;
  final ConversionSettings settings;
  final int remainingConversions;

  @override
  List<Object?> get props => [conversionType, settings, remainingConversions];
}

/// File(s) selected, ready to start conversion.
class ConversionReady extends ConversionState {
  const ConversionReady({
    required this.conversionType,
    required this.settings,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.remainingConversions,
    this.batchFiles = const [],
  });

  final ConversionType conversionType;
  final ConversionSettings settings;
  final String filePath;
  final String fileName;
  final int fileSize;
  final int remainingConversions;
  final List<Map<String, dynamic>> batchFiles;

  bool get isBatch => batchFiles.isNotEmpty;

  @override
  List<Object?> get props => [
        conversionType,
        settings,
        filePath,
        fileName,
        fileSize,
        remainingConversions,
        batchFiles,
      ];
}

/// Conversion is currently in progress.
class ConversionInProgress extends ConversionState {
  const ConversionInProgress({
    required this.conversionType,
    required this.fileName,
    this.progress = 0.0,
    this.currentFileIndex = 0,
    this.totalFiles = 1,
    this.statusMessage = 'Converting...',
  });

  final ConversionType conversionType;
  final String fileName;
  final double progress;
  final int currentFileIndex;
  final int totalFiles;
  final String statusMessage;

  bool get isBatch => totalFiles > 1;

  @override
  List<Object?> get props => [
        conversionType,
        fileName,
        progress,
        currentFileIndex,
        totalFiles,
        statusMessage,
      ];
}

/// Conversion completed successfully.
class ConversionSuccess extends ConversionState {
  const ConversionSuccess({
    required this.result,
    this.batchResults = const [],
  });

  final ConversionResult result;
  final List<ConversionResult> batchResults;

  bool get isBatch => batchResults.isNotEmpty;
  int get successCount =>
      isBatch ? batchResults.where((r) => r.success).length : 1;
  int get failedCount =>
      isBatch ? batchResults.where((r) => !r.success).length : 0;

  @override
  List<Object?> get props => [result, batchResults];
}

/// Conversion failed with an error.
class ConversionError extends ConversionState {
  const ConversionError({
    required this.message,
    this.conversionType,
  });

  final String message;
  final ConversionType? conversionType;

  @override
  List<Object?> get props => [message, conversionType];
}

/// Remaining conversions info loaded.
class RemainingConversionsLoaded extends ConversionState {
  const RemainingConversionsLoaded(this.remaining);
  final int remaining;

  @override
  List<Object?> get props => [remaining];
}
