import 'package:flutter/material.dart';

/// Brand palette (docs/00-brand/UI_DESIGN_SPEC.md section 1.1).
abstract final class BrandColors {
  static const indigo = Color(0xFF2B3990);
  static const indigoDeep = Color(0xFF1C2566);
  static const indigoSoft = Color(0xFFEEF0FA);
  static const turquoise = Color(0xFF12A39A);
  static const turquoiseDeep = Color(0xFF0B7C75);
  static const turquoiseSoft = Color(0xFFE3F6F4);
  static const amber = Color(0xFFFFB020);
  static const amberSoft = Color(0xFFFFF4DC);
  static const violet = Color(0xFF7048E8);
  static const ink = Color(0xFF1A1D3A);
  static const body = Color(0xFF4A4F72);
  static const slate = Color(0xFF6B7090);
  static const line = Color(0xFFE6E8F0);
  static const rowDivider = Color(0xFFF0F1F6);
  static const chalk = Color(0xFFF6F7FB);
  static const onDarkAmber = Color(0xFFFFD27A);
  static const onDarkTeal = Color(0xFF7FE3DA);
}

/// The color family of a block: strong color, soft background, and text written on the soft background.
enum Accent {
  indigo(Color(0xFF2B3990), Color(0xFFEEF0FA), Color(0xFF2B3990)),
  turquoise(Color(0xFF12A39A), Color(0xFFE3F6F4), Color(0xFF0B6E68)),
  amber(Color(0xFFFFB020), Color(0xFFFFF4DC), Color(0xFF9A6300)),
  violet(Color(0xFF7048E8), Color(0xFFF1ECFD), Color(0xFF5B34D6)),
  blue(Color(0xFF3B5BDB), Color(0xFFEAF0FF), Color(0xFF2F4AC0)),
  red(Color(0xFFE03131), Color(0xFFFDECEC), Color(0xFFB42525)),
  orange(Color(0xFFE8590C), Color(0xFFFDEEE4), Color(0xFFB5440A)),
  green(Color(0xFF2F9E44), Color(0xFFE7F6EA), Color(0xFF237A35)),
  grey(Color(0xFF868E96), Color(0xFFF1F3F5), Color(0xFF868E96));

  const Accent(this.strong, this.soft, this.onSoft);

  final Color strong;
  final Color soft;
  final Color onSoft;
}

/// "#2B3990" from the API; brand indigo when unreadable.
Color colorFromHex(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  return value == null ? BrandColors.indigo : Color(0xFF000000 | value);
}

/// Text on a group color: ink on amber, white on the others (UI design spec 1.1).
Color onGroupColor(Color background) => background.computeLuminance() > 0.45 ? BrandColors.ink : Colors.white;

/// The six group colors, in order of creation.
const groupPalette = ['#2B3990', '#12A39A', '#FFB020', '#7048E8', '#3B5BDB', '#E8590C'];

abstract final class AppRadii {
  static const groupSquare = 7.0;
  static const badge = 8.0;
  static const sm = 12.0;
  static const md = 14.0;
  static const row = 16.0;
  static const tile = 20.0;
  static const card = 24.0;
  static const hero = 28.0;
  static const pill = 999.0;
}

abstract final class AppShadows {
  static const hero = [BoxShadow(color: Color(0x381C2566), blurRadius: 40, offset: Offset(0, 18))];
  static const primaryButton = [BoxShadow(color: Color(0x402B3990), blurRadius: 24, offset: Offset(0, 10))];
  static const toggle = [BoxShadow(color: Color(0x1F1A1D3A), blurRadius: 3, offset: Offset(0, 1))];
  static const menu = [BoxShadow(color: Color(0x261C2566), blurRadius: 24, offset: Offset(0, 8))];
}

abstract final class Breakpoints {
  /// Below: phone layout (header and bottom bar).
  static const tablet = 600.0;

  /// From here the sidebar shows its labels.
  static const desktop = 1024.0;

  /// Content width from which paired blocks sit side by side.
  static const pairedBlocks = 900.0;

  static const contentMaxWidth = 1240.0;
}
