import 'package:flutter/material.dart';

import '../../core/network/api_failure.dart';
import '../../l10n/app_localizations.dart';
import 'cards.dart';

/// The text to show for a failure: the server's message (already in the app language),
/// or the app's own wording for local problems.
String failureText(AppLocalizations l10n, ApiFailure failure) {
  if (failure.isNetwork) return l10n.errorNetwork;
  return failure.message ?? l10n.errorUnknown;
}

class FailureBanner extends StatelessWidget {
  const FailureBanner(this.failure, {super.key, this.onRetry});

  final ApiFailure failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ErrorBanner(message: failureText(l10n, failure), onRetry: onRetry, retryLabel: l10n.retry);
  }
}

/// "Cette section arrive avec une prochaine version": for actions whose release has not come yet.
void showComingSoon(BuildContext context) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).comingSoonMessage)));
}
