import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';

/// White block with a 1 px border and no shadow: title row, then content.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.title, this.count, this.countAccent = Accent.amber, this.trailing, this.phone});

  final String? title;
  final int? count;
  final Accent countAccent;

  /// Usually a [CardLink] ("Tout voir", "Planning").
  final Widget? trailing;
  final Widget child;

  /// Phone padding and title size; null follows the screen width.
  final bool? phone;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final phone = this.phone ?? MediaQuery.sizeOf(context).width < Breakpoints.tablet;
    return Container(
      padding: EdgeInsets.all(phone ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(phone ? AppRadii.tile : AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(title!, style: text.sectionTitle(phone: phone)),
                      ),
                      if (count != null) ...[const SizedBox(width: 10), CountPill(count: count!, accent: countAccent)],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
            SizedBox(height: phone ? 12 : 16),
          ],
          child,
        ],
      ),
    );
  }
}

/// "Tout voir": a quiet indigo link at the end of a card header.
class CardLink extends StatelessWidget {
  const CardLink({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadii.badge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(label, style: AppText.of(context).style(13, FontWeight.w700, color: BrandColors.indigo)),
      ),
    );
  }
}

class CountPill extends StatelessWidget {
  const CountPill({super.key, required this.count, this.accent = Accent.amber});

  final int count;
  final Accent accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: accent.soft, borderRadius: BorderRadius.circular(AppRadii.pill)),
    child: Text('$count', style: AppText.of(context).style(12, FontWeight.w800, color: accent.onSoft, tabular: true)),
  );
}

enum IconBadgeSize {
  large(40, 12, 20),
  medium(36, 10, 17),
  small(26, 8, 15);

  const IconBadgeSize(this.box, this.radius, this.icon);

  final double box;
  final double radius;
  final double icon;
}

/// An icon on a soft square of its accent.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.accent = Accent.indigo, this.size = IconBadgeSize.large});

  final IconData icon;
  final Accent accent;
  final IconBadgeSize size;

  @override
  Widget build(BuildContext context) => Container(
    width: size.box,
    height: size.box,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: accent.soft, borderRadius: BorderRadius.circular(size.radius)),
    child: Icon(icon, size: size.icon, color: accent.onSoft),
  );
}

/// A status always says its word next to its color.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.accent, this.solid = false});

  final String label;
  final Accent accent;

  /// "Prochaine": solid indigo with white text, no dot.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: solid ? accent.strong : accent.soft, borderRadius: BorderRadius.circular(AppRadii.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!solid) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent.strong, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.style(12, FontWeight.w700, color: solid ? Colors.white : accent.onSoft),
            ),
          ),
        ],
      ),
    );
  }
}

/// Initials on a circle: a soft color picked from the initials (the same one every time), or [solid].
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, this.size = 40, this.solid});

  final String initials;
  final double size;

  /// A strong background with white initials (the signed-in user's own avatar).
  final Color? solid;

  static Accent accentFor(String key) {
    const choices = [Accent.indigo, Accent.turquoise, Accent.amber, Accent.violet, Accent.blue, Accent.orange];
    final hash = key.codeUnits.fold<int>(0, (sum, unit) => (sum * 31 + unit) & 0x7fffffff);
    return choices[hash % choices.length];
  }

  @override
  Widget build(BuildContext context) {
    final accent = accentFor(initials);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: solid ?? accent.soft, shape: BoxShape.circle),
      child: Text(
        initials,
        textDirection: TextDirection.ltr,
        style: AppText.of(context).style(size >= 40 ? 14 : 13, FontWeight.w800, color: solid == null ? accent.onSoft : Colors.white),
      ),
    );
  }
}

/// A quiet hint on chalk: info or clock icon, one sentence.
class InfoNote extends StatelessWidget {
  const InfoNote({super.key, required this.text, this.icon = LucideIcons.info});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: BrandColors.chalk, borderRadius: BorderRadius.circular(AppRadii.md)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: BrandColors.indigo),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppText.of(context).style(13, FontWeight.w500, color: BrandColors.body, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

/// A refusal or an error, inline under a form or at the top of a block.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message, this.onRetry, this.retryLabel});

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Accent.red.soft, borderRadius: BorderRadius.circular(AppRadii.md)),
      child: Row(
        children: [
          Icon(LucideIcons.triangleAlert, size: 18, color: Accent.red.onSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: text.style(13, FontWeight.w600, color: Accent.red.onSoft, height: 1.5)),
          ),
          if (onRetry != null && retryLabel != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(AppRadii.badge),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(retryLabel!, style: text.style(13, FontWeight.w800, color: Accent.red.onSoft)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
