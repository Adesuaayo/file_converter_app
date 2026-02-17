import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/services/file_service.dart';
import '../../domain/entities/conversion_task.dart' as domain;
import '../../domain/usecases/convert_file_usecase.dart';
import '../../domain/usecases/batch_convert_usecase.dart';
import '../../domain/usecases/get_conversion_history_usecase.dart';
import '../../../monetization/domain/repositories/monetization_repository.dart';
import 'conversion_event.dart';
import 'conversion_state.dart';

/// BLoC for managing file conversion workflow.
/// Orchestrates the conversion pipeline: type selection → file picking →
/// settings → conversion → result display.
///
/// Uses BLoC pattern for explicit, traceable state transitions.
/// All business logic is delegated to use cases — BLoC only manages UI state.
class ConversionBloc extends Bloc<ConversionEvent, ConversionState> {
  ConversionBloc({
    required this.convertFileUseCase,
    required this.batchConvertUseCase,
    required this.getRemainingConversionsUseCase,
    required this.monetizationRepository,
    required this.fileService,
  }) : super(const ConversionInitial()) {
    on<ConversionTypeSelected>(_onConversionTypeSelected);
    on<FileSelected>(_onFileSelected);
    on<MultipleFilesSelected>(_onMultipleFilesSelected);
    on<SettingsUpdated>(_onSettingsUpdated);
    on<ConversionStarted>(_onConversionStarted);
    on<BatchConversionStarted>(_onBatchConversionStarted);
    on<ConversionReset>(_onConversionReset);
    on<OutputFileShared>(_onOutputFileShared);
    on<RemainingConversionsChecked>(_onRemainingConversionsChecked);
  }

  final ConvertFileUseCase convertFileUseCase;
  final BatchConvertUseCase batchConvertUseCase;
  final GetRemainingConversionsUseCase getRemainingConversionsUseCase;
  final MonetizationRepository monetizationRepository;
  final FileService fileService;
  final Uuid _uuid = const Uuid();

  // Track current settings across state transitions
  domain.ConversionSettings _currentSettings = const domain.ConversionSettings();

  Future<void> _onConversionTypeSelected(
    ConversionTypeSelected event,
    Emitter<ConversionState> emit,
  ) async {
    final remaining = await _getRemainingConversions();
    emit(ConversionTypeReady(
      conversionType: event.conversionType,
      settings: _currentSettings,
      remainingConversions: remaining,
    ));
  }

  void _onFileSelected(
    FileSelected event,
    Emitter<ConversionState> emit,
  ) async {
    if (state is ConversionTypeReady) {
      final currentState = state as ConversionTypeReady;
      final remaining = await _getRemainingConversions();
      emit(ConversionReady(
        conversionType: currentState.conversionType,
        settings: _currentSettings,
        filePath: event.filePath,
        fileName: event.fileName,
        fileSize: event.fileSize,
        remainingConversions: remaining,
      ));
    } else if (state is ConversionReady) {
      final currentState = state as ConversionReady;
      emit(ConversionReady(
        conversionType: currentState.conversionType,
        settings: _currentSettings,
        filePath: event.filePath,
        fileName: event.fileName,
        fileSize: event.fileSize,
        remainingConversions: currentState.remainingConversions,
      ));
    }
  }

  void _onMultipleFilesSelected(
    MultipleFilesSelected event,
    Emitter<ConversionState> emit,
  ) async {
    if (state is ConversionTypeReady || state is ConversionReady) {
      final conversionType = state is ConversionTypeReady
          ? (state as ConversionTypeReady).conversionType
          : (state as ConversionReady).conversionType;

      final remaining = await _getRemainingConversions();
      final firstFile = event.files.first;

      emit(ConversionReady(
        conversionType: conversionType,
        settings: _currentSettings,
        filePath: firstFile.filePath,
        fileName: firstFile.fileName,
        fileSize: firstFile.fileSize,
        remainingConversions: remaining,
        batchFiles: event.files
            .map((f) => {
                  'path': f.filePath,
                  'name': f.fileName,
                  'size': f.fileSize,
                })
            .toList(),
      ));
    }
  }

  void _onSettingsUpdated(
    SettingsUpdated event,
    Emitter<ConversionState> emit,
  ) {
    _currentSettings = event.settings;

    if (state is ConversionReady) {
      final currentState = state as ConversionReady;
      emit(ConversionReady(
        conversionType: currentState.conversionType,
        settings: _currentSettings,
        filePath: currentState.filePath,
        fileName: currentState.fileName,
        fileSize: currentState.fileSize,
        remainingConversions: currentState.remainingConversions,
        batchFiles: currentState.batchFiles,
      ));
    }
  }

