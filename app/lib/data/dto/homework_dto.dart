import '../../domain/model/homework.dart';
import 'content_dto.dart';
import 'school_dto.dart';

HomeworkStatus? homeworkStatus(Object? value) => switch (value) {
  'TODO' => HomeworkStatus.todo,
  'SUBMITTED' => HomeworkStatus.submitted,
  'LATE' => HomeworkStatus.late,
  'MISSING' => HomeworkStatus.missing,
  'CORRECTED' => HomeworkStatus.corrected,
  _ => null,
};

SubmissionMode submissionMode(Object? value) => value == 'NONE' ? SubmissionMode.none : SubmissionMode.file;

String submissionModeParam(SubmissionMode mode) => mode == SubmissionMode.none ? 'NONE' : 'FILE';

StatusCounts _counts(Object? value) {
  final json = value as Json? ?? const {};
  int n(String key) => (json[key] as num? ?? 0).toInt();
  return StatusCounts(todo: n('todo'), submitted: n('submitted'), late: n('late'), missing: n('missing'), corrected: n('corrected'));
}

Assignment assignmentOf(Json json) => Assignment(
  id: json['id'] as String,
  title: json['title'] as String? ?? '',
  contentItemId: json['contentItemId'] as String,
  contentKind: fileKind(json['contentKind']),
  group: groupRef(json['group'] as Json),
  wholeGroup: json['wholeGroup'] as bool? ?? true,
  deadlineAt: instant(json['deadlineAt'])!,
  mode: submissionMode(json['submissionMode']),
  allowLate: json['allowLate'] as bool? ?? false,
  instructions: json['instructions'] as String?,
  closed: json['closed'] as bool? ?? false,
  done: json['done'] as bool? ?? false,
  recipients: (json['recipients'] as num? ?? 0).toInt(),
  counts: _counts(json['counts']),
  maxScore: (json['maxScore'] as num? ?? 20).toInt(),
  subjectId: json['subjectId'] as String?,
  average: (json['average'] as num?)?.toDouble(),
);

AssignmentDetail assignmentDetailOf(Json json) => AssignmentDetail(
  assignment: assignmentOf(json['assignment'] as Json),
  recipients: [
    for (final r in jsonList(json['recipients']))
      RecipientRow(
        studentId: r['studentId'] as String,
        firstName: r['firstName'] as String? ?? '',
        lastName: r['lastName'] as String? ?? '',
        status: homeworkStatus(r['status']),
        submittedAt: instant(r['submittedAt']),
        submissionId: r['submissionId'] as String?,
        score: (r['score'] as num?)?.toDouble(),
      ),
  ],
);

Json assignmentDraftJson(AssignmentDraft draft) => {
  'contentItemId': draft.contentItemId,
  'title': draft.title.trim(),
  'groupId': draft.groupId,
  'studentIds': draft.studentIds,
  'deadlineAt': draft.deadlineAt.toUtc().toIso8601String(),
  'submissionMode': submissionModeParam(draft.mode),
  'allowLate': draft.allowLate,
  if (draft.instructions.trim().isNotEmpty) 'instructions': draft.instructions.trim(),
};

MyHomework myHomeworkOf(Json json) {
  final subject = json['subject'] as Json;
  return MyHomework(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    subject: subjectRefOf(subject),
    groupName: json['groupName'] as String? ?? '',
    deadlineAt: instant(json['deadlineAt'])!,
    mode: submissionMode(json['submissionMode']),
    allowLate: json['allowLate'] as bool? ?? false,
    closed: json['closed'] as bool? ?? false,
    status: homeworkStatus(json['status']),
    submittedAt: instant(json['submittedAt']),
    score: (json['score'] as num?)?.toDouble(),
    maxScore: (json['maxScore'] as num? ?? 20).toInt(),
  );
}

SubmissionInfo? _submission(Object? value) {
  final json = value as Json?;
  return json == null
      ? null
      : SubmissionInfo(
          id: json['id'] as String,
          submittedAt: instant(json['submittedAt'])!,
          late: json['late'] as bool? ?? false,
          fileName: json['fileName'] as String? ?? '',
          pageCount: (json['pageCount'] as num?)?.toInt(),
        );
}

CorrectionFile? _correctionFile(Object? value) {
  final json = value as Json?;
  return json == null
      ? null
      : CorrectionFile(
          fileName: json['fileName'] as String? ?? '',
          kind: fileKind(json['kind']),
          pageCount: (json['pageCount'] as num?)?.toInt(),
        );
}

Correction? _correction(Object? value) {
  final json = value as Json?;
  return json == null
      ? null
      : Correction(
          score: (json['score'] as num).toDouble(),
          maxScore: (json['maxScore'] as num? ?? 20).toInt(),
          comment: json['comment'] as String?,
          correctedAt: instant(json['correctedAt'])!,
          file: _correctionFile(json['file']),
        );
}

CorrectionView correctionViewOf(Json json) => CorrectionView(
  assignmentId: json['assignmentId'] as String,
  studentId: json['studentId'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  status: homeworkStatus(json['status']),
  maxScore: (json['maxScore'] as num? ?? 20).toInt(),
  submission: _submission(json['submission']),
  score: (json['score'] as num?)?.toDouble(),
  comment: json['comment'] as String?,
  correctedAt: instant(json['correctedAt']),
  file: _correctionFile(json['file']),
);

ToCorrectGroup toCorrectGroupOf(Json json) => ToCorrectGroup(
  assignment: assignmentOf(json['assignment'] as Json),
  items: [
    for (final i in jsonList(json['items']))
      ToCorrectItem(
        studentId: i['studentId'] as String,
        firstName: i['firstName'] as String? ?? '',
        lastName: i['lastName'] as String? ?? '',
        status: homeworkStatus(i['status']),
        submittedAt: instant(i['submittedAt'])!,
        submissionId: i['submissionId'] as String,
      ),
  ],
);

MissingWork missingWorkOf(Json json) => MissingWork(
  assignment: assignmentOf(json['assignment'] as Json),
  missing: [
    for (final m in jsonList(json['missing']))
      PupilName(studentId: m['studentId'] as String, firstName: m['firstName'] as String? ?? '', lastName: m['lastName'] as String? ?? ''),
  ],
);

MyHomeworkDetail myHomeworkDetailOf(Json json) {
  final content = json['content'] as Json;
  final submission = json['submission'] as Json?;
  return MyHomeworkDetail(
    homework: myHomeworkOf(json['homework'] as Json),
    instructions: json['instructions'] as String?,
    content: ContentRef(
      id: content['id'] as String,
      title: content['title'] as String? ?? '',
      kind: fileKind(content['kind']),
      tag: contentTag(content['tag']),
      pageCount: (content['pageCount'] as num?)?.toInt(),
    ),
    submission: _submission(submission),
    canSubmit: json['canSubmit'] as bool? ?? false,
    correction: _correction(json['correction']),
  );
}
