import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

/// Helper class for importing study materials
/// Supports PDF, images, and text files
class FileImportHelper {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick a PDF file from device storage
  Future<File?> pickPDFFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick PDF file: $e');
    }
  }

  /// Pick an image file from device storage or camera
  Future<File?> pickImageFile({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Pick a text file from device storage
  Future<File?> pickTextFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'md'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick text file: $e');
    }
  }

  /// Pick any document file (PDF, text, etc.)
  Future<File?> pickAnyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Read text content from a file
  Future<String> readTextFromFile(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file: $e');
    }
  }

  /// Get file name from path
  String getFileName(String path) {
    return path.split('/').last;
  }

  /// Get file extension
  String getFileExtension(String path) {
    final parts = path.split('.');
    return parts.isNotEmpty ? parts.last.toLowerCase() : '';
  }

  /// Check if file is a PDF
  bool isPDF(String path) {
    return getFileExtension(path) == 'pdf';
  }

  /// Check if file is an image
  bool isImage(String path) {
    final ext = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(ext);
  }

  /// Check if file is a text file
  bool isTextFile(String path) {
    final ext = getFileExtension(path);
    return ['txt', 'md'].contains(ext);
  }

  /// Get file size in a human-readable format
  String getFileSizeString(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
