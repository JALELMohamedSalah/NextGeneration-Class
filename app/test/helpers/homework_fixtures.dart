import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/evaluation.dart';
import 'package:ngclass/domain/model/group.dart';
import 'package:ngclass/domain/model/homework.dart';
import 'package:ngclass/domain/model/results.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/domain/repositories/comment_repository.dart';
import 'package:ngclass/domain/repositories/evaluation_repository.dart';
import 'package:ngclass/domain/repositories/group_repository.dart';
import 'package:ngclass/domain/repositories/homework_repository.dart';
import 'package:ngclass/domain/repositories/results_repository.dart';

import 'content_fixtures.dart';
import 'fakes.dart';
import 'student_fixtures.dart';

/// The homework of the mockups (`r2/Devoirs.png`), on Tuesday 6 October 2026 at 10:00 in Tunis.
Assignment assignment(
  String id,
  String title, {
  DateTime? deadlineAt,
  SubmissionMode mode = SubmissionMode.file,
  StatusCounts counts = const StatusCounts(todo: 2),
  int recipients = 2,
  bool done = false,
  bool closed = false,
  bool allowLate = false,
  String contentItemId = 'serie2',
}) => Assignment(
  id: id,
  title: title,
  contentItemId: contentItemId,
  contentKind: FileKind.pdf,
  group: ref4A,
  deadlineAt: deadlineAt ?? at(8, 18),
  mode: mode,
  recipients: recipients,
  counts: counts,
  done: done,
  closed: closed,
  allowLate: allowLate,
);

List<Assignment> sampleAssignments() => [
  assignment('a-fr', 'Série 2 : les fractions', deadlineAt: at(8, 18), counts: const StatusCounts(todo: 1, submitted: 1)),
  assignment('a-lect', 'Lecture : le corbeau', deadlineAt: at(7, 18), mode: SubmissionMode.none, counts: const StatusCounts()),
  assignment(
    'a-old',
    'Série 1 : les fractions',
    deadlineAt: at(3, 18),
    done: true,
    allowLate: true,
    counts: const StatusCounts(submitted: 1, missing: 1),
  ),
];

AssignmentDetail detailOf(Assignment a) => AssignmentDetail(
  assignment: a,
  recipients: [
    RecipientRow(studentId: 's1', firstName: 'Adam', lastName: 'Gharbi', status: HomeworkStatus.submitted, submittedAt: at(3, 17, 12), submissionId: 'sub-1'),
    const RecipientRow(studentId: 's2', firstName: 'Rayen', lastName: 'Mansour', status: HomeworkStatus.missing),
  ],
);

MyHomework mineOf(
  String id,
  String title, {
  DateTime? deadlineAt,
  HomeworkStatus? status = HomeworkStatus.todo,
  SubmissionMode mode = SubmissionMode.file,
  DateTime? submittedAt,
  bool allowLate = false,
  bool closed = false,
}) => MyHomework(
  id: id,
  title: title,
  subject: mathRef,
  groupName: ref4A.name,
  deadlineAt: deadlineAt ?? at(8, 18),
  mode: mode,
  status: status,
  submittedAt: submittedAt,
  allowLate: allowLate,
  closed: closed,
);

/// "Mes devoirs": two to do, one to read, one sent last week.
List<MyHomework> sampleMine() => [
  mineOf('h-lect', 'Lecture : le corbeau et le renard', deadlineAt: at(7, 18)),
  mineOf('h-fr', 'Série 2 : les fractions', deadlineAt: at(8, 18)),
  mineOf('h-table', 'Table de 7', deadlineAt: at(12, 18), status: null, mode: SubmissionMode.none),
  mineOf('h-old', 'Série 1 : les fractions', deadlineAt: at(3, 18), status: HomeworkStatus.submitted, submittedAt: at(2, 17, 12)),
];

MyHomeworkDetail myDetailOf(MyHomework h, {SubmissionInfo? submission, bool? canSubmit}) => MyHomeworkDetail(
  homework: h,
  instructions: 'Fais les exercices 1 à 3 sur ton cahier.',
  content: const ContentRef(id: 'serie2', title: 'Série 2 : les fractions', kind: FileKind.pdf, tag: ContentTag.serie, pageCount: 3),
  submission: submission,
  canSubmit: canSubmit ?? (h.mode == SubmissionMode.file && !h.closed && h.deadlineAt.isAfter(now)),
);

