import 'package:flutter/material.dart';

import '../../core/l10n/app_language.dart';
import '../../core/l10n/formatting.dart';
import '../../core/l10n/tunis_time.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/homework.dart';
import '../../l10n/app_localizations.dart';
import 'cards.dart';

String homeworkStatusLabel(AppLocalizations l10n, HomeworkStatus? status) => switch (status) {
  HomeworkStatus.todo => l10n.hwStatusTodo,
  HomeworkStatus.submitted => l10n.hwStatusSubmitted,
  HomeworkStatus.late => l10n.hwStatusLate,
  HomeworkStatus.missing => l10n.hwStatusMissing,
  HomeworkStatus.corrected => l10n.hwStatusCorrected,
  null => l10n.toRead,
};

Accent homeworkStatusAccent(HomeworkStatus? status) => switch (status) {
  HomeworkStatus.todo => Accent.blue,
  HomeworkStatus.submitted => Accent.green,
  HomeworkStatus.late => Accent.amber,
  HomeworkStatus.missing => Accent.red,
  HomeworkStatus.corrected => Accent.violet,
  null => Accent.grey,
};

class HomeworkStatusChip extends StatelessWidget {
  const HomeworkStatusChip(this.status, {super.key});

  /// Null: something to read only.
  final HomeworkStatus? status;

  @override
  Widget build(BuildContext context) =>
      StatusChip(label: homeworkStatusLabel(AppLocalizations.of(context), status), accent: homeworkStatusAccent(status));
}

/// "Aujourd'hui, 18:00", "Demain, 18:00", "Jeu. 9 oct., 18:00" (Tunisian time).
String deadlineLabel(AppLocalizations l10n, AppLanguage language, DateTime deadline, DateTime now) {
  final day = TunisTime.day(deadline);
  final today = TunisTime.day(now);
  final time = hm(deadline);
  if (TunisTime.sameDay(day, today)) return l10n.dueToday(time);
  if (TunisTime.sameDay(day, TunisTime.addDays(today, 1))) return l10n.dueTomorrow(time);
  return l10n.dueOn('${weekdayShort(day, language)} ${shortDate(day, language)}', time);
}

/// "dans 2 jours", "demain", "il y a 3 jours".
String deadlineNote(AppLocalizations l10n, DateTime deadline, DateTime now) {
  final days = TunisTime.day(deadline).difference(TunisTime.day(now)).inDays;
  return days >= 0 ? l10n.inDays(days) : l10n.daysAgo(-days);
}

/// The deadline is close (today or tomorrow) and the work is still to do.
bool deadlineIsNear(DateTime deadline, DateTime now) =>
    deadline.isAfter(now) && TunisTime.day(deadline).difference(TunisTime.day(now)).inDays <= 1;

/// Sent in green, late in amber, missing in red, the rest still to do (design `r2/Devoirs.png`).
class HomeworkProgress extends StatelessWidget {
  const HomeworkProgress({super.key, required this.counts, required this.total});

  final StatusCounts counts;
  final int total;

  @override
  Widget build(BuildContext context) {
    final parts = [
      (counts.submitted + counts.corrected, Accent.green.strong),
      (counts.late, Accent.amber.strong),
      (counts.missing, Accent.red.strong),
      (total - counts.sent - counts.missing, BrandColors.line),
    ].where((p) => p.$1 > 0).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        width: double.infinity,
        child: parts.isEmpty
            ? const ColoredBox(color: BrandColors.line)
            : Row(
                // A segment has no height of its own: it takes the bar's.
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, (n, color)) in parts.indexed) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      flex: n,
                      child: ColoredBox(color: color),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
