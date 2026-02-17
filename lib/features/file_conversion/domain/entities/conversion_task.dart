import 'package:equatable/equatable.dart';
import '../../../../core/constants/conversion_constants.dart';

/// Domain entity representing a single file conversion task.
/// Pure business object — no framework or data layer dependencies.
class ConversionTask extends Equatable {
  const ConversionTask({
    required this.id,
    required this.inputFilePath,
    required this.inputFileName,
    required this.inputFileSize,
    required this.inputFileType,
    required this.conversionType,
    required this.settings,
    this.outputFilePath,
    this.outputFileSize,
    this.status = ConversionStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.startTime,
    this.endTime,
  });

  final String id;
  final String inputFilePath;
  final String inputFileName;
  final int inputFileSize;
  final String inputFileType;
  final ConversionType conversionType;
  final ConversionSettings settings;
  final String? outputFilePath;
  final int? outputFileSize;
  final ConversionStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;
  final DateTime? startTime;
  final DateTime? endTime;

  /// Duration of the conversion, if completed.
  Duration? get duration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Creates a copy with updated fields (immutable update pattern).
  ConversionTask copyWith({
    String? id,
    String? inputFilePath,
    String? inputFileName,
    int? inputFileSize,
    String? inputFileType,
    ConversionType? conversionType,
    ConversionSettings? settings,
    String? outputFilePath,
    int? outputFileSize,
    ConversionStatus? status,
    double? progress,
    String? errorMessage,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ConversionTask(
      id: id ?? this.id,
      inputFilePath: inputFilePath ?? this.inputFilePath,
      inputFileName: inputFileName ?? this.inputFileName,
      inputFileSize: inputFileSize ?? this.inputFileSize,
      inputFileType: inputFileType ?? this.inputFileType,
      conversionType: conversionType ?? this.conversionType,
      settings: settings ?? this.settings,
      outputFilePath: outputFilePath ?? this.outputFilePath,
      outputFileSize: outputFileSize ?? this.outputFileSize,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        inputFilePath,
        inputFileName,
        inputFileSize,
        inputFileType,
        conversionType,
        settings,
        outputFilePath,
        outputFileSize,
        status,
        progress,
        errorMessage,
        startTime,
        endTime,
      ];
}

/// Conversion output settings (customizable by user).
class ConversionSettings extends Equatable {
  const ConversionSettings({
    this.pdfPageSize = PdfPageSize.a4,
    this.compressionLevel = CompressionLevel.medium,
    this.imageQuality = ImageQuality.high,
    this.imageOutputFormat = ImageOutputFormat.png,
    this.highSpeedMode = false,
  });

  final PdfPageSize pdfPageSize;
  final CompressionLevel compressionLevel;
  final ImageQuality imageQuality;
  final ImageOutputFormat imageOutputFormat;
  final bool highSpeedMode; // Premium feature

  ConversionSettings copyWith({
    PdfPageSize? pdfPageSize,
    CompressionLevel? compressionLevel,
    ImageQuality? imageQuality,
    ImageOutputFormat? imageOutputFormat,
    bool? highSpeedMode,
  }) {
    return ConversionSettings(
      pdfPageSize: pdfPageSize ?? this.pdfPageSize,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      imageQuality: imageQuality ?? this.imageQuality,
      imageOutputFormat: imageOutputFormat ?? this.imageOutputFormat,
      highSpeedMode: highSpeedMode ?? this.highSpeedMode,
    );
  }

  @override
  List<Object?> get props => [
        pdfPageSize,
        compressionLevel,
        imageQuality,
        imageOutputFormat,
        highSpeedMode,
      ];
}
