import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../l10n/app_localizations.dart';

/// The NG symbol alone.
class BrandSymbol extends StatelessWidget {
  const BrandSymbol({super.key, this.height = 34});

  final double height;

  @override
  Widget build(BuildContext context) =>
      Image.asset('assets/brand/symbol.png', height: height, fit: BoxFit.contain, excludeFromSemantics: true);
}

enum WordmarkSize {
  /// Sidebar: symbol 34, name on two lines at 17.
  sidebar(34, 17),

  /// Login and splash: symbol 40, one line at 21.
  login(40, 21),

  /// Phone header: symbol 30, "NG Class" at 15.
  short(30, 15);

  const WordmarkSize(this.symbol, this.text);

  final double symbol;
  final double text;
}

/// Symbol + "NextGeneration" (800, indigo) + "Class" (500, turquoise), always set in Plus Jakarta Sans
/// and written left to right in both languages: it is a name, not a sentence.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = WordmarkSize.login});

  final WordmarkSize size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    // The brand name comes from the translations like every text: "NextGeneration Class".
    final space = l10n.appTitle.indexOf(' ');
    final first = space < 0 ? l10n.appTitle : l10n.appTitle.substring(0, space);
    final second = space < 0 ? '' : l10n.appTitle.substring(space + 1);
    TextStyle base(FontWeight weight, Color color, {double spacing = -0.3}) => text.inScript(
      TextStyle(fontSize: size.text, fontWeight: weight, color: color, letterSpacing: spacing, height: 1.15),
      arabic: false,
    );
    final Widget name = switch (size) {
      WordmarkSize.short => Text(
        l10n.appShortName,
        textDirection: TextDirection.ltr,
        style: base(FontWeight.w700, BrandColors.indigo, spacing: 0),
      ),
      _ => Text.rich(
        textDirection: TextDirection.ltr,
        TextSpan(
          children: [
            TextSpan(text: first, style: base(FontWeight.w800, BrandColors.indigo)),
            TextSpan(text: size == WordmarkSize.sidebar ? '\n' : ' '),
            TextSpan(text: second, style: base(FontWeight.w500, BrandColors.turquoise)),
          ],
        ),
      ),
    };
    return Semantics(
      label: l10n.appTitle,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandSymbol(height: size.symbol),
          SizedBox(width: size == WordmarkSize.login ? 12 : 10),
          name,
        ],
      ),
    );
  }
}
