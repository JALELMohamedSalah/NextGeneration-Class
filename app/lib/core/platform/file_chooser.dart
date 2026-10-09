import 'package:file_picker/file_picker.dart';

import '../../domain/model/content.dart';

/// Lets the user choose a document on the device (spec 04 uploads).
abstract interface class FileChooser {
  /// Null when the user closed the picker.
  Future<PickedFile?> pickDocument();

  /// A class list to import: Excel (.xlsx) or CSV. Null when the user closed the picker.
  Future<PickedFile?> pickSpreadsheet();
}

class FilePickerChooser implements FileChooser {
  @override
  Future<PickedFile?> pickDocument() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png', 'docx']);
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.readAsBytes());
  }

  @override
  Future<PickedFile?> pickSpreadsheet() async {
    final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: const ['xlsx', 'csv']);
    if (file == null) return null;
    return PickedFile(name: file.name, bytes: await file.readAsBytes());
  }
}
