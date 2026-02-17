import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing runtime permissions.
/// Handles Android scoped storage (Android 13+) and iOS photo library access.
class PermissionService {
  /// Request storage permission appropriate for the platform version.
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses granular media permissions (scoped storage)
      // For file conversion, we use file_picker which handles SAF internally
      // We only need MANAGE_EXTERNAL_STORAGE for saving to shared storage
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      // Fallback: try legacy storage permission for older Android versions
      final legacyStatus = await Permission.storage.request();
      return legacyStatus.isGranted;
    }

    if (Platform.isIOS) {
      // iOS uses app sandbox by default — no special permission needed
      // for reading/writing within app documents directory.
      // Only request photo library permission if saving images.
      return true;
    }

    return true;
  }

  /// Request photo library permission (needed for saving converted images).
  Future<bool> requestPhotoLibraryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted || status.isLimited;
    }

    if (Platform.isAndroid) {
      // On Android 13+, use Photos permission
      final status = await Permission.photos.request();
      if (status.isGranted) return true;

      // Fallback for older Android
      final legacyStatus = await Permission.storage.request();
      return legacyStatus.isGranted;
    }

    return true;
  }

  /// Check if storage permission is currently granted.
  Future<bool> isStoragePermissionGranted() async {
    if (Platform.isAndroid) {
      return await Permission.manageExternalStorage.isGranted ||
          await Permission.storage.isGranted;
    }
    return true; // iOS uses app sandbox
  }

  /// Open app settings so the user can manually grant permissions.
  Future<bool> openSettings() async {
    return openAppSettings();
  }

  /// Request notification permission (Android 13+).
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }
}
