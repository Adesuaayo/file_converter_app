import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/file_utils.dart';

/// Core file conversion engine.
/// All conversion logic is concentrated here to maintain single responsibility.
/// Heavy operations should be called from isolates where possible.
///
/// Architecture note: This datasource handles raw file I/O and conversion.
/// Business rules (limits, history) are handled at the use case/repository level.
class FileConversionDatasource {
  // ─── DOCX → PDF ───────────────────────────────────────────────────────

  /// Converts a DOCX file to PDF.
  /// DOCX is a ZIP archive containing XML files.
  /// We extract text from word/document.xml and render it into a PDF.
  Future<String> convertDocxToPdf(
    String inputPath,
    ConversionSettings settings,
  ) async {
    try {
      final inputFile = File(inputPath);
      final bytes = await inputFile.readAsBytes();

      // DOCX files are ZIP archives
      final archive = ZipDecoder().decodeBytes(bytes);

      // Find the main document XML
      final documentXml = archive.files.firstWhere(
        (file) => file.name == 'word/document.xml',
        orElse: () => throw const ConversionException(
          'Invalid DOCX file: missing document.xml',
        ),
      );

      // Parse XML and extract text content
      final xmlContent = String.fromCharCodes(documentXml.content as List<int>);
      final document = XmlDocument.parse(xmlContent);
      final textContent = _extractTextFromDocx(document);

      // Generate PDF from extracted text
      final outputPath = await FileUtils.generateOutputPath(
        FileUtils.getFileName(inputPath),
        'pdf',
      );

      final pdf = pw.Document();
      final pageSize = _getPdfPageFormat(settings.pdfPageSize);

      // Split text into pages with proper pagination
      final lines = textContent.split('\n');
      final linesPerPage = 45; // Approximate lines per A4 page
      final pageCount = (lines.length / linesPerPage).ceil().clamp(1, 10000);

      for (int page = 0; page < pageCount; page++) {
        final startLine = page * linesPerPage;
        final endLine = (startLine + linesPerPage).clamp(0, lines.length);
        final pageLines = lines.sublist(startLine, endLine);
        final pageText = pageLines.join('\n');

        pdf.addPage(
          pw.Page(
            pageFormat: pageSize,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Text(
                pageText,
                style: const pw.TextStyle(fontSize: 11),
              );
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pdfBytes);

      return outputPath;
    } on ConversionException {
      rethrow;
    } catch (e) {
      throw ConversionException('DOCX to PDF conversion failed: $e');
    }
  }

  /// Recursively extracts text content from DOCX XML structure.
  /// Handles paragraphs (<w:p>), runs (<w:r>), and text elements (<w:t>).
  String _extractTextFromDocx(XmlDocument document) {
    final buffer = StringBuffer();
    final body = document.findAllElements('w:body');

    if (body.isEmpty) {
      // Try without namespace prefix
      final bodyAlt = document.findAllElements('body');
      if (bodyAlt.isEmpty) {
        return document.innerText;
      }
    }

    // Extract text from all paragraph elements
    final paragraphs = document.findAllElements('w:p');
    for (final paragraph in paragraphs) {
      final runs = paragraph.findAllElements('w:r');
      for (final run in runs) {
        final textElements = run.findAllElements('w:t');
        for (final textElement in textElements) {
          buffer.write(textElement.innerText);
        }
      }
      buffer.writeln(); // New line after each paragraph
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? 'No text content found in document.' : result;
  }

  // ─── PDF → TXT ────────────────────────────────────────────────────────

  /// Converts a PDF file to plain text.
  /// Extracts text from raw PDF content streams (BT/ET blocks with Tj/TJ operators).
  Future<String> convertPdfToTxt(
    String inputPath,
    ConversionSettings settings,
  ) async {
    try {
      final inputFile = File(inputPath);
      final bytes = await inputFile.readAsBytes();
      final content = String.fromCharCodes(bytes);

      // Extract text from PDF content streams
      final textBuffer = StringBuffer();
      final btEtPattern = RegExp(r'BT\s(.*?)\sET', dotAll: true);
      final tjPattern = RegExp(r'\((.*?)\)\s*Tj', dotAll: true);
      final tjArrayPattern = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
      final parenthesesPattern = RegExp(r'\((.*?)\)');

      for (final btMatch in btEtPattern.allMatches(content)) {
        final block = btMatch.group(1) ?? '';

        // Extract text from Tj operators
        for (final tjMatch in tjPattern.allMatches(block)) {
          final text = tjMatch.group(1) ?? '';
          textBuffer.write(_decodePdfText(text));
        }

        // Extract text from TJ arrays
        for (final tjArr in tjArrayPattern.allMatches(block)) {
          final arrayContent = tjArr.group(1) ?? '';
          for (final pMatch in parenthesesPattern.allMatches(arrayContent)) {
            textBuffer.write(_decodePdfText(pMatch.group(1) ?? ''));
          }
        }

        textBuffer.writeln();
      }

      final text = textBuffer.toString().trim();
      if (text.isEmpty) {
        throw const ConversionException(
          'No extractable text found in PDF. The PDF may contain only images or use embedded fonts.',
        );
      }

      // Write text to output file
      final outputPath = await FileUtils.generateOutputPath(
        FileUtils.getFileName(inputPath),
        'txt',
      );

      await File(outputPath).writeAsString(text);
      return outputPath;
    } on ConversionException {
      rethrow;
    } catch (e) {
      throw ConversionException('PDF to Text conversion failed: $e');
    }
  }

  /// Decodes basic PDF text escape sequences.
  String _decodePdfText(String text) {
    return text
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\r')
        .replaceAll(r'\t', '\t')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')');
  }

  // ─── TXT → PDF ────────────────────────────────────────────────────────

  /// Converts a plain text file to PDF.
  /// Pure Dart implementation — safe for isolate execution.
  Future<String> convertTxtToPdf(
    String inputPath,
    ConversionSettings settings,
  ) async {
    try {
      final inputFile = File(inputPath);
      final textContent = await inputFile.readAsString();

      if (textContent.trim().isEmpty) {
        throw const ConversionException('Text file is empty.');
      }

      final pdf = pw.Document();
      final pageSize = _getPdfPageFormat(settings.pdfPageSize);

      // Paginate text content
      final lines = textContent.split('\n');
      final linesPerPage = 50;
      final pageCount = (lines.length / linesPerPage).ceil().clamp(1, 10000);

      for (int page = 0; page < pageCount; page++) {
        final startLine = page * linesPerPage;
        final endLine = (startLine + linesPerPage).clamp(0, lines.length);
        final pageLines = lines.sublist(startLine, endLine);
        final pageText = pageLines.join('\n');

        pdf.addPage(
          pw.Page(
            pageFormat: pageSize,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return pw.Text(
                pageText,
                style: pw.TextStyle(
                  fontSize: 10,
                  font: pw.Font.courier(),
                ),
              );
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();
      final outputPath = await FileUtils.generateOutputPath(
        FileUtils.getFileName(inputPath),
        'pdf',
      );
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pdfBytes);

      return outputPath;
    } on ConversionException {
      rethrow;
    } catch (e) {
      throw ConversionException('TXT to PDF conversion failed: $e');
    }
  }

  // ─── Image → PDF ──────────────────────────────────────────────────────

  /// Converts one or more images (JPG/PNG) to a single PDF.
  /// Each image becomes a separate page.
  Future<String> convertImageToPdf(
    String inputPath,
    ConversionSettings settings, {
    List<String>? additionalImages,
  }) async {
    try {
      final imagePaths = [inputPath, ...?additionalImages];
      final pdf = pw.Document();
      final pageSize = _getPdfPageFormat(settings.pdfPageSize);

      for (final imagePath in imagePaths) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          continue; // Skip missing files in batch
        }

        final imageBytes = await imageFile.readAsBytes();

        // Compress image if needed based on quality settings
        final processedBytes = _processImageForPdf(
          imageBytes,
          settings.imageQuality,
        );

        final image = pw.MemoryImage(processedBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pageSize,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }

      final pdfBytes = await pdf.save();
      final outputPath = await FileUtils.generateOutputPath(
        FileUtils.getFileName(inputPath),
        'pdf',
      );
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(pdfBytes);

      return outputPath;
    } catch (e) {
      throw ConversionException('Image to PDF conversion failed: $e');
    }
  }

  /// Process image bytes for PDF embedding with quality control.
  Uint8List _processImageForPdf(
    Uint8List imageBytes,
    ImageQuality quality,
  ) {
    if (quality == ImageQuality.original) {
      return imageBytes;
    }

    try {
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) return imageBytes;

      // Re-encode with specified quality
      return Uint8List.fromList(
        img.encodeJpg(decodedImage, quality: quality.quality),
      );
    } catch (_) {
      // If image processing fails, use original bytes
      return imageBytes;
    }
  }

  // ─── PDF → Images ─────────────────────────────────────────────────────

  /// Converts each page of a PDF to an image file.
  /// Returns the directory path containing the output images.
  Future<String> convertPdfToImages(
    String inputPath,
    ConversionSettings settings,
  ) async {
    try {
      final pdfDocument = await pdfx.PdfDocument.openFile(inputPath);
      final baseName = FileUtils.getFileNameWithoutExtension(
        FileUtils.getFileName(inputPath),
      );
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputDir = await FileUtils.getOutputDirectory();
      final imageDir = Directory(
        '${outputDir.path}/${baseName}_images_$timestamp',
      );
      await imageDir.create(recursive: true);

      final outputPaths = <String>[];

      for (int i = 1; i <= pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i);

        // Render page to image
        final pageImage = await page.render(
          width: page.width * 2, // 2x for quality
          height: page.height * 2,
          format: pdfx.PdfPageImageFormat.png,
          backgroundColor: '#FFFFFF',
        );

        if (pageImage != null) {
          final ext = settings.imageOutputFormat.extension;
          final imagePath = '${imageDir.path}/page_${i.toString().padLeft(3, '0')}.$ext';

          Uint8List outputBytes;
          if (settings.imageOutputFormat == ImageOutputFormat.jpg) {
            // Convert to JPG with quality setting
            final decoded = img.decodeImage(pageImage.bytes);
            if (decoded != null) {
              outputBytes = Uint8List.fromList(
                img.encodeJpg(decoded, quality: settings.imageQuality.quality),
              );
            } else {
              outputBytes = pageImage.bytes;
            }
          } else {
            outputBytes = pageImage.bytes;
          }

          await File(imagePath).writeAsBytes(outputBytes);
          outputPaths.add(imagePath);
        }

        await page.close();
      }

      await pdfDocument.close();

      if (outputPaths.isEmpty) {
        throw const ConversionException(
          'Failed to render any pages from the PDF.',
        );
      }

      // Return first image path as representative output
      // The full directory path is embedded in the path
      return outputPaths.first;
    } catch (e) {
      throw ConversionException('PDF to Images conversion failed: $e');
    }
  }

  // ─── Utility Methods ──────────────────────────────────────────────────

  /// Maps our PdfPageSize enum to the pdf package's PdfPageFormat.
  PdfPageFormat _getPdfPageFormat(PdfPageSize pageSize) {
    switch (pageSize) {
      case PdfPageSize.a4:
        return PdfPageFormat.a4;
      case PdfPageSize.letter:
        return PdfPageFormat.letter;
      case PdfPageSize.legal:
        return PdfPageFormat.legal;
      case PdfPageSize.a3:
        return PdfPageFormat.a3;
      case PdfPageSize.a5:
        return PdfPageFormat.a5;
    }
  }
}

/// Data class to hold conversion settings for isolate-safe passing.
/// This mirrors the domain entity but is data-layer specific.
class ConversionSettings {
  const ConversionSettings({
    this.pdfPageSize = PdfPageSize.a4,
    this.compressionLevel = CompressionLevel.medium,
    this.imageQuality = ImageQuality.high,
    this.imageOutputFormat = ImageOutputFormat.png,
    this.highSpeedMode = false,
  });

  final PdfPageSize pdfPageSize;
  final CompressionLevel compressionLevel;
  final ImageQuality imageQuality;
  final ImageOutputFormat imageOutputFormat;
  final bool highSpeedMode;

  /// Create from domain entity settings.
  factory ConversionSettings.fromDomain(
    // ignore: avoid_types_as_parameter_names, use the import alias
    dynamic domainSettings,
  ) {
    // The domain ConversionSettings fields match 1:1
    return ConversionSettings(
      pdfPageSize: domainSettings.pdfPageSize,
      compressionLevel: domainSettings.compressionLevel,
      imageQuality: domainSettings.imageQuality,
      imageOutputFormat: domainSettings.imageOutputFormat,
      highSpeedMode: domainSettings.highSpeedMode,
    );
  }
}
