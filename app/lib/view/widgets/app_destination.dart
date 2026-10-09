import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// A text taken from the translations.
typedef LabelOf = String Function(AppLocalizations l10n);

/// One entry of a role's navigation: path, icon, translated label and its screen.
class AppDestination {
  const AppDestination({
    required this.path,
    required this.icon,
    required this.label,
    required this.screen,
    this.inPhoneBar = true,
    this.badge,
  });

  final String path;
  final IconData icon;
  final LabelOf label;
  final Widget Function() screen;

  /// False: on phones it sits in the "Plus" sheet instead of the bottom bar.
  final bool inPhoneBar;

  /// A count shown on the item (0 hides it), read from a Cubit of the shell: watch it in the function.
  final int Function(BuildContext context)? badge;
}
