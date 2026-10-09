import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/app_user.dart';
import '../../../../domain/model/student.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../widgets/account_menu.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/panels.dart';

/// Login details shown once after an account is created or its password reset (design `r1/Identifiants.png`).
class CredentialsDialog extends StatelessWidget {
  const CredentialsDialog({super.key, required this.accounts, this.reset = false, this.note});

  final List<NewAccount> accounts;

  /// A reset of an existing account rather than new accounts.
  final bool reset;

  /// What to do next; the pupils' and parents' note by default.
  final String? note;

  static Future<void> show(BuildContext context, List<NewAccount> accounts, {bool reset = false, String? note}) => showAppDialog<void>(
    context,
    builder: (_) => CredentialsDialog(accounts: accounts, reset: reset, note: note),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      icon: LucideIcons.keyRound,
      accent: Accent.turquoise,
      title: reset ? l10n.resetPasswordTitle : l10n.credentialsTitle,
      subtitle: l10n.credentialsSubtitle,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final account in accounts) ...[_AccountCard(account: account, reset: reset), const SizedBox(height: 14)],
          InfoNote(text: note ?? l10n.credentialsNote, icon: LucideIcons.lock),
        ],
      ),
      actions: [PrimaryButton(label: l10n.credentialsDone, height: 46, onPressed: () => Navigator.of(context).pop())],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, required this.reset});

  final NewAccount account;
  final bool reset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final initials = '${account.firstName.isEmpty ? '' : account.firstName[0]}${account.lastName.isEmpty ? '' : account.lastName[0]}'
        .toUpperCase();
    final role = roleLabel(l10n, account.role);
    final note = account.role == UserRole.parent ? '$role${l10n.dotSeparator}${l10n.parentLoginNote}' : role;

    Widget box(String label, String value, {bool mono = false}) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(text.upper(label), style: text.overline(size: 11)),
            const SizedBox(height: 4),
            SelectableText(
              value,
              textDirection: TextDirection.ltr,
              style: mono
                  ? text
                        .style(17, FontWeight.w800, spacing: 1)
                        .copyWith(fontFamily: 'monospace', fontFamilyFallback: const ['Menlo', 'Courier'])
                  : text.style(17, FontWeight.w800),
            ),
          ],
        ),
      ),
    );

    Future<void> copy(String value) async {
      await Clipboard.setData(ClipboardData(text: value));
      if (context.mounted) showNotice(context, l10n.copied);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InitialsAvatar(initials: initials),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(account.fullName, style: text.rowTitle),
                    Text(note, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                  ],
                ),
              ),
              if (!reset) StatusChip(label: l10n.newAccount, accent: Accent.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              box(l10n.credentialUsername, account.username),
              const SizedBox(width: 12),
              box(l10n.credentialPassword, account.temporaryPassword, mono: true),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SecondaryButton(
                label: l10n.copy,
                icon: LucideIcons.copy,
                height: 38,
                onPressed: () => copy('${account.username}\n${account.temporaryPassword}'),
              ),
              TonalButton(
                label: l10n.copyMessage,
                icon: LucideIcons.messageCircle,
                onPressed: () =>
                    copy(l10n.credentialsMessage(account.firstName, l10n.appTitle, account.username, account.temporaryPassword)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
