import 'dart:convert';

import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/contents`, `/chapters`, `/me/contents` (docs/HANDOVER.md, API).
class ContentApi {
  ContentApi(this._dio);

  final Dio _dio;

  Future<Json> library() async => (await _dio.get<Json>('/contents')).data!;

  Future<Json> createChapter(Json body) async => (await _dio.post<Json>('/chapters', data: body)).data!;

  Future<Json> renameChapter(String id, String title) async => (await _dio.put<Json>('/chapters/$id', data: {'title': title})).data!;

  Future<void> deleteChapter(String id) => _dio.delete<void>('/chapters/$id');

  Future<Json> shareChapter(String id, List<String> groupIds) async =>
      (await _dio.put<Json>('/chapters/$id/shares', data: {'groupIds': groupIds})).data!;

  /// Two parts: the file, and "meta" as JSON.
  Future<Json> upload(Json meta, List<int> bytes, String fileName, {void Function(int sent, int total)? onSendProgress}) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
      'meta': MultipartFile.fromString(jsonEncode(meta), contentType: DioMediaType.parse('application/json')),
    });
    return (await _dio.post<Json>('/contents', data: form, onSendProgress: onSendProgress)).data!;
  }

  Future<Json> update(String id, Json body) async => (await _dio.put<Json>('/contents/$id', data: body)).data!;

  Future<Json> share(String id, List<String> groupIds) async =>
      (await _dio.put<Json>('/contents/$id/shares', data: {'groupIds': groupIds})).data!;

  Future<void> archive(String id) => _dio.post<void>('/contents/$id/archive');

  Future<Json> view(String id) async => (await _dio.get<Json>('/contents/$id/view')).data!;

  Future<List<Json>> mine({String? studentId}) async =>
      jsonList((await _dio.get<List<dynamic>>('/me/contents', queryParameters: {'studentId': ?studentId})).data);
}
