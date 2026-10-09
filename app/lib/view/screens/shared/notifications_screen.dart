import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/formatting.dart';
import '../../../core/l10n/joined_names.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../domain/model/app_notification.dart';
import '../../../domain/model/app_user.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/auth/auth_cubit.dart';
import '../../stateManager/common/load_status.dart';
import '../../stateManager/language/language_cubit.dart';
import '../../stateManager/notifications/notifications_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/feedback.dart';
import '../../widgets/labels.dart';
import '../../widgets/page_frame.dart';

/// The parent's "Notifications" tab, or the child's page opened from the bell (design `r1/Notifications.png`).
/// Reads the shell's [NotificationsCubit], so the badge follows what is read here.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.showBack = false});

  /// The child's page comes from the bell: a back button returns home.
  final bool showBack;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) => NotificationsView(showBack: widget.showBack);
}

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final phone = isPhone(context);
    final state = context.watch<NotificationsCubit>().state;
    final now = sl.get<Now>()();

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showBack) ...[
          IconSquareButton(
            icon: LucideIcons.arrowLeftDir,
            tooltip: l10n.back,
            size: 40,
            onPressed: () => context.canPop() ? context.pop() : context.go(Routes.studentHome),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.loaded)
                Text(l10n.notificationsUnread(state.unreadCount), style: text.style(13, FontWeight.w600, color: BrandColors.slate)),
              Text(l10n.navNotifications, style: phone ? text.style(22, FontWeight.w800, spacing: -0.5) : text.pageTitle()),
            ],
          ),
        ),
        if (state.unreadCount > 0) ...[
          const SizedBox(width: 12),
          // On the narrowest phones the link takes two lines rather than pushing the title out.
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: CardLink(label: l10n.markAllRead, onPressed: context.read<NotificationsCubit>().markAllRead),
            ),
          ),
        ],
      ],
    );

    return PageScroll(
      maxWidth: familyPageWidth,
      gap: 20,
      children: [
        header,
        NotificationSections(now: now),
      ],
    );
  }
}

/// The list itself, read from [NotificationsCubit]: loading, failure, empty, or "Aujourd'hui" then "Plus tôt".
/// Shared by the families' page and the teacher's panel ([onOpen] closes the panel before a tile navigates).
class NotificationSections extends StatelessWidget {
  const NotificationSections({super.key, required this.now, this.onOpen});

  final DateTime now;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<NotificationsCubit>().state;
    if (state.status == LoadStatus.failure && !state.loaded) {
      return FailureBanner(state.failure!, onRetry: context.read<NotificationsCubit>().load);
    }
    if (state.status == LoadStatus.loading && !state.loaded) return const LinearProgressIndicator(minHeight: 3);
    if (state.items.isEmpty) {
      final role = context.select((AuthCubit c) => c.user?.role);
      return SectionCard(
        child: EmptyState(
          message: role == UserRole.teacher ? l10n.noNotificationsTeacher : l10n.noNotifications,
          scale: 0.5,
          action: Text(
            switch (role) {
              UserRole.student => l10n.noNotificationsHintStudent,
              UserRole.teacher => l10n.noNotificationsHintTeacher,
              _ => l10n.noNotificationsHint,
            },
            textAlign: TextAlign.center,
            style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5),
          ),
        ),
      );
    }
    final today = TunisTime.day(now);
    final recent = state.items.where((n) => TunisTime.day(n.createdAt) == today).toList();
    final earlier = state.items.where((n) => TunisTime.day(n.createdAt) != today).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (recent.isNotEmpty) _Section(label: l10n.notificationsToday, items: recent, now: now, onOpen: onOpen),
        if (recent.isNotEmpty && earlier.isNotEmpty) const SizedBox(height: 20),
        if (earlier.isNotEmpty) _Section(label: l10n.notificationsEarlier, items: earlier, now: now, onOpen: onOpen),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.items, required this.now, this.onOpen});

  final String label;
  final List<AppNotification> items;
  final DateTime now;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(text.upper(label), style: text.overline()),
        const SizedBox(height: 10),
        // Two by two on a wide page; one column in the teacher's panel and on phones.
        CardColumns(
          gap: 10,
          minColumnWidth: 400,
          children: [for (final item in items) NotificationTile(notification: item, now: now, onOpen: onOpen)],
        ),
      ],
    );
  }
}

