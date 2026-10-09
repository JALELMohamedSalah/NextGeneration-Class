import '../../domain/model/content.dart';
import '../../domain/model/student_import.dart';
import '../../domain/repositories/student_import_repository.dart';
import '../dto/school_dto.dart';
import '../dto/student_dto.dart';
import '../remote/student_import_api.dart';
import 'api_guard.dart';

class StudentImportRepositoryImpl implements StudentImportRepository {
  StudentImportRepositoryImpl(this._api);

  final StudentImportApi _api;

  @override
  Future<ImportPreview> preview(PickedFile file, {String? groupId, String? levelId}) => guard(() async {
    final json = await _api.preview(file.bytes, file.name, groupId: groupId, levelId: levelId);
    return ImportPreview(fileName: json['fileName'] as String? ?? file.name, rows: [for (final r in jsonList(json['rows'])) importRow(r)]);
  });

  @override
  Future<ImportResult> importRows(List<ImportRow> rows, {required bool createLogins}) => guard(() async {
    final json = await _api.importRows({
      'createLogins': createLogins,
      'rows': [
        for (final r in rows)
          {
            'line': r.line,
            'firstName': r.firstName,
            'lastName': r.lastName,
            'levelId': r.levelId,
            'groupIds': r.groupIds,
            'phone': r.phone,
            'parentFirstName': r.parentFirstName,
            'parentLastName': r.parentLastName,
            'parentPhone': r.parentPhone,
          },
      ],
    });
    return ImportResult(
      created: (json['created'] as num? ?? 0).toInt(),
      linked: (json['linked'] as num? ?? 0).toInt(),
      accounts: [
        for (final c in jsonList(json['credentials']))
          ImportedAccount(
            account: newAccount(c['credential'] as Json),
            children: [for (final name in (c['children'] as List<dynamic>? ?? const [])) name as String],
          ),
      ],
    );
  });

  @override
  String templateUrl(String languageCode) => _api.templateUrl(languageCode);
}

ImportRow importRow(Json json) => ImportRow(
  line: (json['line'] as num).toInt(),
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  levelId: json['levelId'] as String?,
  levelText: json['levelText'] as String? ?? '',
  groupIds: [for (final id in (json['groupIds'] as List<dynamic>? ?? const [])) id as String],
  groupText: json['groupText'] as String? ?? '',
  phone: json['phone'] as String? ?? '',
  parentFirstName: json['parentFirstName'] as String? ?? '',
  parentLastName: json['parentLastName'] as String? ?? '',
  parentPhone: json['parentPhone'] as String? ?? '',
  state: switch (json['state']) {
    'READY' => ImportState.ready,
    'PARENT_KNOWN' => ImportState.parentKnown,
    'EXISTS' => ImportState.exists,
    _ => ImportState.error,
  },
  problems: [for (final p in (json['problems'] as List<dynamic>? ?? const [])) p as String],
  knownParent: json['knownParent'] as String?,
  sameParentAs: (json['sameParentAs'] as num?)?.toInt(),
  sameAs: (json['sameAs'] as num?)?.toInt(),
);
