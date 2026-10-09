import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import 'buttons.dart';
import 'cards.dart';

const _scrim = Color(0x471A1D3A);

Duration _duration(BuildContext context, int milliseconds) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : Duration(milliseconds: milliseconds);

/// Creation and quick edits (docs/03-conception/05-SCREENS_NAVIGATION.md): a panel sliding in from
/// the end side on tablet and desktop, a full-screen sheet rising from the bottom on phones.
/// Blocs the panel needs must be passed in [builder] (the panel lives above the shell).
Future<T?> showSidePanel<T>(BuildContext context, {required WidgetBuilder builder, double width = 520}) {
  final phone = MediaQuery.sizeOf(context).width < Breakpoints.tablet;
  final rtl = Directionality.of(context) == TextDirection.rtl;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: _scrim,
    transitionDuration: _duration(context, 260),
    pageBuilder: (dialogContext, _, _) => SafeArea(
      top: phone,
      bottom: false,
      child: Align(
        alignment: phone ? Alignment.bottomCenter : AlignmentDirectional.centerEnd,
        child: Material(
          color: Colors.white,
          elevation: 24,
          shadowColor: const Color(0x401C2566),
          borderRadius: phone ? const BorderRadius.vertical(top: Radius.circular(AppRadii.card)) : null,
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: phone ? double.infinity : width,
            height: double.infinity,
            child: Builder(builder: builder),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
      final begin = phone ? const Offset(0, 1) : Offset(rtl ? -1 : 1, 0);
      return SlideTransition(
        position: Tween(begin: begin, end: Offset.zero).animate(curved),
        child: child,
      );
    },
  );
}

/// Header, scrolling body, footer actions.
class SidePanel extends StatelessWidget {
  const SidePanel({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.icon,
    this.accent = Accent.indigo,
    this.leading,
    this.headerColor,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Accent accent;

  /// Replaces the icon badge (a group square).
  final Widget? leading;
  final Color? headerColor;
  final Widget body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 14, 20),
          decoration: BoxDecoration(
            color: headerColor ?? Colors.white,
            border: headerColor == null ? const Border(bottom: BorderSide(color: BrandColors.line)) : null,
          ),
          child: Row(
            children: [
              if (leading != null) leading! else if (icon != null) IconBadge(icon: icon!, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.style(20, FontWeight.w800, spacing: -0.3)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.close,
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(LucideIcons.x, size: 22, color: BrandColors.slate),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: body),
        ),
        if (actions.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: BrandColors.line)),
            ),
            child: SafeArea(
              top: false,
              child: Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: actions),
            ),
          ),
      ],
    );
  }
}

/// A centered card that fades and grows in.
Future<T?> showAppDialog<T>(BuildContext context, {required WidgetBuilder builder}) => showGeneralDialog<T>(
  context: context,
  barrierDismissible: true,
  barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
  barrierColor: _scrim,
  transitionDuration: _duration(context, 220),
  pageBuilder: (dialogContext, _, _) => SafeArea(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.hero),
          elevation: 24,
          shadowColor: const Color(0x401C2566),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Builder(builder: builder),
          ),
        ),
      ),
    ),
  ),
  transitionBuilder: (context, animation, _, child) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curved), child: child),
    );
  },
);

/// Icon, title, text, content and actions, in the card of [showAppDialog].
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.accent = Accent.indigo,
    this.content,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Accent accent;
  final Widget? content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: accent.soft, borderRadius: BorderRadius.circular(AppRadii.md)),
                  child: Icon(icon, size: 21, color: accent.onSoft),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.style(20, FontWeight.w800, spacing: -0.3)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.4)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (content != null) ...[const SizedBox(height: 18), content!],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

/// "Archiver Amine Kefi ?": true when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String text,
  required String confirmLabel,
  IconData icon = LucideIcons.triangleAlert,
  bool danger = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showAppDialog<bool>(
    context,
    builder: (dialogContext) => AppDialog(
      title: title,
      subtitle: text,
      icon: icon,
      accent: danger ? Accent.red : Accent.indigo,
      actions: [
        GhostButton(label: l10n.back, onPressed: () => Navigator.of(dialogContext).pop(false)),
        danger
            ? DangerButton(label: confirmLabel, filled: true, onPressed: () => Navigator.of(dialogContext).pop(true))
            : PrimaryButton(label: confirmLabel, height: 44, onPressed: () => Navigator.of(dialogContext).pop(true)),
      ],
    ),
  );
  return result ?? false;
}

/// A short message at the bottom of the screen.
void showNotice(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
