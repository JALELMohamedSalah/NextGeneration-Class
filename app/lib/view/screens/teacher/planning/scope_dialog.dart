import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/tunis_time.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/session.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/controls.dart';
import '../../../widgets/panels.dart';
import '../../../widgets/text_field.dart';

/// Editing a session of a weekly series: this one only, or this one and the following ones.
Future<EditScope?> askEditScope(BuildContext context, Session session) =>
    showAppDialog<EditScope>(context, builder: (_) => _ScopeDialog(session: session, cancel: false));

/// Cancelling a session: scope (for a series) and the reason students and parents will read.
Future<(EditScope, String?)?> askCancel(BuildContext context, Session session) =>
    showAppDialog<(EditScope, String?)>(context, builder: (_) => _ScopeDialog(session: session, cancel: true));

class _ScopeDialog extends StatefulWidget {
  const _ScopeDialog({required this.session, required this.cancel});

  final Session session;
  final bool cancel;

  @override
  State<_ScopeDialog> createState() => _ScopeDialogState();
}

class _ScopeDialogState extends State<_ScopeDialog> {
  EditScope _scope = EditScope.one;
  String _reason = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = context.watch<LanguageCubit>().state;
    final session = widget.session;
    final day = dayDate(TunisTime.day(session.startsAt), language);
    final seriesEnd = session.seriesEndsOn == null ? '' : fullDate(session.seriesEndsOn!, language);
    return AppDialog(
      icon: widget.cancel ? LucideIcons.ban : LucideIcons.pencil,
      accent: widget.cancel ? Accent.red : Accent.indigo,
      title: widget.cancel ? l10n.cancelSession : l10n.editSession,
      subtitle: session.recurring ? l10n.seriesNote : day,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (session.recurring) ...[
            ChoiceCard(
              title: l10n.scopeOne,
              subtitle: day,
              selected: _scope == EditScope.one,
              onTap: () => setState(() => _scope = EditScope.one),
            ),
            const SizedBox(height: 10),
            ChoiceCard(
              title: l10n.scopeFollowing,
              subtitle: session.followingCount > 0 ? l10n.scopeFollowingCount(l10n.sessionsCount(session.followingCount), seriesEnd) : null,
              selected: _scope == EditScope.following,
              onTap: () => setState(() => _scope = EditScope.following),
            ),
          ],
          if (widget.cancel) ...[
            if (session.recurring) const SizedBox(height: 16),
            FormInput(
              label: l10n.cancelReason,
              labelSuffix: l10n.cancelReasonVisibility,
              hint: l10n.cancelReasonHint,
              onChanged: (v) => _reason = v,
            ),
            const SizedBox(height: 14),
            InfoNote(text: l10n.cancelVisibleNote, icon: LucideIcons.bell),
          ],
        ],
      ),
      actions: [
        GhostButton(label: l10n.back, onPressed: () => Navigator.of(context).pop()),
        widget.cancel
            ? DangerButton(
                label: l10n.cancelSession,
                filled: true,
                onPressed: () => Navigator.of(context).pop((_scope, _reason.trim().isEmpty ? null : _reason.trim())),
              )
            : PrimaryButton(label: l10n.save, height: 44, onPressed: () => Navigator.of(context).pop(_scope)),
      ],
    );
  }
}
