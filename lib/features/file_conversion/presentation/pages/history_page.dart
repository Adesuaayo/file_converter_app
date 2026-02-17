import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/conversion_history_tile.dart';

/// Conversion history page.
/// Displays all past conversions with timestamps, sizes, and action buttons.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryLoaded());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Conversion History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    if (state is HistoryLoadSuccess && state.history.isNotEmpty) {
                      return IconButton(
                        onPressed: () => _showClearDialog(context),
                        icon: Icon(
                          Icons.delete_sweep_rounded,
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        tooltip: 'Clear history',
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is HistoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HistoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context
                              .read<HistoryBloc>()
                              .add(const HistoryLoaded()),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HistoryLoadSuccess) {
                  if (state.history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.15),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversions yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your converted files will appear here',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<HistoryBloc>().add(const HistoryLoaded());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: state.history.length,
                      itemBuilder: (context, index) {
                        final result = state.history[index];
                        return ConversionHistoryTile(
                          result: result,
                          onShare: () {
                            context.read<HistoryBloc>().add(
                                  HistoryFileShared(result.outputFilePath),
                                );
                          },
                          onDelete: () {
                            context.read<HistoryBloc>().add(
                                  HistoryEntryDeleted(result.id),
                                );
                          },
                          onTap: () {
                            // Could navigate to a detailed result view
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text(
            'This will remove all conversion history. '
            'Converted files will not be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<HistoryBloc>().add(const HistoryCleared());
                Navigator.pop(dialogContext);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}
