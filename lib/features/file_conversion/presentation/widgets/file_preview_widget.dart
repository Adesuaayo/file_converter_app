import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/file_utils.dart';

/// Widget for previewing files before or after conversion.
/// Supports text, image, and generic file info display.
class FilePreviewWidget extends StatelessWidget {
  const FilePreviewWidget({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });

  final String filePath;
  final String fileName;
  final int fileSize;

  @override
  Widget build(BuildContext context) {
    final extension = FileUtils.getFileExtension(filePath);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File info header
          Row(
            children: [
              Icon(
                _getFileIcon(extension),
                color: _getFileColor(extension),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${FileUtils.formatFileSize(fileSize)} • .${extension.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Preview content based on file type
          if (FileUtils.isImageExtension(extension)) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildErrorPreview(context),
                ),
              ),
            ),
          ] else if (extension == 'txt') ...[
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: _readTextPreview(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        snapshot.data!,
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorPreview(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          size: 40,
        ),
      ),
    );
  }

  Future<String> _readTextPreview() async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      // Only show first 500 characters as preview
      return content.length > 500 ? '${content.substring(0, 500)}...' : content;
    } catch (_) {
      return 'Unable to preview file content.';
    }
  }

  IconData _getFileIcon(String ext) {
    return switch (ext.toLowerCase()) {
      'pdf' => Icons.picture_as_pdf_rounded,
      'docx' || 'doc' => Icons.description_rounded,
      'txt' => Icons.text_snippet_rounded,
      'jpg' || 'jpeg' || 'png' || 'gif' => Icons.image_rounded,
      _ => Icons.insert_drive_file_rounded,
    };
  }

  Color _getFileColor(String ext) {
    return switch (ext.toLowerCase()) {
      'pdf' => AppColors.pdfColor,
      'docx' || 'doc' => AppColors.docxColor,
      'txt' => AppColors.txtColor,
      'jpg' || 'jpeg' || 'png' || 'gif' => AppColors.imageColor,
      _ => AppColors.primary,
    };
  }
}
