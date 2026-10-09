import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_language.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';
import '../stateManager/language/language_cubit.dart';

/// Français / العربية, each language written in itself so anyone can find theirs.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = context.watch<LanguageCubit>().state;
    final text = AppText.of(context);

    Widget option(AppLanguage language, String label) {
      final selected = language == current;
      return Semantics(
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: () => context.read<LanguageCubit>().change(language),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: selected ? AppShadows.toggle : null,
              ),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: text.inScript(
                  TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? BrandColors.indigo : BrandColors.slate,
                  ),
                  arabic: language == AppLanguage.ar,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrandColors.chalk,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [option(AppLanguage.fr, l10n.languageFrench), const SizedBox(width: 2), option(AppLanguage.ar, l10n.languageArabic)],
      ),
    );
  }
}

/// "FR · ع" in the top bar: one tap switches to the other language.
class LanguageToggleCompact extends StatelessWidget {
  const LanguageToggleCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.watch<LanguageCubit>();
    final radius = BorderRadius.circular(AppRadii.sm);
    return Tooltip(
      message: l10n.language,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: BrandColors.line),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: () => cubit.change(cubit.state == AppLanguage.fr ? AppLanguage.ar : AppLanguage.fr),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            child: Text(
              l10n.languageToggleShort,
              textDirection: TextDirection.ltr,
              style: AppText.of(context).style(13, FontWeight.w700, color: BrandColors.body),
            ),
          ),
        ),
      ),
    );
  }
}
