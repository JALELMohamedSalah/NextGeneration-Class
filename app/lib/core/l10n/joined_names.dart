import '../../l10n/app_localizations.dart';
import 'formatting.dart';

/// "Adam", "Adam et Sara", "Adam, Sara et Omar", "Sami, Omar, Adam et 2 autres". Each name is isolated so a
/// French name keeps its order inside an Arabic line.
String joinedNames(AppLocalizations l10n, List<String> names) {
  final shown = [for (final n in names) isolated(n)];
  if (shown.isEmpty) return '';
  if (shown.length == 1) return shown.single;
  if (shown.length <= 3) return l10n.namesAnd(shown.sublist(0, shown.length - 1).join(l10n.listSeparator), shown.last);
  return l10n.namesAndOthers(shown.length - 3, shown.take(3).join(l10n.listSeparator));
}
