import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/utils/user_error.dart';

const _documentExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'webp'];

Future<Directory> _documentsDirectory() async {
  final base = await getApplicationSupportDirectory();
  final dir = Directory(p.join(base.path, 'documents'));
  await dir.create(recursive: true);
  return dir;
}

Future<XFile?> pickDocumentFile() {
  return openFile(
    acceptedTypeGroups: const [
      XTypeGroup(
        label: 'Documentos e imágenes',
        extensions: _documentExtensions,
      ),
    ],
  );
}

Future<XFile?> takeDocumentPhoto() {
  return ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 85);
}

Future<String> copyDocumentFile(XFile file) async {
  final dir = await _documentsDirectory();
  final safeName = p
      .basename(file.name)
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  final target = File(
    p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_$safeName'),
  );
  await File(file.path).copy(target.path);
  return target.path;
}

Future<void> deleteDocumentFile(String? path) async {
  if (path == null || path.isEmpty) return;
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  } catch (error) {
    logError('eliminar adjunto', error, StackTrace.current);
  }
}
