import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/conversion_task.dart';
import '../bloc/conversion_bloc.dart';
import '../bloc/conversion_event.dart';
import '../bloc/conversion_state.dart';
import '../widgets/conversion_progress_widget.dart';
import '../widgets/file_preview_widget.dart';

/// Main conversion workflow page.
/// Handles file selection, settings configuration, conversion execution,
/// and result display in a single scrollable view.
class ConversionPage extends StatelessWidget {
  const ConversionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ConversionBloc, ConversionState>(
          builder: (context, state) {
            if (state is ConversionTypeReady) {
              return Text(state.conversionType.label);
            }
            if (state is ConversionReady) {
              return Text(state.conversionType.label);
            }
            if (state is ConversionInProgress) {
              return Text(state.conversionType.label);
            }
            return const Text('Convert');
          },
        ),
        leading: BlocBuilder<ConversionBloc, ConversionState>(
          builder: (context, state) {
            return IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () {
                context.read<ConversionBloc>().add(const ConversionReset());
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: BlocConsumer<ConversionBloc, ConversionState>(
        listener: (context, state) {
          if (state is ConversionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildContent(context, state),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConversionState state) {
    if (state is ConversionTypeReady) {
      return _FileSelectionView(
        key: const ValueKey('selection'),
        conversionType: state.conversionType,
        remainingConversions: state.remainingConversions,
      );
    }
    if (state is ConversionReady) {
      return _ConversionReadyView(
        key: const ValueKey('ready'),
        state: state,
      );
    }
    if (state is ConversionInProgress) {
      return _ConversionProgressView(
        key: const ValueKey('progress'),
        state: state,
      );
    }
    if (state is ConversionSuccess) {
      return _ConversionSuccessView(
        key: const ValueKey('success'),
        state: state,
      );
    }
    if (state is ConversionError) {
      return _ConversionErrorView(
        key: const ValueKey('error'),
        state: state,
      );
    }
    // Safety net: if an unexpected state arrives (e.g. RemainingConversionsLoaded
    // from the home page's BlocBuilder), show the generic "Convert" prompt
    // rather than a stuck loading spinner.
    return Center(
      key: const ValueKey('idle'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Select a file to convert',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── File Selection View ──────────────────────────────────────────────────

class _FileSelectionView extends StatelessWidget {
  const _FileSelectionView({
    super.key,
    required this.conversionType,
    required this.remainingConversions,
  });

  final ConversionType conversionType;
  final int remainingConversions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Drop zone / file picker area
          GestureDetector(
            onTap: () => _pickFile(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Select a file to convert',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supported: ${_getSupportedFormats()}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max file size: 50 MB',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Single file button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickFile(context),
              icon: const Icon(Icons.file_open_rounded),
              label: const Text('Select File'),
            ),
          ),

          const SizedBox(height: 12),

          // Batch conversion button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickMultipleFiles(context),
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Batch Select (Multiple Files)'),
            ),
          ),
        ],
      ),
    );
  }

  String _getSupportedFormats() {
    return switch (conversionType) {
      ConversionType.docxToPdf => '.DOCX',
      ConversionType.pdfToTxt => '.PDF',
      ConversionType.txtToPdf => '.TXT',
      ConversionType.imageToPdf => '.JPG, .PNG',
      ConversionType.pdfToImage => '.PDF',
    };
  }

  List<String> _getAllowedExtensions() {
    return switch (conversionType) {
      ConversionType.docxToPdf => ['docx'],
      ConversionType.pdfToTxt => ['pdf'],
      ConversionType.txtToPdf => ['txt'],
      ConversionType.imageToPdf => ['jpg', 'jpeg', 'png'],
      ConversionType.pdfToImage => ['pdf'],
    };
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(),
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty && context.mounted) {
        final file = result.files.first;
        if (file.path != null) {
          context.read<ConversionBloc>().add(
                FileSelected(
                  filePath: file.path!,
                  fileName: file.name,
                  fileSize: file.size,
                ),
              );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick file: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _getAllowedExtensions(),
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty && context.mounted) {
        final files = result.files
            .where((f) => f.path != null)
            .map((f) => FileInfo(
                  filePath: f.path!,
                  fileName: f.name,
                  fileSize: f.size,
                ))
            .toList();

        if (files.isNotEmpty) {
          context.read<ConversionBloc>().add(MultipleFilesSelected(files));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick files: $e')),
        );
      }
    }
  }
}

// ─── Conversion Ready View ────────────────────────────────────────────────

class _ConversionReadyView extends StatefulWidget {
  const _ConversionReadyView({super.key, required this.state});
  final ConversionReady state;

  @override
  State<_ConversionReadyView> createState() => _ConversionReadyViewState();
}

class _ConversionReadyViewState extends State<_ConversionReadyView> {
  late ConversionSettings _settings;
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    _settings = widget.state.settings;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File preview
          FilePreviewWidget(
            filePath: widget.state.filePath,
            fileName: widget.state.fileName,
            fileSize: widget.state.fileSize,
          ),

          // Batch file list
          if (widget.state.isBatch) ...[
            const SizedBox(height: 16),
            Text(
              '${widget.state.batchFiles.length} files selected for batch conversion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.state.batchFiles.take(5).map((file) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file_rounded,
                        size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      FileUtils.formatFileSize(file['size'] as int),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (widget.state.batchFiles.length > 5)
              Text(
                '...and ${widget.state.batchFiles.length - 5} more',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
          ],

          const SizedBox(height: 24),

          // Settings toggle
          GestureDetector(
            onTap: () => setState(() => _showSettings = !_showSettings),
            child: Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Output Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _showSettings ? 0.5 : 0,
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Settings panel
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _showSettings
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSettingsPanel(context),
          ),

          const SizedBox(height: 32),

          // Convert button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<ConversionBloc>()
                    .add(SettingsUpdated(_settings));

                if (widget.state.isBatch) {
                  context
                      .read<ConversionBloc>()
                      .add(const BatchConversionStarted());
                } else {
                  context
                      .read<ConversionBloc>()
                      .add(const ConversionStarted());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.rocket_launch_rounded, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    widget.state.isBatch
                        ? 'Convert ${widget.state.batchFiles.length} Files'
                        : 'Start Conversion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context) {
    final convType = widget.state.conversionType;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PDF Page Size (for conversions that output PDF)
          if (convType == ConversionType.docxToPdf ||
              convType == ConversionType.txtToPdf ||
              convType == ConversionType.imageToPdf) ...[
            _SettingDropdown<PdfPageSize>(
              label: 'Page Size',
              value: _settings.pdfPageSize,
              items: PdfPageSize.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(pdfPageSize: v);
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Compression Level
          if (convType == ConversionType.docxToPdf ||
              convType == ConversionType.txtToPdf ||
              convType == ConversionType.imageToPdf) ...[
            _SettingDropdown<CompressionLevel>(
              label: 'Compression',
              value: _settings.compressionLevel,
              items: CompressionLevel.values,
              itemLabel: (v) => '${v.label} — ${v.description}',
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(compressionLevel: v);
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Image Quality (for image→PDF or PDF→image)
          if (convType == ConversionType.imageToPdf ||
              convType == ConversionType.pdfToImage) ...[
            _SettingDropdown<ImageQuality>(
              label: 'Image Quality',
              value: _settings.imageQuality,
              items: ImageQuality.values,
              itemLabel: (v) => '${v.label} (${v.quality}%)',
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(imageQuality: v);
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Image Output Format (PDF → Images only)
          if (convType == ConversionType.pdfToImage) ...[
            _SettingDropdown<ImageOutputFormat>(
              label: 'Output Format',
              value: _settings.imageOutputFormat,
              items: ImageOutputFormat.values,
              itemLabel: (v) => v.label,
              onChanged: (v) => setState(() {
                _settings = _settings.copyWith(imageOutputFormat: v);
              }),
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable dropdown setting widget.
class _SettingDropdown<T> extends StatelessWidget {
  const _SettingDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Progress View ──────────────────────────────────────────────────────

class _ConversionProgressView extends StatelessWidget {
  const _ConversionProgressView({super.key, required this.state});
  final ConversionInProgress state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConversionProgressWidget(
          progress: state.progress,
          fileName: state.fileName,
          statusMessage: state.statusMessage,
          currentFile: state.currentFileIndex,
          totalFiles: state.totalFiles,
        ),
      ),
    );
  }
}

// ─── Success View ───────────────────────────────────────────────────────

class _ConversionSuccessView extends StatelessWidget {
  const _ConversionSuccessView({super.key, required this.state});
  final ConversionSuccess state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final result = state.result;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // Success icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            state.isBatch
                ? 'Batch Conversion Complete!'
                : 'Conversion Successful!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          if (state.isBatch) ...[
            Text(
              '${state.successCount} succeeded, ${state.failedCount} failed',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Result details card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ResultRow('Output', result.outputFileName),
                const SizedBox(height: 8),
                _ResultRow('Size', FileUtils.formatFileSize(result.outputFileSize)),
                const SizedBox(height: 8),
                _ResultRow('Duration', '${result.durationMs}ms'),
                const SizedBox(height: 8),
                _ResultRow('Ratio', result.compressionRatio),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ConversionBloc>().add(
                      OutputFileShared(result.outputFilePath),
                    );
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share File'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<ConversionBloc>().add(const ConversionReset());
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Convert Another File'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Error View ─────────────────────────────────────────────────────────

class _ConversionErrorView extends StatelessWidget {
  const _ConversionErrorView({super.key, required this.state});
  final ConversionError state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                color: AppColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Conversion Failed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (state.conversionType != null) {
                  context.read<ConversionBloc>().add(
                        ConversionTypeSelected(state.conversionType!),
                      );
                } else {
                  context.read<ConversionBloc>().add(const ConversionReset());
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
