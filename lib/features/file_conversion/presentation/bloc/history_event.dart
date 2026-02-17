import 'package:equatable/equatable.dart';

/// Events for the HistoryBloc.
abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load conversion history from storage.
class HistoryLoaded extends HistoryEvent {
  const HistoryLoaded();
}

/// Delete a single history entry.
class HistoryEntryDeleted extends HistoryEvent {
  const HistoryEntryDeleted(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Clear all history entries.
class HistoryCleared extends HistoryEvent {
  const HistoryCleared();
}

/// Share a file from history.
class HistoryFileShared extends HistoryEvent {
  const HistoryFileShared(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}
