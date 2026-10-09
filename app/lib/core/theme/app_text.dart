import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_colors.dart';

/// The two brand fonts, set by [AppTheme]. Absent in widget tests (fonts are not downloaded there),
/// where the platform default font is used.
///
/// google_fonts serves one family per weight, so a style must ask for its own weight
/// ([AppText.inScript]) rather than reuse a family name. Bundled files in `assets/google_fonts/`
/// are picked up first, with no code change.
class AppFonts extends ThemeExtension<AppFonts> {
  const AppFonts();

  static const latin = 'Plus Jakarta Sans';
  static const arabic = 'IBM Plex Sans Arabic';

  @override
  AppFonts copyWith() => this;

  @override
  AppFonts lerp(AppFonts? other, double t) => this;
}

/// The type roles of the design spec (section 1.2). French and Arabic share sizes; Arabic caps the
/// weight at 700, never spaces letters (it breaks the joining) and is never uppercase.
class AppText {
  AppText._(this._base, this.isArabic, this._fonts);

  factory AppText.of(BuildContext context) {
    final theme = Theme.of(context);
    return AppText._(
      theme.textTheme.bodyMedium ?? const TextStyle(),
      Localizations.maybeLocaleOf(context)?.languageCode == 'ar',
      theme.extension<AppFonts>(),
    );
  }

  final TextStyle _base;
  final bool isArabic;
  final AppFonts? _fonts;

  /// [style] set in the brand font of one script, at its own weight: the wordmark is always Latin,
  /// "العربية" in the language toggle always Arabic.
  TextStyle inScript(TextStyle style, {required bool arabic}) =>
      _fonts == null ? style : GoogleFonts.getFont(arabic ? AppFonts.arabic : AppFonts.latin, textStyle: style);

  static const _tabular = [FontFeature.tabularFigures()];

  TextStyle style(
    double size,
    FontWeight weight, {
    double spacing = 0,
    Color color = BrandColors.ink,
    double? height,
    bool tabular = false,
  }) {
    final capped = isArabic && weight.value > 700 ? FontWeight.w700 : weight;
    final style = _base.copyWith(
      fontSize: size,
      fontWeight: capped,
      letterSpacing: isArabic ? 0 : spacing,
      color: color,
      height: height,
      fontFeatures: tabular ? _tabular : null,
    );
    return inScript(style, arabic: isArabic);
  }

  /// Uppercase in French only: Arabic has no capitals.
  String upper(String text) => isArabic ? text : text.toUpperCase();

  TextStyle heroTime({bool phone = false}) =>
      style(phone ? 52 : 76, FontWeight.w800, spacing: phone ? -2 : -3, color: Colors.white, height: 1, tabular: true);
  TextStyle get heroNumber => style(56, FontWeight.w800, spacing: -2, color: Colors.white, height: 1, tabular: true);
  TextStyle get loginHeadline => style(52, FontWeight.w800, spacing: -1.5, height: 1.1);
  TextStyle pageTitle({bool phone = false}) => style(phone ? 24 : 38, FontWeight.w800, spacing: phone ? -0.5 : -1, height: 1.2);
  TextStyle get loginTitle => style(36, FontWeight.w800, spacing: -0.8, height: 1.2);
  TextStyle get statValue => style(34, FontWeight.w800, spacing: -1, tabular: true);
  TextStyle get heroSubject => style(22, FontWeight.w700, color: Colors.white);
  TextStyle sectionTitle({bool phone = false}) => phone ? style(16, FontWeight.w700) : style(18, FontWeight.w800);
  TextStyle get rowTitle => style(15, FontWeight.w700);
  TextStyle get body => style(15, FontWeight.w500, color: BrandColors.body, height: 1.5);
  TextStyle get small => style(13, FontWeight.w600, color: BrandColors.slate, height: 1.45);
  TextStyle get caption => style(12, FontWeight.w700, color: BrandColors.slate);
  TextStyle overline({Color color = BrandColors.slate, double size = 12}) =>
      style(size, FontWeight.w700, spacing: size >= 12 ? 1.4 : 1.2, color: color);
  TextStyle get label => style(14, FontWeight.w600);
}
