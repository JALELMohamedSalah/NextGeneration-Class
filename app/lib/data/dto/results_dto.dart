import '../../domain/model/results.dart';
import 'content_dto.dart';
import 'school_dto.dart';

Trend? _trend(Object? value) => switch (value) {
  'UP' => Trend.up,
  'DOWN' => Trend.down,
  'STABLE' => Trend.stable,
  _ => null,
};

MyResults myResultsOf(Json json) => MyResults(
  subjects: [
    for (final s in jsonList(json['subjects']))
      SubjectResult(
        subject: subjectRefOf(s['subject'] as Json),
        average: (s['average'] as num?)?.toDouble(),
        gradeCount: (s['gradeCount'] as num? ?? 0).toInt(),
        trend: _trend(s['trend']),
        submitted: (s['submitted'] as num? ?? 0).toInt(),
        due: (s['due'] as num? ?? 0).toInt(),
        attendanceRate: (s['attendanceRate'] as num?)?.toInt(),
        grades: [
          for (final g in jsonList(s['grades']))
            GradeItem(
              kind: g['kind'] == 'EVALUATION' ? GradeKind.evaluation : GradeKind.homework,
              assignmentId: g['assignmentId'] as String?,
              evaluationId: g['evaluationId'] as String?,
              title: g['title'] as String? ?? '',
              date: instant(g['date'])!,
              score: (g['score'] as num?)?.toDouble(),
              maxScore: (g['maxScore'] as num? ?? 20).toInt(),
              score20: (g['score20'] as num?)?.toDouble(),
              comment: g['comment'] as String?,
              absent: g['absent'] as bool? ?? false,
            ),
        ],
      ),
  ],
);