/// Homework in memory, with what each call received.
class FakeHomeworkRepository implements HomeworkRepository {
  FakeHomeworkRepository({List<Assignment>? items, List<MyHomework>? mine})
    : items = items ?? sampleAssignments(),
      mineItems = mine ?? sampleMine();

  List<Assignment> items;
  List<MyHomework> mineItems;
  ApiFailure? failure;
  final List<AssignmentDraft> drafts = [];
  final List<(String, DateTime)> deadlines = [];
  final List<String> closed = [];
  final List<String?> mineAskedFor = [];
  final List<(String, PickedFile, String?)> submitted = [];
  final Map<String, MyHomeworkDetail> details = {};

  /// The pupils of a homework, by its id (otherwise Adam sent, Rayen missing).
  final Map<String, List<RecipientRow>> rows = {};

  /// "À corriger" and "Travail manquant" as the server would send them.
  List<ToCorrectGroup> queue = [];
  List<MissingWork> missingWork = [];

  /// Each pupil's copy on the correction screen, by "assignmentId/studentId".
  final Map<String, CorrectionView> corrections = {};
  final List<(String, String, double, String?)> grades = [];
  final List<(String, String, PickedFile)> attached = [];

  @override
  Future<List<Assignment>> list() async {
    if (failure != null) throw failure!;
    return items;
  }

  @override
  Future<Assignment> assign(AssignmentDraft draft) async {
    if (failure != null) throw failure!;
    drafts.add(draft);
    final saved = assignment(
      'a-new',
      draft.title,
      deadlineAt: draft.deadlineAt,
      mode: draft.mode,
      allowLate: draft.allowLate,
      contentItemId: draft.contentItemId,
      recipients: draft.studentIds.isEmpty ? 2 : draft.studentIds.length,
    );
    items = [...items, saved];
    return saved;
  }

  @override
  Future<AssignmentDetail> detail(String id) async {
    if (failure != null) throw failure!;
    final a = items.firstWhere((a) => a.id == id);
    final custom = rows[id];
    return custom == null ? detailOf(a) : AssignmentDetail(assignment: a, recipients: custom);
  }

  @override
  Future<Assignment> changeDeadline(String id, DateTime deadlineAt) async {
    deadlines.add((id, deadlineAt));
    final old = items.firstWhere((a) => a.id == id);
    final changed = assignment(old.id, old.title, deadlineAt: deadlineAt, counts: old.counts, mode: old.mode);
    items = [for (final a in items) a.id == id ? changed : a];
    return changed;
  }

  @override
  Future<void> close(String id) async {
    closed.add(id);
    final old = items.firstWhere((a) => a.id == id);
    items = [
      for (final a in items)
        a.id == id ? assignment(old.id, old.title, deadlineAt: old.deadlineAt, counts: old.counts, closed: true, done: true) : a,
    ];
  }

  @override
  Future<DocumentView> submissionView(String submissionId) async => viewOf(submissionId);

  @override
  Future<List<MyHomework>> mine({String? studentId}) async {
    if (failure != null) throw failure!;
    mineAskedFor.add(studentId);
    return mineItems;
  }

  @override
  Future<MyHomeworkDetail> myDetail(String id, {String? studentId}) async {
    if (failure != null) throw failure!;
    return details[id] ?? myDetailOf(mineItems.firstWhere((h) => h.id == id));
  }

  @override
  Future<MyHomeworkDetail> submit(String id, PickedFile file, {String? studentId, void Function(double progress)? onProgress}) async {
    if (failure != null) throw failure!;
    submitted.add((id, file, studentId));
    onProgress?.call(0.5);
    onProgress?.call(1);
    final old = await myDetail(id, studentId: studentId);
    final h = old.homework;
    final sent = MyHomeworkDetail(
      homework: MyHomework(
        id: h.id,
        title: h.title,
        subject: h.subject,
        groupName: h.groupName,
        deadlineAt: h.deadlineAt,
        mode: h.mode,
        allowLate: h.allowLate,
        status: HomeworkStatus.submitted,
        submittedAt: now,
      ),
      instructions: old.instructions,
      content: old.content,
      submission: SubmissionInfo(id: 'sub-new', submittedAt: now, fileName: file.name, pageCount: 2),
      canSubmit: true,
    );
    details[id] = sent;
    return sent;
  }

