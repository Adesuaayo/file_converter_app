import 'package:flutter/material.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Card widget representing a conversion type on the home screen.
/// Displays icon, label, and source→target format indicator.
class FileTypeCard extends StatelessWidget {
  const FileTypeCard({
    super.key,
    required this.conversionType,
    required this.onTap,
  });

  final ConversionType conversionType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getTypeColor(conversionType).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _getTypeColor(conversionType).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // File type icon with colored background
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getTypeColor(conversionType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getTypeIcon(conversionType),
                  color: _getTypeColor(conversionType),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              // Conversion label
              Text(
                conversionType.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Format indicator chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FormatChip(
                    label: _getInputLabel(conversionType),
                    color: _getTypeColor(conversionType),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  _FormatChip(
                    label: _getOutputLabel(conversionType),
                    color: _getTypeColor(conversionType),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(ConversionType type) {
    return switch (type) {
      ConversionType.docxToPdf => AppColors.docxColor,
      ConversionType.pdfToTxt => AppColors.pdfColor,
      ConversionType.txtToPdf => AppColors.txtColor,
      ConversionType.imageToPdf => AppColors.imageColor,
      ConversionType.pdfToImage => AppColors.pdfColor,
    };
  }

  IconData _getTypeIcon(ConversionType type) {
    return switch (type) {
      ConversionType.docxToPdf => Icons.description_rounded,
      ConversionType.pdfToTxt => Icons.text_snippet_rounded,
      ConversionType.txtToPdf => Icons.article_rounded,
      ConversionType.imageToPdf => Icons.image_rounded,
      ConversionType.pdfToImage => Icons.photo_library_rounded,
    };
  }

  String _getInputLabel(ConversionType type) {
    return switch (type) {
      ConversionType.docxToPdf => 'DOCX',
      ConversionType.pdfToTxt => 'PDF',
      ConversionType.txtToPdf => 'TXT',
      ConversionType.imageToPdf => 'IMG',
      ConversionType.pdfToImage => 'PDF',
    };
  }

  String _getOutputLabel(ConversionType type) {
    return switch (type) {
      ConversionType.docxToPdf => 'PDF',
      ConversionType.pdfToTxt => 'TXT',
      ConversionType.txtToPdf => 'PDF',
      ConversionType.imageToPdf => 'PDF',
      ConversionType.pdfToImage => 'IMG',
    };
  }
}

/// Small chip showing file format abbreviation.
class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
