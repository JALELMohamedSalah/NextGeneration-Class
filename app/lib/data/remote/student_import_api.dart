import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/students/import` (docs/HANDOVER.md, API).
class StudentImportApi {
  StudentImportApi(this._dio);

  final Dio _dio;

  Future<Json> preview(List<int> bytes, String fileName, {String? groupId, String? levelId}) async {
    final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)});
    return (await _dio.post<Json>(
      '/students/import/preview',
      data: form,
      queryParameters: {'groupId': ?groupId, 'levelId': ?levelId},
    )).data!;
  }

  Future<Json> importRows(Json body) async => (await _dio.post<Json>('/students/import', data: body)).data!;

  String templateUrl(String languageCode) => '${_dio.options.baseUrl}/students/import/template?lang=$languageCode';
}
