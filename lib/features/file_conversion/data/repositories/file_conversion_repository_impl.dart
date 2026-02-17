import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/conversion_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/file_utils.dart';
import '../../domain/entities/conversion_task.dart' as domain;
import '../../domain/entities/conversion_result.dart';
import '../../domain/repositories/file_conversion_repository.dart';
import '../datasources/file_conversion_datasource.dart';
import '../datasources/local_conversion_datasource.dart';
import '../models/conversion_history_model.dart';

/// Concrete repository implementation.
/// Bridges the domain layer with data sources (conversion engine + local storage).
/// All exceptions are caught here and converted to typed Failures.
class FileConversionRepositoryImpl implements FileConversionRepository {
  FileConversionRepositoryImpl({
    required this.conversionDatasource,
    required this.localDatasource,
  });

  final FileConversionDatasource conversionDatasource;
  final LocalConversionDatasource localDatasource;
  final Uuid _uuid = const Uuid();

  @override
  Future<Either<Failure, ConversionResult>> convertFile(
    domain.ConversionTask task,
  ) async {
    try {
      // Validate input file exists
      final inputFile = File(task.inputFilePath);
      if (!await inputFile.exists()) {
        return const Left(FileFailure('Input file not found.'));
      }

      // Validate file size
      final fileSize = await inputFile.length();
      if (!FileUtils.isFileSizeValid(fileSize)) {
        return Left(
          FileFailure(
            'File too large. Maximum size: ${FileUtils.formatFileSize(50 * 1024 * 1024)}',
          ),
        );
      }

      // Map domain settings to data-layer settings
      final settings = ConversionSettings(
        pdfPageSize: task.settings.pdfPageSize,
        compressionLevel: task.settings.compressionLevel,
        imageQuality: task.settings.imageQuality,
        imageOutputFormat: task.settings.imageOutputFormat,
        highSpeedMode: task.settings.highSpeedMode,
      );

      final startTime = DateTime.now();

      // Execute the appropriate conversion
      final outputPath = await _executeConversion(
        task.conversionType,
        task.inputFilePath,
        settings,
      );

      final endTime = DateTime.now();
      final outputFile = File(outputPath);
      final outputSize = await outputFile.exists() ? await outputFile.length() : 0;

      // Build result
      final result = ConversionResult(
        id: _uuid.v4(),
        inputFileName: task.inputFileName,
        outputFileName: FileUtils.getFileName(outputPath),
        inputFilePath: task.inputFilePath,
        outputFilePath: outputPath,
        conversionTypeLabel: task.conversionType.label,
        inputFileSize: task.inputFileSize,
        outputFileSize: outputSize,
        timestamp: DateTime.now(),
        durationMs: endTime.difference(startTime).inMilliseconds,
        success: true,
      );

      return Right(result);
    } on ConversionException catch (e) {
      return Left(ConversionFailure(e.message));
    } on UnsupportedFormatException catch (e) {
      return Left(FormatFailure(e.message));
    } on FileOperationException catch (e) {
      return Left(FileFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error during conversion: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ConversionResult>>> batchConvert(
    List<domain.ConversionTask> tasks, {
    void Function(int completed, int total)? onProgress,
  }) async {
    try {
      final results = <ConversionResult>[];
      int completed = 0;

      for (final task in tasks) {
        final result = await convertFile(task);
        result.fold(
          (failure) {
            // Record failed conversion in results
            results.add(ConversionResult(
              id: _uuid.v4(),
              inputFileName: task.inputFileName,
              outputFileName: '',
              inputFilePath: task.inputFilePath,
              outputFilePath: '',
              conversionTypeLabel: task.conversionType.label,
              inputFileSize: task.inputFileSize,
              outputFileSize: 0,
              timestamp: DateTime.now(),
              durationMs: 0,
              success: false,
              errorMessage: failure.message,
            ));
          },
          (conversionResult) {
            results.add(conversionResult);
          },
        );

        completed++;
        onProgress?.call(completed, tasks.length);
      }

      return Right(results);
    } catch (e) {
      return Left(UnexpectedFailure('Batch conversion failed: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ConversionResult>>> getConversionHistory() async {
    try {
      final models = localDatasource.getConversionHistory();
      final results = models.map((m) => m.toEntity()).toList();
      return Right(results);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to load history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearConversionHistory() async {
    try {
      await localDatasource.clearConversionHistory();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to clear history: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHistoryEntry(String id) async {
    try {
      await localDatasource.deleteHistoryEntry(id);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to delete entry: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getRemainingFreeConversions() async {
    try {
      final remaining = localDatasource.getRemainingFreeConversions();
      return Right(remaining);
    } catch (e) {
      return Left(UnexpectedFailure('Failed to check conversion limit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> incrementConversionCount() async {
    try {
      await localDatasource.incrementConversionCount();
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update count: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveConversionResult(
    ConversionResult result,
  ) async {
    try {
      final model = ConversionHistoryModel.fromEntity(result);
      await localDatasource.saveConversionResult(model);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to save result: $e'));
    }
  }

  /// Routes conversion to the appropriate engine method based on type.
  Future<String> _executeConversion(
    ConversionType type,
    String inputPath,
    ConversionSettings settings,
  ) async {
    switch (type) {
      case ConversionType.docxToPdf:
        return conversionDatasource.convertDocxToPdf(inputPath, settings);
      case ConversionType.pdfToTxt:
        return conversionDatasource.convertPdfToTxt(inputPath, settings);
      case ConversionType.txtToPdf:
        return conversionDatasource.convertTxtToPdf(inputPath, settings);
      case ConversionType.imageToPdf:
        return conversionDatasource.convertImageToPdf(inputPath, settings);
      case ConversionType.pdfToImage:
        return conversionDatasource.convertPdfToImages(inputPath, settings);
    }
  }
}
