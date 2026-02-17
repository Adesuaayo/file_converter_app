import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import '../constants/app_constants.dart';

/// Centralized file utility functions.
/// Handles file path resolution, MIME detection, size validation, etc.
class FileUtils {
  FileUtils._();

  /// Returns the application's output directory, creating it if needed.
  static Future<Directory> getOutputDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(
      '${appDir.path}/${AppConstants.outputDirectoryName}',
    );
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }
    return outputDir;
  }

  /// Generates a unique output file path based on input name and target extension.
  static Future<String> generateOutputPath(
    String inputFileName,
    String outputExtension,
  ) async {
    final outputDir = await getOutputDirectory();
    final baseName = getFileNameWithoutExtension(inputFileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${outputDir.path}/${baseName}_$timestamp.$outputExtension';
  }

  /// Extracts the file extension from a path (lowercase, no dot).
  static String getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1 || lastDot == filePath.length - 1) return '';
    return filePath.substring(lastDot + 1).toLowerCase();
  }

  /// Extracts the filename without extension.
  static String getFileNameWithoutExtension(String filePath) {
    final fileName = filePath.split(Platform.pathSeparator).last;
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  /// Extracts just the filename from a full path.
  static String getFileName(String filePath) {
    return filePath.split(Platform.pathSeparator).last;
  }

  /// Detects MIME type from file path using the mime package.
  static String? detectMimeType(String filePath) {
    return lookupMimeType(filePath);
  }

  /// Smart file type auto-detection using both extension and MIME type.
  static String detectFileType(String filePath) {
    final extension = getFileExtension(filePath);
    final mimeType = detectMimeType(filePath);

    // Prefer extension-based detection, fall back to MIME
    if (extension.isNotEmpty) {
      return extension;
    }

    if (mimeType != null) {
      if (mimeType.contains('pdf')) return 'pdf';
      if (mimeType.contains('wordprocessingml')) return 'docx';
      if (mimeType.contains('text/plain')) return 'txt';
      if (mimeType.contains('image/jpeg')) return 'jpg';
      if (mimeType.contains('image/png')) return 'png';
    }

    return 'unknown';
  }

  /// Validates file size against the maximum allowed.
  static bool isFileSizeValid(int fileSize) {
    return fileSize <= AppConstants.maxFileSizeBytes;
  }

  /// Formats file size to human-readable string.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Checks if a file extension is supported for input.
  static bool isSupportedInput(String extension) {
    return AppConstants.supportedInputExtensions.contains(
      extension.toLowerCase(),
    );
  }

  /// Checks if the file at the given path exists.
  static Future<bool> fileExists(String filePath) async {
    return File(filePath).exists();
  }

  /// Safely deletes a file if it exists.
  static Future<void> safeDelete(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Gets the file size in bytes.
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  /// Determines if a file extension represents an image type.
  static bool isImageExtension(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(
      extension.toLowerCase(),
    );
  }
}