/// One notification: what happened (icon and color), for which child, the session, and how long ago.
/// Unread ones are tinted, with a dot. Tapping reads it and opens what it is about: the planning, the
/// homework, the results; for the teacher the copy to correct or the homework (with a button saying so).
class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.now, this.embedded = false, this.onOpen});

  final AppNotification notification;
  final DateTime now;

  /// Inside the child's "Du nouveau" card: no frame of its own and no "how long ago".
  final bool embedded;

  /// Called before navigating (the teacher's panel closes).
  final VoidCallback? onOpen;

  /// An unread notification: tinted, with a light indigo line.
  static const unreadTint = Color(0xFFF4F5FC);
  static const unreadLine = Color(0xFFDCE0F5);

  static (IconData, Accent) _look(AppNotification n) => switch (n.kind) {
    NotificationKind.cancelled => (LucideIcons.ban, Accent.red),
    NotificationKind.moved => (LucideIcons.clock, Accent.blue),
    NotificationKind.restored => (LucideIcons.circleCheck, Accent.green),
    NotificationKind.homework => (LucideIcons.clipboardList, Accent.indigo),
    NotificationKind.corrected => (LucideIcons.penLine, Accent.violet),
    NotificationKind.evaluation => (LucideIcons.clipboardCheck, Accent.green),
    NotificationKind.workSent => (LucideIcons.inbox, Accent.green),
    NotificationKind.deadlinePassed when n.pupils.isEmpty => (LucideIcons.calendarCheck, Accent.turquoise),
    NotificationKind.deadlinePassed => (LucideIcons.calendarX, Accent.red),
  };

  void _open(BuildContext context) {
    context.read<NotificationsCubit>().markRead(notification);
    final router = GoRouter.of(context);
    onOpen?.call();
    final user = context.read<AuthCubit>().user;
    final homework = notification.assignmentId;
    // The teacher: the first copy sent, or the homework and who is missing.
    if (notification.kind == NotificationKind.workSent && homework != null && notification.pupils.isNotEmpty) {
      return router.go(Routes.teacherCorrection(homework, notification.pupils.first.id));
    }
    if (notification.kind == NotificationKind.deadlinePassed || notification.kind == NotificationKind.workSent) {
      return router.go(homework == null ? Routes.teacherAssignments : Routes.teacherHomework(homework));
    }
    final aboutHomework = notification.kind == NotificationKind.homework || notification.kind == NotificationKind.corrected;
    if (aboutHomework && homework != null) {
      final child = notification.studentId;
      return router.go(
        user?.role == UserRole.parent
            ? '${Routes.parentHomework(homework)}${child == null ? '' : '?${Routes.childParam}=$child'}'
            : Routes.studentHomework(homework),
      );
    }
    // A new grade: the results, where it sits with the others.
    if (notification.kind == NotificationKind.evaluation) {
      final child = notification.studentId;
      return router.go(
        user?.role == UserRole.parent
            ? '${Routes.parentResults}${child == null ? '' : '?${Routes.childParam}=$child'}'
            : Routes.studentResults,
      );
    }
    if (user?.role == UserRole.parent) {
      final child = notification.studentId;
      router.go(child == null ? Routes.parentPlanning : '${Routes.parentPlanning}?${Routes.childParam}=$child');
    } else {
      router.go(Routes.studentPlanning);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = context.watch<LanguageCubit>().state;
    final n = notification;
    final unread = !n.read;
    final (icon, accent) = _look(n);
    // A parent of one child does not need the first name on every line.
    final severalChildren = (context.select((AuthCubit c) => c.user?.children.length) ?? 0) > 1;
    final sep = l10n.dotSeparator;

    String when(DateTime instant) => '${dayDate(TunisTime.day(instant), language)}$sep${hm(instant)}';
    String fromWhen(DateTime instant) => l10n.fromDate(dayInSentence(TunisTime.day(instant), language));
    final series = n.sessionCount > 1;
    final group = keptTogether(n.groupName);

    final title = switch (n.kind) {
      NotificationKind.cancelled => l10n.notificationCancelled(n.sessionCount),
      NotificationKind.moved => l10n.notificationMoved(n.sessionCount),
      NotificationKind.restored => l10n.notificationRestored,
      NotificationKind.homework => l10n.notificationHomework,
      NotificationKind.corrected => l10n.notificationCorrected,
      NotificationKind.evaluation => l10n.notificationEvaluation,
      NotificationKind.workSent => l10n.notificationWorkSent(n.pupils.length),
      NotificationKind.deadlinePassed => l10n.notificationDeadlinePassed,
    };
    final body = text.style(13, FontWeight.w500, color: BrandColors.body, height: 1.45);
    // The teacher's rows say where they lead.
    final action = switch (n.kind) {
      NotificationKind.workSent => l10n.correctAction,
      NotificationKind.deadlinePassed => l10n.actionSee,
      _ => null,
    };
    final lines = <Widget>[
      if (n.kind == NotificationKind.moved && n.previousStartsAt != null) ...[
        Text(
          series ? fromWhen(n.previousStartsAt!) : when(n.previousStartsAt!),
          style: body.copyWith(color: BrandColors.slate, decoration: TextDecoration.lineThrough),
        ),
        Text(
          '${series ? '${fromWhen(n.startsAt)}$sep${hm(n.startsAt)}' : when(n.startsAt)}$sep$group',
          style: text.style(13, FontWeight.w700, height: 1.45),
        ),
      ] else if (n.kind == NotificationKind.homework) ...[
        Text(isolated(n.title ?? ''), style: text.style(13, FontWeight.w700, height: 1.45)),
        Text('${l10n.dueLabel(when(n.startsAt))}$sep$group', style: body),
      ] else if (n.kind == NotificationKind.corrected) ...[
        Text(isolated(n.title ?? ''), style: text.style(13, FontWeight.w700, height: 1.45)),
        Text(l10n.correctedSeeGrade(group), style: body),
      ] else if (n.kind == NotificationKind.evaluation) ...[
        Text(isolated(n.title ?? ''), style: text.style(13, FontWeight.w700, height: 1.45)),
        Text(l10n.evaluationSeeGrade(group), style: body),
      ] else if (n.kind == NotificationKind.workSent) ...[
        Text(isolated(n.title ?? ''), style: text.style(13, FontWeight.w700, height: 1.45)),
        Text('${pupilNames(l10n, n.pupils)}$sep$group', style: body),
      ] else if (n.kind == NotificationKind.deadlinePassed) ...[
        Text(isolated(n.title ?? ''), style: text.style(13, FontWeight.w700, height: 1.45)),
        if (n.pupils.isEmpty)
          Text(l10n.everyoneSent, style: text.style(13, FontWeight.w600, color: Accent.green.onSoft, height: 1.45))
        else
          Text(
            l10n.missingPupils(n.pupils.length, pupilNames(l10n, n.pupils, full: true)),
            style: text.style(13, FontWeight.w600, color: Accent.red.onSoft, height: 1.45),
          ),
        Text(group, style: body),
      ] else
        Text('${series ? fromWhen(n.startsAt) : when(n.startsAt)}$sep$group', style: body),
      if (n.reason != null && n.reason!.isNotEmpty)
        Text(l10n.cancelledBecause(isolated(n.reason!)), style: text.style(13, FontWeight.w600, color: Accent.red.onSoft, height: 1.45)),
    ];

    final radius = BorderRadius.circular(embedded ? 14 : 18);
    return Semantics(
      button: true,
      child: Material(
        color: embedded ? Colors.transparent : (unread ? unreadTint : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: embedded ? BorderSide.none : BorderSide(color: unread ? unreadLine : BrandColors.line),
        ),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.all(embedded ? 4 : 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBadge(icon: icon, accent: accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: text.style(15, unread ? FontWeight.w800 : FontWeight.w700)),
                          if (severalChildren && n.childFirstName != null) _ChildTag(name: n.childFirstName!),
                          if (n.kind == NotificationKind.workSent && n.late) _LateTag(label: l10n.workLate),
                        ],
                      ),
                      const SizedBox(height: 5),
                      ...lines,
                      if (!embedded) ...[
                        const SizedBox(height: 6),
                        if (action == null)
                          Text(timeAgo(l10n, language, n.createdAt, now), style: text.style(12, FontWeight.w600, color: BrandColors.slate))
                        else
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  timeAgo(l10n, language, n.createdAt, now),
                                  style: text.style(12, FontWeight.w600, color: BrandColors.slate),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TonalButton(label: action, height: 34, onPressed: () => _open(context)),
                            ],
                          ),
                      ],
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(color: BrandColors.indigo, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildTag extends StatelessWidget {
  const _ChildTag({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: BrandColors.line),
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Text(name, style: AppText.of(context).style(12, FontWeight.w700)),
  );
}

class _LateTag extends StatelessWidget {
  const _LateTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: Accent.amber.soft, borderRadius: BorderRadius.circular(AppRadii.pill)),
    child: Text(label, style: AppText.of(context).style(12, FontWeight.w700, color: Accent.amber.onSoft)),
  );
}

/// "Amine Kefi"; "Adam et Sara", "Adam, Sara et Omar"; "Sami, Omar, Adam et 2 autres". [full]: last names too
/// (who is missing). Each name is isolated so a French name keeps its order in an Arabic line.
String pupilNames(AppLocalizations l10n, List<NamedPupil> pupils, {bool full = false}) =>
    joinedNames(l10n, [for (final p in pupils) full || pupils.length == 1 ? p.fullName : p.firstName]);
