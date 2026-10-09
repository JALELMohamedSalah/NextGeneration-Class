import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_language.dart';
import 'app_text.dart';
import 'brand_colors.dart';

abstract final class AppTheme {
  /// French: Plus Jakarta Sans. Arabic: IBM Plex Sans Arabic, which also carries the Latin glyphs of
  /// names and numbers.
  static ThemeData light(AppLanguage language) {
    final isArabic = language == AppLanguage.ar;

    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.indigo,
      primary: BrandColors.indigo,
      secondary: BrandColors.turquoise,
      tertiary: BrandColors.amber,
      surface: Colors.white,
      onSurface: BrandColors.ink,
      onSurfaceVariant: BrandColors.slate,
      outlineVariant: BrandColors.line,
      error: Accent.red.strong,
    );
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: BrandColors.chalk);
    // Each style of these themes carries the family of its own weight.
    final text = (isArabic ? GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme) : GoogleFonts.plusJakartaSansTextTheme(base.textTheme))
        .apply(bodyColor: BrandColors.ink, displayColor: BrandColors.ink);
    return base.copyWith(
      textTheme: text,
      extensions: const [AppFonts()],
      dividerTheme: const DividerThemeData(color: BrandColors.rowDivider, space: 1, thickness: 1),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x331C2566),
        textStyle: text.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: BrandColors.ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: const BorderSide(color: BrandColors.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card))),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BrandColors.ink,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: BrandColors.ink, borderRadius: BorderRadius.circular(AppRadii.badge)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: BrandColors.indigo, linearTrackColor: BrandColors.indigoSoft),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: BrandColors.indigo),
    );
  }
}
