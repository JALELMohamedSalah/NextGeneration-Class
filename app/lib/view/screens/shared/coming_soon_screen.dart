import 'package:flutter/material.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/app_destination.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';

/// A section whose release has not come yet (docs/04-delivery/01-RELEASE_PLAN.md): what it will hold,
/// and in which version.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.description, this.release});

  final LabelOf title;
  final LabelOf description;

  /// The release that brings it, when the plan says so.
  final int? release;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SectionCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const Classmates(scale: 0.4),
                  const SizedBox(height: 22),
                  Text(title(l10n), textAlign: TextAlign.center, style: text.style(22, FontWeight.w800)),
                  if (release != null) ...[const SizedBox(height: 10), StatusChip(label: l10n.releaseBadge(release!), accent: Accent.blue)],
                  const SizedBox(height: 14),
                  Text(
                    description(l10n),
                    textAlign: TextAlign.center,
                    style: text.style(15, FontWeight.w500, color: BrandColors.body, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
