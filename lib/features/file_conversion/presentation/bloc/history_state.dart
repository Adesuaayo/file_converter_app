import 'package:equatable/equatable.dart';
import '../../domain/entities/conversion_result.dart';

/// States for the HistoryBloc.
abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state — history not yet loaded.
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// History is being loaded from storage.
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// History loaded successfully.
class HistoryLoadSuccess extends HistoryState {
  const HistoryLoadSuccess(this.history);
  final List<ConversionResult> history;

  @override
  List<Object?> get props => [history];
}

/// History operation failed.
class HistoryError extends HistoryState {
  const HistoryError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
