import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import '../utils/file_utils.dart';

/// Service layer for file system operations.
/// Abstracts file picking, saving, sharing, and directory management.
class FileService {
  /// Pick a single file with optional type filtering.
  Future<File?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          return File(path);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Pick multiple files for batch conversion.
  Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }

  /// Share a converted file using the platform share sheet.
  Future<void> shareFile(String filePath, {String? subject}) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Converted file from ${AppConstants.appName}',
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// Share multiple files.
  Future<void> shareMultipleFiles(
    List<String> filePaths, {
    String? subject,
  }) async {
    try {
      final xFiles = filePaths.map((p) => XFile(p)).toList();
      await Share.shareXFiles(
        xFiles,
        subject: subject ?? 'Converted files from ${AppConstants.appName}',
      );
    } catch (e) {
      throw Exception('Failed to share files: $e');
    }
  }

  /// Get the application output directory.
  Future<Directory> getOutputDirectory() async {
    return FileUtils.getOutputDirectory();
  }

  /// Clean up old converted files to manage storage.
  Future<int> cleanupOldFiles({int maxAgeDays = 30}) async {
    try {
      final outputDir = await FileUtils.getOutputDirectory();
      final now = DateTime.now();
      int deletedCount = 0;

      await for (final entity in outputDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          final age = now.difference(stat.modified);
          if (age.inDays > maxAgeDays) {
            await entity.delete();
            deletedCount++;
          }
        }
      }
      return deletedCount;
    } catch (e) {
      throw Exception('Failed to cleanup files: $e');
    }
  }

  /// Get the total size of converted files in the output directory.
  Future<int> getOutputDirectorySize() async {
    try {
      final outputDir = await FileUtils.getOutputDirectory();
      int totalSize = 0;

      await for (final entity in outputDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get the temporary directory for intermediate processing.
  Future<Directory> getTempDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final processingDir = Directory('${tempDir.path}/file_converter_processing');
    if (!await processingDir.exists()) {
      await processingDir.create(recursive: true);
    }
    return processingDir;
  }

  /// Clean the temporary processing directory.
  Future<void> cleanTempDirectory() async {
    try {
      final tempDir = await getTempDirectory();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
        await tempDir.create(recursive: true);
      }
    } catch (_) {
      // Silently fail — temp cleanup is not critical
    }
  }
}
