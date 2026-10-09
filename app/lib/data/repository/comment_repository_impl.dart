import '../../domain/model/student.dart';
import '../../domain/repositories/comment_repository.dart';
import '../dto/student_dto.dart';
import '../remote/comments_api.dart';
import 'api_guard.dart';

class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._api);

  final CommentsApi _api;

  @override
  Future<List<NoteEntry>> mine({String? studentId}) => guard(() async => [for (final c in await _api.mine(studentId: studentId)) noteEntry(c)]);
}
