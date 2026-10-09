import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/app_text.dart';
import '../../../core/theme/brand_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/cards.dart';
import '../../widgets/classmates.dart';
import '../../widgets/language_toggle.dart';

/// The frame of the screens before the app (login, choose password). From 900 px: the brand pane at
/// the start (indigo soft, headline, three features, the characters) and the form pane at the end.
/// Narrower: wordmark, form, then the characters.
class WelcomeLayout extends StatelessWidget {
  const WelcomeLayout({super.key, required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 900) return _Narrow(form: form);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(flex: 560, child: _BrandPane()),
              Expanded(flex: 440, child: _FormPane(form: form)),
            ],
          );
        },
      ),
    );
  }
}

class _BrandPane extends StatelessWidget {
  const _BrandPane();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final features = [
      (LucideIcons.calendar, Accent.indigo, l10n.loginFeaturePlanning, l10n.loginFeaturePlanningText),
      (LucideIcons.clipboardCheck, Accent.amber, l10n.loginFeatureWork, l10n.loginFeatureWorkText),
      (LucideIcons.trendingUp, Accent.turquoise, l10n.loginFeatureProgress, l10n.loginFeatureProgressText),
    ];
    return ColoredBox(
      color: BrandColors.indigoSoft,
      child: ClipRect(
        child: Stack(
          children: [
            const PositionedDirectional(start: 56, bottom: 0, child: Classmates()),
            SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(56, 48, 56, 230),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandWordmark(),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.tagline, style: text.loginHeadline),
                        const SizedBox(height: 18),
                        Text(l10n.loginBrandLine, style: text.style(17, FontWeight.w500, color: BrandColors.body, height: 1.55)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      children: [
                        for (final (icon, accent, title, body) in features) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.row)),
                            child: Row(
                              children: [
                                IconBadge(icon: icon, accent: accent),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: text.rowTitle),
                                      const SizedBox(height: 2),
                                      Text(body, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormPane extends StatelessWidget {
  const _FormPane({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          children: [
            const Align(alignment: AlignmentDirectional.centerEnd, child: LanguageToggle()),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: form),
                ),
              ),
            ),
            Text(l10n.footerCopyright, style: AppText.of(context).style(12, FontWeight.w500, color: BrandColors.slate)),
          ],
        ),
      ),
    );
  }
}

class _Narrow extends StatelessWidget {
  const _Narrow({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: BrandWordmark(size: WordmarkSize.short),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    LanguageToggle(),
                  ],
                ),
                const SizedBox(height: 36),
                form,
                const SizedBox(height: 36),
                const Center(child: Classmates(scale: 0.45)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overline, title and one sentence above a welcome form.
class WelcomeTitle extends StatelessWidget {
  const WelcomeTitle({super.key, required this.overline, required this.title, required this.message});

  final String overline;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text.upper(overline), style: text.overline(color: BrandColors.turquoise)),
        const SizedBox(height: 10),
        Text(title, style: text.loginTitle),
        const SizedBox(height: 10),
        Text(message, style: text.style(15, FontWeight.w500, color: BrandColors.slate, height: 1.5)),
      ],
    );
  }
}
