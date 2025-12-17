import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class FileUploadImpl {
  Future<String?> uploadFileFromPath(String path, String targetPath) async {
    try {
      final file = File(path);
      final int maxBytes = 50 * 1024 * 1024;
      final int size = await file.length();
      if (size > maxBytes) {
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(dir.path, targetPath));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final fileName = p.basename(file.path);
      final destPath = p.join(targetDir.path, fileName);
      await file.copy(destPath);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  Future<String?> uploadBytes(Uint8List bytes, String filename, String targetPath) async {
    try {
      final int maxBytes = 50 * 1024 * 1024;
      if (bytes.length > maxBytes) {
        return null;
      }
      final dir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(dir.path, targetPath));
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
      final destPath = p.join(targetDir.path, filename);
      final outFile = File(destPath);
      await outFile.writeAsBytes(bytes);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  Future<String?> downloadFile(String fileUrl, String fileName) async {
    try {
      // Check if fileUrl is a local path or a network URL
      final Uri? uri = Uri.tryParse(fileUrl);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        // It's a network URL, proceed with HTTP download
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          Directory? downloadsDirectory;
          try {
            downloadsDirectory = await getDownloadsDirectory();
          } catch (e) {
            print('Error getting downloads directory: $e');
          }
          downloadsDirectory ??= await getApplicationDocumentsDirectory();

          final filePath = p.join(downloadsDirectory.path, fileName);
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
          return filePath;
        } else {
          print('Failed to download file: ${response.statusCode}');
          return null;
        }
      } else {
        // Assume it's a local file path
        final File localFile = File(fileUrl);
        if (await localFile.exists()) {
          Directory? downloadsDirectory;
          try {
            downloadsDirectory = await getDownloadsDirectory();
          } catch (e) {
            print('Error getting downloads directory: $e');
          }
          downloadsDirectory ??= await getApplicationDocumentsDirectory();

          final filePath = p.join(downloadsDirectory.path, fileName);
          final file = File(filePath);
          await localFile.copy(filePath); // Copy local file to downloads
          return filePath;
        } else {
          print('Local file not found: $fileUrl');
          return null;
        }
      }
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }
}
