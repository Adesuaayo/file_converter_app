import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated progress indicator for file conversion.
/// Shows circular progress with percentage, file name, and status message.
class ConversionProgressWidget extends StatelessWidget {
  const ConversionProgressWidget({
    super.key,
    required this.progress,
    required this.fileName,
    required this.statusMessage,
    this.currentFile = 0,
    this.totalFiles = 1,
  });

  final double progress;
  final String fileName;
  final String statusMessage;
  final int currentFile;
  final int totalFiles;

  bool get isBatch => totalFiles > 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular progress indicator with percentage
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 10,
                  color: colorScheme.surfaceContainerHighest,
                ),
              ),
              // Progress circle
              SizedBox(
                width: 160,
                height: 160,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      color: AppColors.primary,
                    );
                  },
                ),
              ),
              // Percentage text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (isBatch)
                    Text(
                      '$currentFile / $totalFiles',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // File name
        Text(
          fileName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Status message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            statusMessage,
            key: ValueKey(statusMessage),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 24),

        // Linear progress bar for overall batch progress
        if (isBatch) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      '$currentFile of $totalFiles files',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: totalFiles > 0 ? currentFile / totalFiles : 0,
                    ),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
