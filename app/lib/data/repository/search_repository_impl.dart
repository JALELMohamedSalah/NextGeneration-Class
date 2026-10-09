import '../../domain/model/localized_text.dart';
import '../../domain/model/search.dart';
import '../../domain/repositories/search_repository.dart';
import '../dto/content_dto.dart';
import '../dto/school_dto.dart';
import '../dto/user_dto.dart';
import '../remote/search_api.dart';
import 'api_guard.dart';

class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._api);

  final SearchApi _api;

  @override
  Future<SearchResults> search(String query) => guard(() async => searchResults(await _api.search(query)));
}

SearchResults searchResults(Json json) {
  LocalizedText? text(Object? value) => value == null ? null : localizedText(value);
  return SearchResults(
    hits: [
      for (final s in jsonList(json['students']))
        StudentHit(
          id: s['id'] as String,
          firstName: s['firstName'] as String? ?? '',
          lastName: s['lastName'] as String? ?? '',
          level: text(s['level']),
          groups: [for (final g in (s['groups'] as List<dynamic>? ?? const [])) g as String],
        ),
      for (final p in jsonList(json['parents']))
        ParentHit(
          id: p['id'] as String,
          firstName: p['firstName'] as String? ?? '',
          lastName: p['lastName'] as String? ?? '',
          phone: p['phone'] as String?,
          children: [for (final c in jsonList(p['children'])) ChildRef(id: c['id'] as String, firstName: c['firstName'] as String? ?? '')],
        ),
      for (final g in jsonList(json['groups']))
        GroupHit(
          id: g['id'] as String,
          name: g['name'] as String? ?? '',
          code: g['code'] as String? ?? '',
          color: g['color'] as String? ?? '#2B3990',
          privateLesson: g['privateLesson'] as bool? ?? false,
          memberCount: (g['memberCount'] as num? ?? 0).toInt(),
        ),
      for (final d in jsonList(json['documents']))
        DocumentHit(
          id: d['id'] as String,
          name: d['title'] as String? ?? '',
          tag: contentTag(d['tag']),
          fileKind: fileKind(d['kind']),
          subject: text(d['subject']),
          level: text(d['level']),
          chapter: d['chapter'] as String?,
        ),
      for (final c in jsonList(json['chapters']))
        ChapterHit(
          id: c['id'] as String,
          name: c['title'] as String? ?? '',
          subject: text(c['subject']),
          level: text(c['level']),
          documents: (c['documents'] as num? ?? 0).toInt(),
        ),
      for (final h in jsonList(json['homework']))
        HomeworkHit(
          id: h['id'] as String,
          name: h['title'] as String? ?? '',
          group: groupRef(h['group'] as Json),
          deadlineAt: instant(h['deadlineAt'])!,
          toCorrect: (h['toCorrect'] as num? ?? 0).toInt(),
          done: h['done'] as bool? ?? false,
        ),
      for (final e in jsonList(json['evaluations']))
        EvaluationHit(
          id: e['id'] as String,
          name: e['title'] as String? ?? '',
          group: groupRef(e['group'] as Json),
          heldOn: DateTime.parse('${e['heldOn']}T00:00:00Z'),
        ),
    ],
  );
}
