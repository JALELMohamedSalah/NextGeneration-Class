import '../../domain/model/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../dto/school_dto.dart';
import '../remote/school_api.dart';
import 'api_guard.dart';

class GroupRepositoryImpl implements GroupRepository {
  GroupRepositoryImpl(this._api);

  final SchoolApi _api;

  @override
  Future<List<Group>> list() => guard(() async => [for (final g in await _api.groups()) GroupDto(g).toDomain()]);

  @override
  Future<GroupDetail> detail(String groupId) => guard(() async => GroupDetailDto(await _api.group(groupId)).toDomain());

  @override
  Future<Group> create(GroupDraft draft) => guard(() async => GroupDto(await _api.createGroup(_json(draft))).toDomain());

  @override
  Future<Group> update(String groupId, GroupDraft draft) =>
      guard(() async => GroupDto(await _api.updateGroup(groupId, _json(draft))).toDomain());

  @override
  Future<void> archive(String groupId) => guard(() => _api.archiveGroup(groupId));

  @override
  Future<GroupDetail> setMembers(String groupId, List<String> studentIds) =>
      guard(() async => GroupDetailDto(await _api.setMembers(groupId, studentIds)).toDomain());

  @override
  Future<Group> createPrivateLesson({required String studentId, required String subjectId}) =>
      guard(() async => GroupDto(await _api.createPrivateLesson(studentId, subjectId)).toDomain());

  static Json _json(GroupDraft draft) => {
    'name': draft.name.trim(),
    'subjectId': draft.subjectId,
    'levelId': draft.levelId,
    'defaultMeetUrl': draft.defaultMeetUrl,
    'color': draft.color,
  };
}
