import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/l10n/tunis_time.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/notifications/notifications_cubit.dart';
import '../../widgets/cards.dart';
import '../../widgets/page_frame.dart';
import '../../widgets/panels.dart';
import '../shared/notifications_screen.dart';

/// The teacher's notifications (design `r2/NotificationsEnseignante.png`): work sent, gathered by homework, and
/// deadlines passed. Opened from the bell: a side panel on wider screens, the whole screen on phones. Reads the
/// shell's [NotificationsCubit], so the bell follows what is read here.
class TeacherNotificationsPanel extends StatefulWidget {
  const TeacherNotificationsPanel({super.key});

  static Future<void> open(BuildContext context) {
    final notifications = context.read<NotificationsCubit>();
    return showSidePanel<void>(
      context,
      width: 480,
      builder: (_) => BlocProvider.value(value: notifications, child: const TeacherNotificationsPanel()),
    );
  }

  @override
  State<TeacherNotificationsPanel> createState() => _TeacherNotificationsPanelState();
}

class _TeacherNotificationsPanelState extends State<TeacherNotificationsPanel> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<NotificationsCubit>().state;
    final phone = isPhone(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsetsDirectional.fromSTEB(phone ? 16 : 24, 18, phone ? 6 : 14, 18),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: BrandColors.line)),
          ),
          child: Row(
            children: [
              if (!phone) ...[const IconBadge(icon: LucideIcons.bell, accent: Accent.indigo), const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.navNotifications, style: text.style(20, FontWeight.w800, spacing: -0.3)),
                    if (state.loaded) ...[
                      const SizedBox(height: 2),
                      Text(l10n.notificationsUnread(state.unreadCount), style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                    ],
                  ],
                ),
              ),
              if (state.unreadCount > 0) ...[
                const SizedBox(width: 8),
                // On the narrowest phones the link takes two lines rather than pushing the title out.
                Flexible(child: CardLink(label: l10n.markAllRead, onPressed: context.read<NotificationsCubit>().markAllRead)),
              ],
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(LucideIcons.x, size: 22, color: BrandColors.slate),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(phone ? 16 : 24),
            child: NotificationSections(now: sl.get<Now>()(), onOpen: () => Navigator.of(context).pop()),
          ),
        ),
      ],
    );
  }
}
