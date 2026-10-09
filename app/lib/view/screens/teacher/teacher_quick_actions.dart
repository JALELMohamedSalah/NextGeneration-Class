import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/library/library_cubit.dart';
import '../../widgets/app_destination.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/panels.dart';
import 'contents/document_form_panel.dart';
import 'homework/evaluation_panel.dart';
import 'homework/assign_panel.dart';
import 'planning/session_form_panel.dart';

/// What the teacher creates most. Each opens its creation flow once its release is there
/// (session R1, assignment R2, QCM and series R3, import R2); until then, "coming soon".
class TeacherQuickAction {
  const TeacherQuickAction(this.label, this.icon, this.accent, {this.flow, this.menuOnly = false});

  final LabelOf label;
  final IconData icon;
  final Accent accent;

  /// Only in the "Créer" menu: the row of Ma journée keeps its five actions (design `TeacherHome.png`).
  final bool menuOnly;

  /// The creation flow; true when something was created.
  final Future<bool> Function(BuildContext context)? flow;

  static final all = [
    TeacherQuickAction(
      (l10n) => l10n.quickSession,
      LucideIcons.calendarPlus,
      Accent.indigo,
      flow: (context) => SessionFormPanel.create(context),
    ),
    TeacherQuickAction((l10n) => l10n.quickAssignment, LucideIcons.clipboardCheck, Accent.amber, flow: _assign),
    TeacherQuickAction(
      (l10n) => l10n.quickEvaluation,
      LucideIcons.clipboardPen,
      Accent.violet,
      flow: (context) => EvaluationPanel.createAndGrade(context),
      menuOnly: true,
    ),
    TeacherQuickAction((l10n) => l10n.quickQcm, LucideIcons.listChecks, Accent.violet),
    TeacherQuickAction((l10n) => l10n.quickSeries, LucideIcons.layers, Accent.turquoise),
    TeacherQuickAction((l10n) => l10n.quickImport, LucideIcons.upload, Accent.blue, flow: _import),
  ];

  Future<bool> open(BuildContext context) async {
    if (flow != null) return flow!(context);
    showComingSoon(context);
    return false;
  }

  /// "Importer un document" from anywhere: the panel of Contenus, with a library of its own for the chapters.
  static Future<bool> _import(BuildContext context) async {
    final library = sl.get<LibraryCubit>()..load();
    try {
      final saved = await DocumentFormPanel.upload(context, library: library);
      if (saved != null && context.mounted) showNotice(context, AppLocalizations.of(context).documentUploaded);
      return saved != null;
    } finally {
      await library.close();
    }
  }

  static Future<bool> _assign(BuildContext context) async {
    final saved = await AssignPanel.open(context);
    if (saved != null && context.mounted) showNotice(context, AppLocalizations.of(context).homeworkGiven);
    return saved != null;
  }
}

/// The row of quick actions under the greeting of Ma journée.
class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key, this.onChanged});

  /// Called when an action created something (Ma journée reloads).
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in TeacherQuickAction.all.where((a) => !a.menuOnly))
          QuickActionButton(
            label: action.label(l10n),
            icon: action.icon,
            accent: action.accent,
            onPressed: () async {
              if (await action.open(context)) onChanged?.call();
            },
          ),
      ],
    );
  }
}

/// "Créer" in the top bar: the same quick actions in a menu.
class CreateMenuButton extends StatelessWidget {
  const CreateMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
            side: const BorderSide(color: BrandColors.line),
          ),
        ),
      ),
      menuChildren: [
        for (final action in TeacherQuickAction.all)
          MenuItemButton(
            onPressed: () => action.open(context),
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(220, 44)),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm))),
            ),
            leadingIcon: IconBadge(icon: action.icon, accent: action.accent, size: IconBadgeSize.small),
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 4),
              child: Text(action.label(l10n), style: text.style(14, FontWeight.w700)),
            ),
          ),
      ],
      builder: (context, controller, child) => PrimaryButton(
        label: l10n.quickCreate,
        icon: LucideIcons.plus,
        height: 44,
        onPressed: () => controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
