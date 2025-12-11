import 'dart:typed_data';
import 'package:path/path.dart' as p;

class FileUploadImpl {
  Future<String?> uploadFileFromPath(String path, String targetPath) async {
    return null;
  }

  Future<String?> uploadBytes(Uint8List bytes, String filename, String targetPath) async {
    final safeName = p.basename(filename);
    return 'web-upload://$targetPath/$safeName';
  }
}
