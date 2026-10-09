import '../../domain/model/results.dart';
import '../../domain/repositories/results_repository.dart';
import '../dto/results_dto.dart';
import '../remote/results_api.dart';
import 'api_guard.dart';

class ResultsRepositoryImpl implements ResultsRepository {
  ResultsRepositoryImpl(this._api);

  final ResultsApi _api;

  @override
  Future<MyResults> mine({String? studentId}) => guard(() async => myResultsOf(await _api.mine(studentId: studentId)));

  @override
  Future<MyResults> forStudent(String studentId) => guard(() async => myResultsOf(await _api.forStudent(studentId)));
}