  Future<void> _onConversionStarted(
    ConversionStarted event,
    Emitter<ConversionState> emit,
  ) async {
    if (state is! ConversionReady) return;
    final readyState = state as ConversionReady;

    emit(ConversionInProgress(
      conversionType: readyState.conversionType,
      fileName: readyState.fileName,
      statusMessage: 'Preparing conversion...',
    ));

    final isPremium = await _checkPremiumStatus();

    final task = domain.ConversionTask(
      id: _uuid.v4(),
      inputFilePath: readyState.filePath,
      inputFileName: readyState.fileName,
      inputFileSize: readyState.fileSize,
      inputFileType: readyState.conversionType.inputType,
      conversionType: readyState.conversionType,
      settings: readyState.settings,
      status: ConversionStatus.inProgress,
      startTime: DateTime.now(),
    );

    emit(ConversionInProgress(
      conversionType: readyState.conversionType,
      fileName: readyState.fileName,
      progress: 0.3,
      statusMessage: 'Converting file...',
    ));

    final result = await convertFileUseCase(
      task: task,
      isPremium: isPremium,
    );

    result.fold(
      (failure) => emit(ConversionError(
        message: failure.message,
        conversionType: readyState.conversionType,
      )),
      (conversionResult) => emit(ConversionSuccess(result: conversionResult)),
    );
  }

  Future<void> _onBatchConversionStarted(
    BatchConversionStarted event,
    Emitter<ConversionState> emit,
  ) async {
    if (state is! ConversionReady) return;
    final readyState = state as ConversionReady;

    if (readyState.batchFiles.isEmpty) {
      emit(const ConversionError(message: 'No files selected for batch conversion.'));
      return;
    }

    final isPremium = await _checkPremiumStatus();

    // Build tasks for batch conversion
    final tasks = readyState.batchFiles.map((fileInfo) {
      return domain.ConversionTask(
        id: _uuid.v4(),
        inputFilePath: fileInfo['path'] as String,
        inputFileName: fileInfo['name'] as String,
        inputFileSize: fileInfo['size'] as int,
        inputFileType: readyState.conversionType.inputType,
        conversionType: readyState.conversionType,
        settings: readyState.settings,
        status: ConversionStatus.inProgress,
        startTime: DateTime.now(),
      );
    }).toList();

    emit(ConversionInProgress(
      conversionType: readyState.conversionType,
      fileName: 'Batch: ${tasks.length} files',
      progress: 0.0,
      totalFiles: tasks.length,
      statusMessage: 'Starting batch conversion...',
    ));

    final result = await batchConvertUseCase(
      tasks: tasks,
      isPremium: isPremium,
      onProgress: (completed, total) {
        // BLoC emitters can't be used in callbacks outside the handler
        // Progress is tracked within the batch conversion logic
      },
    );

    result.fold(
      (failure) => emit(ConversionError(
        message: failure.message,
        conversionType: readyState.conversionType,
      )),
      (results) {
        final successfulResults = results.where((r) => r.success).toList();
        if (successfulResults.isEmpty) {
          emit(ConversionError(
            message: 'All conversions failed.',
            conversionType: readyState.conversionType,
          ));
        } else {
          emit(ConversionSuccess(
            result: successfulResults.first,
            batchResults: results,
          ));
        }
      },
    );
  }

  void _onConversionReset(
    ConversionReset event,
    Emitter<ConversionState> emit,
  ) {
    _currentSettings = const domain.ConversionSettings();
    emit(const ConversionInitial());
  }

  Future<void> _onOutputFileShared(
    OutputFileShared event,
    Emitter<ConversionState> emit,
  ) async {
    try {
      await fileService.shareFile(event.filePath);
    } catch (e) {
      // Sharing errors are non-fatal — don't change state
    }
  }

  Future<void> _onRemainingConversionsChecked(
    RemainingConversionsChecked event,
    Emitter<ConversionState> emit,
  ) async {
    final remaining = await _getRemainingConversions();
    emit(RemainingConversionsLoaded(remaining));
  }

  /// Check if user has premium status.
  Future<bool> _checkPremiumStatus() async {
    final result = await monetizationRepository.isPremium();
    return result.fold((_) => false, (isPremium) => isPremium);
  }

  /// Get remaining free conversions.
  Future<int> _getRemainingConversions() async {
    final isPremium = await _checkPremiumStatus();
    if (isPremium) return -1; // -1 = unlimited

    final result = await getRemainingConversionsUseCase();
    return result.fold((_) => 0, (remaining) => remaining);
  }
}
