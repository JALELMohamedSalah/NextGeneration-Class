import '../model/content.dart';
import '../model/student_import.dart';

/// Importing pupils from Excel or CSV (`/students/import`), teacher only. Every call throws an `ApiFailure` when refused.
abstract interface class StudentImportRepository {
  /// Reads and checks the file; nothing is created. [groupId] for everyone, [levelId] when a line has none.
  Future<ImportPreview> preview(PickedFile file, {String? groupId, String? levelId});

  /// Creates the lines kept, all or none.
  Future<ImportResult> importRows(List<ImportRow> rows, {required bool createLogins});

  /// The empty template in the teacher's language ("fr" or "ar"), as a link to download.
  String templateUrl(String languageCode);
}
