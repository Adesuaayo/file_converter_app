import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/file_service.dart';
import '../../domain/usecases/get_conversion_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

/// BLoC for managing conversion history display.
/// Separated from ConversionBloc to follow single responsibility principle.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({
    required this.getConversionHistoryUseCase,
    required this.clearConversionHistoryUseCase,
    required this.deleteHistoryEntryUseCase,
    required this.fileService,
  }) : super(const HistoryInitial()) {
    on<HistoryLoaded>(_onHistoryLoaded);
    on<HistoryEntryDeleted>(_onHistoryEntryDeleted);
    on<HistoryCleared>(_onHistoryCleared);
    on<HistoryFileShared>(_onHistoryFileShared);
  }

  final GetConversionHistoryUseCase getConversionHistoryUseCase;
  final ClearConversionHistoryUseCase clearConversionHistoryUseCase;
  final DeleteHistoryEntryUseCase deleteHistoryEntryUseCase;
  final FileService fileService;

  Future<void> _onHistoryLoaded(
    HistoryLoaded event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    final result = await getConversionHistoryUseCase();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (history) => emit(HistoryLoadSuccess(history)),
    );
  }

  Future<void> _onHistoryEntryDeleted(
    HistoryEntryDeleted event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await deleteHistoryEntryUseCase(event.id);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => add(const HistoryLoaded()), // Reload history after deletion
    );
  }

  Future<void> _onHistoryCleared(
    HistoryCleared event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await clearConversionHistoryUseCase();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => emit(const HistoryLoadSuccess([])),
    );
  }

  Future<void> _onHistoryFileShared(
    HistoryFileShared event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await fileService.shareFile(event.filePath);
    } catch (_) {
      // Non-fatal, don't change state
    }
  }
}
