import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';

enum HeroVariant {
  teacher(BrandColors.indigo, AppShadows.hero),
  parent(BrandColors.indigoDeep, null),
  student(BrandColors.turquoiseDeep, null);

  const HeroVariant(this.color, this.shadow);

  final Color color;
  final List<BoxShadow>? shadow;
}

/// The one big answer of a screen: next session, average. Solid color, white text, the rising chevrons
/// behind the content at the end side (left in Arabic).
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.variant, required this.child, this.phone = false});

  final HeroVariant variant;
  final Widget child;
  final bool phone;

  @override
  Widget build(BuildContext context) {
    final patternSize = phone ? 165.0 : 300.0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(phone ? AppRadii.card : AppRadii.hero),
        boxShadow: variant.shadow,
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: phone ? -22 : -40,
            bottom: phone ? -33 : -60,
            child: ChevronPattern(size: patternSize, onStudentHero: variant == HeroVariant.student),
          ),
          Padding(
            padding: phone ? const EdgeInsets.all(20) : const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three rising chevrons and the amber spark, from the mockup SVG (viewBox 300). Painted mirrored
/// in right-to-left so the spark stays on the outer side.
class ChevronPattern extends StatelessWidget {
  const ChevronPattern({super.key, required this.size, this.onStudentHero = false});

  final double size;
  final bool onStudentHero;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _ChevronPainter(mirrored: rtl, onStudentHero: onStudentHero),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({required this.mirrored, required this.onStudentHero});

  final bool mirrored;
  final bool onStudentHero;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 300;
    canvas.save();
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    canvas.scale(k);
    void chevron(List<Offset> points, Color color, double width) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    chevron(const [Offset(40, 250), Offset(150, 140), Offset(260, 250)], Colors.white.withValues(alpha: 0.07), 34);
    chevron(const [Offset(70, 170), Offset(150, 90), Offset(230, 170)], Colors.white.withValues(alpha: 0.09), 30);
    chevron(
      const [Offset(100, 95), Offset(150, 45), Offset(200, 95)],
      onStudentHero ? Colors.white.withValues(alpha: 0.12) : BrandColors.turquoise.withValues(alpha: 0.55),
      26,
    );
    canvas.drawCircle(const Offset(232, 38), 14, Paint()..color = BrandColors.amber);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.mirrored != mirrored || oldDelegate.onStudentHero != onStudentHero;
}

/// "PROCHAINE SÉANCE" on a dark hero.
class HeroPill extends StatelessWidget {
  const HeroPill(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Text(text.upper(label), style: text.style(12, FontWeight.w700, spacing: 1, color: Colors.white)),
    );
  }
}

/// White button on a hero ("Planifier une séance", "Démarrer la séance").
class HeroButtonLight extends StatelessWidget {
  const HeroButtonLight({super.key, required this.label, required this.onPressed, this.icon = LucideIcons.play});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return _HeroButton(
      onPressed: onPressed,
      background: Colors.white,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: BrandColors.indigo),
          const SizedBox(width: 10),
          Flexible(
            child: Text(label, style: text.style(15, FontWeight.w800, color: BrandColors.indigo)),
          ),
        ],
      ),
    );
  }
}

/// Outlined see-through button on a hero ("Ouvrir Meet").
class HeroButtonGhost extends StatelessWidget {
  const HeroButtonGhost({super.key, required this.label, required this.onPressed, required this.icon});

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return _HeroButton(
      onPressed: onPressed,
      background: Colors.white.withValues(alpha: 0.08),
      border: Colors.white.withValues(alpha: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 10),
          Flexible(
            child: Text(label, style: text.style(15, FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({required this.onPressed, required this.background, required this.child, this.border});

  final VoidCallback? onPressed;
  final Color background;
  final Color? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: border == null ? BorderSide.none : BorderSide(color: border!),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          child: child,
        ),
      ),
    );
  }
}
