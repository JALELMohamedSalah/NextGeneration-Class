import 'package:dio/dio.dart';

import '../dto/school_dto.dart';

/// `/assignments` and `/me/assignments` (docs/HANDOVER.md, API).
class HomeworkApi {
  HomeworkApi(this._dio);

  final Dio _dio;

  Future<List<Json>> list() async => jsonList((await _dio.get<List<dynamic>>('/assignments')).data);

  Future<Json> assign(Json body) async => (await _dio.post<Json>('/assignments', data: body)).data!;

  Future<Json> detail(String id) async => (await _dio.get<Json>('/assignments/$id')).data!;

  Future<Json> deadline(String id, String deadlineAt) async =>
      (await _dio.put<Json>('/assignments/$id/deadline', data: {'deadlineAt': deadlineAt})).data!;

  Future<void> close(String id) => _dio.post<void>('/assignments/$id/close');

  Future<Json> submissionView(String submissionId) async => (await _dio.get<Json>('/assignments/submissions/$submissionId/view')).data!;

  Future<List<Json>> mine({String? studentId}) async =>
      jsonList((await _dio.get<List<dynamic>>('/me/assignments', queryParameters: {'studentId': ?studentId})).data);

  Future<Json> myDetail(String id, {String? studentId}) async =>
      (await _dio.get<Json>('/me/assignments/$id', queryParameters: {'studentId': ?studentId})).data!;

  Future<Json> submit(
    String id,
    List<int> bytes,
    String fileName, {
    String? studentId,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)});
    return (await _dio.post<Json>(
      '/me/assignments/$id/submission',
      data: form,
      queryParameters: {'studentId': ?studentId},
      onSendProgress: onSendProgress,
    )).data!;
  }

  Future<Json> mySubmissionView(String id, {String? studentId}) async =>
      (await _dio.get<Json>('/me/assignments/$id/submission/view', queryParameters: {'studentId': ?studentId})).data!;

  Future<Json> myCorrectionView(String id, {String? studentId}) async =>
      (await _dio.get<Json>('/me/assignments/$id/correction/view', queryParameters: {'studentId': ?studentId})).data!;

  Future<List<Json>> toCorrect() async => jsonList((await _dio.get<List<dynamic>>('/assignments/to-correct')).data);

  Future<List<Json>> missing() async => jsonList((await _dio.get<List<dynamic>>('/assignments/missing')).data);

  Future<Json> correction(String id, String studentId) async => (await _dio.get<Json>('/assignments/$id/corrections/$studentId')).data!;

  Future<Json> correct(String id, String studentId, Json body) async =>
      (await _dio.put<Json>('/assignments/$id/corrections/$studentId', data: body)).data!;

  Future<Json> attachCorrection(
    String id,
    String studentId,
    List<int> bytes,
    String fileName, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final form = FormData.fromMap({'file': MultipartFile.fromBytes(bytes, filename: fileName)});
    return (await _dio.put<Json>('/assignments/$id/corrections/$studentId/file', data: form, onSendProgress: onSendProgress)).data!;
  }

  Future<Json> removeCorrectionFile(String id, String studentId) async =>
      (await _dio.delete<Json>('/assignments/$id/corrections/$studentId/file')).data!;

  Future<Json> correctionFileView(String id, String studentId) async =>
      (await _dio.get<Json>('/assignments/$id/corrections/$studentId/file/view')).data!;
}
