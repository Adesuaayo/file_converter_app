import 'package:hive/hive.dart';
import '../../domain/entities/conversion_result.dart';

part 'conversion_history_model.g.dart';

/// Hive-persisted model for conversion history.
/// Maps between domain entity and Hive storage format.
/// The @HiveType annotation generates the TypeAdapter via build_runner.
@HiveType(typeId: 0)
class ConversionHistoryModel extends HiveObject {
  ConversionHistoryModel({
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

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inputFileName;

  @HiveField(2)
  final String outputFileName;

  @HiveField(3)
  final String inputFilePath;

  @HiveField(4)
  final String outputFilePath;

  @HiveField(5)
  final String conversionTypeLabel;

  @HiveField(6)
  final int inputFileSize;

  @HiveField(7)
  final int outputFileSize;

  @HiveField(8)
  final DateTime timestamp;

  @HiveField(9)
  final int durationMs;

  @HiveField(10)
  final bool success;

  @HiveField(11)
  final String? errorMessage;

  /// Convert from domain entity to Hive model.
  factory ConversionHistoryModel.fromEntity(ConversionResult entity) {
    return ConversionHistoryModel(
      id: entity.id,
      inputFileName: entity.inputFileName,
      outputFileName: entity.outputFileName,
      inputFilePath: entity.inputFilePath,
      outputFilePath: entity.outputFilePath,
      conversionTypeLabel: entity.conversionTypeLabel,
      inputFileSize: entity.inputFileSize,
      outputFileSize: entity.outputFileSize,
      timestamp: entity.timestamp,
      durationMs: entity.durationMs,
      success: entity.success,
      errorMessage: entity.errorMessage,
    );
  }

  /// Convert Hive model to domain entity.
  ConversionResult toEntity() {
    return ConversionResult(
      id: id,
      inputFileName: inputFileName,
      outputFileName: outputFileName,
      inputFilePath: inputFilePath,
      outputFilePath: outputFilePath,
      conversionTypeLabel: conversionTypeLabel,
      inputFileSize: inputFileSize,
      outputFileSize: outputFileSize,
      timestamp: timestamp,
      durationMs: durationMs,
      success: success,
      errorMessage: errorMessage,
    );
  }
}
