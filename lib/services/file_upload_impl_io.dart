import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
}
