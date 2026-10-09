import '../model/group.dart';

abstract interface class GroupRepository {
  Future<List<Group>> list();

  Future<GroupDetail> detail(String groupId);

  Future<Group> create(GroupDraft draft);

  Future<Group> update(String groupId, GroupDraft draft);

  Future<void> archive(String groupId);

  Future<GroupDetail> setMembers(String groupId, List<String> studentIds);

  Future<Group> createPrivateLesson({required String studentId, required String subjectId});
}