  @override
  Future<DocumentView> mySubmissionView(String id, {String? studentId}) async => viewOf('work-$id');

  @override
  Future<DocumentView> myCorrectionView(String id, {String? studentId}) async => viewOf('correction-$id', pages: 1);

  @override
  Future<List<ToCorrectGroup>> toCorrect() async {
    if (failure != null) throw failure!;
    return queue;
  }

  @override
  Future<List<MissingWork>> missing() async {
    if (failure != null) throw failure!;
    return missingWork;
  }

  @override
  Future<CorrectionView> correction(String assignmentId, String studentId) async {
    if (failure != null) throw failure!;
    return corrections['$assignmentId/$studentId'] ?? copyOf(assignmentId, studentId);
  }

  @override
  Future<CorrectionView> correct(String assignmentId, String studentId, {required double score, String? comment}) async {
    if (failure != null) throw failure!;
    grades.add((assignmentId, studentId, score, comment));
    final old = await correction(assignmentId, studentId);
    return corrections['$assignmentId/$studentId'] = CorrectionView(
      assignmentId: assignmentId,
      studentId: studentId,
      firstName: old.firstName,
      lastName: old.lastName,
      status: HomeworkStatus.corrected,
      maxScore: old.maxScore,
      submission: old.submission,
      score: score,
      comment: comment == null || comment.trim().isEmpty ? null : comment.trim(),
      correctedAt: now,
      file: old.file,
    );
  }

  @override
  Future<CorrectionView> attachCorrection(String assignmentId, String studentId, PickedFile file, {void Function(double progress)? onProgress}) async {
    attached.add((assignmentId, studentId, file));
    onProgress?.call(1);
    final old = await correction(assignmentId, studentId);
    return corrections['$assignmentId/$studentId'] = _withFile(old, CorrectionFile(fileName: file.name, kind: FileKind.pdf, pageCount: 1));
  }

  @override
  Future<CorrectionView> removeCorrectionFile(String assignmentId, String studentId) async =>
      corrections['$assignmentId/$studentId'] = _withFile(await correction(assignmentId, studentId), null);

  @override
  Future<DocumentView> correctionFileView(String assignmentId, String studentId) async => viewOf('correction-$studentId', pages: 1);

  static CorrectionView _withFile(CorrectionView v, CorrectionFile? file) => CorrectionView(
    assignmentId: v.assignmentId,
    studentId: v.studentId,
    firstName: v.firstName,
    lastName: v.lastName,
    status: v.status,
    maxScore: v.maxScore,
    submission: v.submission,
    score: v.score,
    comment: v.comment,
    correctedAt: v.correctedAt,
    file: file,
  );
}

/// One pupil's copy, sent on Friday at 17:12 (two pages), not corrected yet.
CorrectionView copyOf(String assignmentId, String studentId, {String firstName = 'Adam', String lastName = 'Gharbi'}) => CorrectionView(
  assignmentId: assignmentId,
  studentId: studentId,
  firstName: studentId == 's2' ? 'Rayen' : firstName,
  lastName: studentId == 's2' ? 'Mansour' : lastName,
  status: studentId == 's2' ? HomeworkStatus.missing : HomeworkStatus.submitted,
  maxScore: 20,
  submission: studentId == 's2' ? null : SubmissionInfo(id: 'sub-$studentId', submittedAt: at(3, 17, 12), fileName: 'travail.pdf', pageCount: 2),
);

