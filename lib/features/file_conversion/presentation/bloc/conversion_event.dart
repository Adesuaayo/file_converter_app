import 'package:equatable/equatable.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../domain/entities/conversion_task.dart';

/// Events for the ConversionBloc.
/// Each event represents a user action or system trigger that may change state.
abstract class ConversionEvent extends Equatable {
  const ConversionEvent();

  @override
  List<Object?> get props => [];
}

/// User selected a conversion type from the home screen.
class ConversionTypeSelected extends ConversionEvent {
  const ConversionTypeSelected(this.conversionType);
  final ConversionType conversionType;

  @override
  List<Object?> get props => [conversionType];
}

/// User picked a file for conversion.
class FileSelected extends ConversionEvent {
  const FileSelected({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });

  final String filePath;
  final String fileName;
  final int fileSize;

  @override
  List<Object?> get props => [filePath, fileName, fileSize];
}

/// User picked multiple files for batch conversion.
class MultipleFilesSelected extends ConversionEvent {
  const MultipleFilesSelected(this.files);
  final List<FileInfo> files;

  @override
  List<Object?> get props => [files];
}

/// User updated conversion settings.
class SettingsUpdated extends ConversionEvent {
  const SettingsUpdated(this.settings);
  final ConversionSettings settings;

  @override
  List<Object?> get props => [settings];
}

/// User triggered single file conversion.
class ConversionStarted extends ConversionEvent {
  const ConversionStarted();
}

/// User triggered batch conversion.
class BatchConversionStarted extends ConversionEvent {
  const BatchConversionStarted();
}

/// Conversion progress updated (from conversion engine).
class ConversionProgressUpdated extends ConversionEvent {
  const ConversionProgressUpdated(this.progress);
  final double progress;

  @override
  List<Object?> get props => [progress];
}

/// User cancelled an in-progress conversion.
class ConversionCancelled extends ConversionEvent {
  const ConversionCancelled();
}

/// Reset the conversion state to initial.
class ConversionReset extends ConversionEvent {
  const ConversionReset();
}

/// Share the converted output file.
class OutputFileShared extends ConversionEvent {
  const OutputFileShared(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

/// Open the converted file with the system default app.
class OutputFileOpened extends ConversionEvent {
  const OutputFileOpened(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

/// Check remaining conversions for free tier.
class RemainingConversionsChecked extends ConversionEvent {
  const RemainingConversionsChecked();
}

/// Helper class for batch file selection.
class FileInfo extends Equatable {
  const FileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });

  final String filePath;
  final String fileName;
  final int fileSize;

  @override
  List<Object?> get props => [filePath, fileName, fileSize];
}
