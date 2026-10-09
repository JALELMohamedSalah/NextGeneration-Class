import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import 'buttons.dart';
import 'panels.dart';

/// "Copier le lien" beside a Meet link once there is one: to paste it in a message to the families.
class CopyLinkButton extends StatelessWidget {
  const CopyLinkButton({super.key, required this.url, this.size = 36});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconSquareButton(
      icon: LucideIcons.copy,
      tooltip: l10n.copyLink,
      size: size,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: url.trim()));
        if (context.mounted) showNotice(context, l10n.linkCopied);
      },
    );
  }
}