/// Adam's results: Maths with four grades (one out of 10), Lecture without any.
MyResults sampleResults() => MyResults(
  subjects: [
    SubjectResult(
      subject: mathRef,
      average: 12.5,
      gradeCount: 4,
      trend: Trend.up,
      submitted: 4,
      due: 5,
      attendanceRate: 95,
      grades: [
        GradeItem(assignmentId: 'a-d', title: 'Série D', date: at(6, 9), score: 16, maxScore: 20, score20: 16, comment: 'Très bien !'),
        GradeItem(assignmentId: 'a-c', title: 'Série C', date: at(5, 9), score: 14, maxScore: 20, score20: 14),
        GradeItem(assignmentId: 'a-b', title: 'Série B', date: at(2, 9), score: 10, maxScore: 20, score20: 10),
        GradeItem(assignmentId: 'a-a', title: 'Série A', date: at(1, 9), score: 5, maxScore: 10, score20: 10),
      ],
    ),
    const SubjectResult(subject: lectureRef, submitted: 1, due: 1),
  ],
);

/// Paper evaluations: none unless a test adds some. The other calls are for the evaluation tests to fill in.
class FakeEvaluationRepository implements EvaluationRepository {
  FakeEvaluationRepository({List<Evaluation>? items, Map<String, EvaluationDetail>? details})
    : items = items ?? [],
      details = details ?? {};

  List<Evaluation> items;

  /// What detail() reads; create() starts from the group's pupils of [newPupils].
  final Map<String, EvaluationDetail> details;
  List<EvaluationGrade> newPupils = sampleEvaluationDetail().grades.map((g) => EvaluationGrade(studentId: g.studentId, firstName: g.firstName, lastName: g.lastName)).toList();
  final List<EvaluationDraft> drafts = [];
  final List<(String, List<GradeInput>)> saves = [];
  ApiFailure? failure;

  @override
  Future<List<Evaluation>> list() async => items;

  @override
  Future<EvaluationDetail> create(EvaluationDraft draft) async {
    if (failure != null) throw failure!;
    drafts.add(draft);
    final created = EvaluationDetail(
      evaluation: Evaluation(
        id: 'e-new',
        title: draft.title.trim(),
        group: ref4A,
        heldOn: draft.heldOn,
        maxScore: draft.maxScore,
        chapterId: draft.chapterId,
        pupils: newPupils.length,
      ),
      grades: newPupils,
    );
    details['e-new'] = created;
    return created;
  }

  @override
  Future<EvaluationDetail> detail(String id) async {
    if (failure != null) throw failure!;
    return details[id] ?? (throw const ApiFailure(code: 'evaluation_not_found'));
  }

  @override
  Future<EvaluationDetail> update(String id, EvaluationDraft draft) async {
    if (failure != null) throw failure!;
    drafts.add(draft);
    final old = details[id]!;
    final e = old.evaluation;
    final updated = EvaluationDetail(
      evaluation: Evaluation(
        id: e.id,
        title: draft.title.trim(),
        group: e.group,
        heldOn: draft.heldOn,
        maxScore: draft.maxScore,
        chapterId: draft.chapterId,
        pupils: e.pupils,
        graded: e.graded,
        absent: e.absent,
        average: e.average,
      ),
      grades: old.grades,
    );
    details[id] = updated;
    return updated;
  }

  @override
  Future<EvaluationDetail> saveGrades(String id, List<GradeInput> grades) async {
    if (failure != null) throw failure!;
    saves.add((id, grades));
    final old = details[id]!;
    final byId = {for (final g in grades) g.studentId: g};
    final rows = [
      for (final g in old.grades)
        if (byId[g.studentId] case final input?)
          EvaluationGrade(
            studentId: g.studentId,
            firstName: g.firstName,
            lastName: g.lastName,
            score: input.absent ? null : input.score,
            absent: input.absent,
            comment: (input.comment ?? '').trim().isEmpty ? null : input.comment!.trim(),
          )
        else
          g,
    ];
    final scores = [for (final r in rows) if (r.score != null) r.score!];
    final saved = EvaluationDetail(
      evaluation: Evaluation(
        id: old.evaluation.id,
        title: old.evaluation.title,
        group: old.evaluation.group,
        heldOn: old.evaluation.heldOn,
        maxScore: old.evaluation.maxScore,
        pupils: rows.length,
        graded: scores.length,
        absent: rows.where((r) => r.absent).length,
        average: scores.isEmpty ? null : scores.reduce((a, b) => a + b) / scores.length,
      ),
      grades: rows,
    );
    details[id] = saved;
    return saved;
  }
}

