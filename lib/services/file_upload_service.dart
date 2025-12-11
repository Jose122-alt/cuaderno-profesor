import 'dart:typed_data';
import 'file_upload_impl_io.dart' if (dart.library.html) 'file_upload_impl_web.dart';

class FileUploadService {
  Future<String?> uploadFileFromPath(String path, String targetPath) {
    return FileUploadImpl().uploadFileFromPath(path, targetPath);
  }

  Future<String?> uploadBytes(Uint8List bytes, String filename, String targetPath) {
    return FileUploadImpl().uploadBytes(bytes, filename, targetPath);
  }
}