/// "Évaluation : la multiplication" of 4ème année · Maths, Wednesday 7 October, on 20 (design `r2/Evaluation.png`):
/// three scores, one absent, two to type.
EvaluationDetail sampleEvaluationDetail({int maxScore = 20}) => EvaluationDetail(
  evaluation: Evaluation(
    id: 'e1',
    title: 'Évaluation : la multiplication',
    group: ref4A,
    heldOn: DateTime.utc(2026, 10, 7),
    maxScore: maxScore,
    chapterTitle: 'La multiplication',
    pupils: 6,
    graded: 3,
    absent: 1,
    average: 14.5,
  ),
  grades: const [
    EvaluationGrade(studentId: 's-adam', firstName: 'Adam', lastName: 'Gharbi', score: 15, comment: 'Très bien, continue.'),
    EvaluationGrade(studentId: 's-amine', firstName: 'Amine', lastName: 'Kefi', score: 11.5),
    EvaluationGrade(studentId: 's-omar', firstName: 'Omar', lastName: 'Saidi'),
    EvaluationGrade(studentId: 's-rayen', firstName: 'Rayen', lastName: 'Mansour', absent: true, comment: 'Malade, à rattraper.'),
    EvaluationGrade(studentId: 's-sami', firstName: 'Sami', lastName: 'Ben Salah', score: 17),
    EvaluationGrade(studentId: 's-yasmine', firstName: 'Yasmine', lastName: 'Ben Abdallah Trabelsi'),
  ],
);

/// A row of the "Évaluations" tab.
Evaluation sampleEvaluation() => sampleEvaluationDetail().evaluation;

class FakeResultsRepository implements ResultsRepository {
  FakeResultsRepository({MyResults? results}) : results = results ?? sampleResults();

  MyResults results;
  ApiFailure? failure;
  final List<String?> askedFor = [];

  @override
  Future<MyResults> mine({String? studentId}) async {
    if (failure != null) throw failure!;
    askedFor.add(studentId);
    return results;
  }

  @override
  Future<MyResults> forStudent(String studentId) async {
    if (failure != null) throw failure!;
    askedFor.add(studentId);
    return results;
  }
}

/// The teacher's comments a family reads ("Mot de l'enseignante"), latest first.
class FakeCommentRepository implements CommentRepository {
  FakeCommentRepository({List<NoteEntry>? items}) : items = items ?? [];

  List<NoteEntry> items;
  final List<String?> askedFor = [];

  @override
  Future<List<NoteEntry>> mine({String? studentId}) async {
    askedFor.add(studentId);
    return items;
  }
}

/// A group with two pupils, for "Des élèves".
class FakeGroupWithMembers extends FakeGroupRepository {
  @override
  Future<GroupDetail> detail(String groupId) async => const GroupDetail(
    group: group4A,
    members: [
      GroupMember(studentId: 's1', firstName: 'Adam', lastName: 'Gharbi', username: 'adam.gharbi'),
      GroupMember(studentId: 's2', firstName: 'Rayen', lastName: 'Mansour', username: 'rayen.mansour'),
    ],
  );
}

/// The homework and content services the screens read from the locator.
({FakeHomeworkRepository homework, FakeContentRepository content, FakeFileChooser chooser, FakeResultsRepository results}) registerHomeworkServices({
  FakeHomeworkRepository? homework,
  GroupRepository? groups,
  FakeResultsRepository? results,
  FakeEvaluationRepository? evaluations,
}) {
  final repo = homework ?? FakeHomeworkRepository();
  final content = registerContentServices();
  final grades = results ?? FakeResultsRepository();
  sl.registerSingleton<HomeworkRepository>(repo);
  sl.registerSingleton<GroupRepository>(groups ?? FakeGroupWithMembers());
  sl.registerSingleton<ResultsRepository>(grades);
  sl.registerSingleton<EvaluationRepository>(evaluations ?? FakeEvaluationRepository());
  sl.registerSingleton<CommentRepository>(FakeCommentRepository());
  return (homework: repo, content: content.repository, chooser: content.chooser, results: grades);
}
