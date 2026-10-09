import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import 'cards.dart';

/// The one strong action of a screen: indigo, white text, optional arrow that points forward in
/// both reading directions.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.arrow = false,
    this.icon,
    this.height = 56,
    this.shadow = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool arrow;
  final IconData? icon;
  final double height;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final radius = BorderRadius.circular(height >= 50 ? AppRadii.md : AppRadii.sm);
    final enabled = onPressed != null && !loading;
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadow && enabled ? AppShadows.primaryButton : null),
      child: Material(
        color: enabled || loading ? BrandColors.indigo : BrandColors.indigo.withValues(alpha: 0.5),
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: loading
                ? const Center(
                    widthFactor: 1,
                    child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[Icon(icon, size: 18, color: Colors.white), const SizedBox(width: 8)],
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: text.style(height >= 50 ? 16 : 14, FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      if (arrow) ...[const SizedBox(width: 10), const Icon(LucideIcons.arrowRightDir, size: 18, color: Colors.white)],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// White, bordered, ink text ("Ouvrir Meet", "Relancer", "Se déconnecter").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 44, this.trailingIcon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  /// A chevron for buttons that open a menu.
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.sm);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: BrandColors.line),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        hoverColor: BrandColors.chalk,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: height <= 40 ? 12 : 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 17, color: BrandColors.ink), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.of(context).style(height <= 40 ? 13 : 14, FontWeight.w700),
                ),
              ),
              if (trailingIcon != null) ...[const SizedBox(width: 6), Icon(trailingIcon, size: 16, color: BrandColors.slate)],
            ],
          ),
        ),
      ),
    );
  }
}

/// A bordered chip-like button with a small colored badge: the quick actions of Ma journée.
class QuickActionButton extends StatelessWidget {
  const QuickActionButton({super.key, required this.label, required this.icon, required this.accent, required this.onPressed});

  final String label;
  final IconData icon;
  final Accent accent;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.sm);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: const BorderSide(color: BrandColors.line),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Container(
          height: 42,
          padding: const EdgeInsetsDirectional.only(start: 8, end: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconBadge(icon: icon, accent: accent, size: IconBadgeSize.small),
              const SizedBox(width: 8),
              Text(label, style: AppText.of(context).style(13, FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Indigo on indigo soft: the row action ("Corriger", "Ajouter").
class TonalButton extends StatelessWidget {
  const TonalButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 38});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) => _FlatButton(
    label: label,
    icon: icon,
    onPressed: onPressed,
    height: height,
    background: BrandColors.indigoSoft,
    foreground: BrandColors.indigo,
    weight: FontWeight.w800,
  );
}

/// Text only, for "Annuler" next to a primary action.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, required this.onPressed, this.icon, this.height = 44});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) => _FlatButton(
    label: label,
    icon: icon,
    onPressed: onPressed,
    height: height,
    background: Colors.transparent,
    foreground: BrandColors.body,
    weight: FontWeight.w700,
  );
}

/// Red: archive, cancel a session. Outlined by default, filled to confirm.
class DangerButton extends StatelessWidget {
  const DangerButton({super.key, required this.label, required this.onPressed, this.icon, this.filled = false, this.height = 44});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final double height;

  @override
  Widget build(BuildContext context) => _FlatButton(
    label: label,
    icon: icon,
    onPressed: onPressed,
    height: height,
    background: filled ? Accent.red.strong : Colors.white,
    foreground: filled ? Colors.white : Accent.red.onSoft,
    border: filled ? null : const Color(0xFFF6C9C9),
    weight: FontWeight.w700,
  );
}

/// A 44 px square icon button with a tooltip (calendar arrows, archive).
class IconSquareButton extends StatelessWidget {
  const IconSquareButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.danger = false,
    this.size = 44,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool danger;
  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.sm);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: danger ? const Color(0xFFF6C9C9) : BrandColors.line),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          hoverColor: BrandColors.chalk,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, size: 18, color: danger ? Accent.red.onSoft : BrandColors.ink),
          ),
        ),
      ),
    );
  }
}

class _FlatButton extends StatelessWidget {
  const _FlatButton({
    required this.label,
    required this.onPressed,
    required this.height,
    required this.background,
    required this.foreground,
    required this.weight,
    this.icon,
    this.border,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color background;
  final Color foreground;
  final Color? border;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.sm);
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: border == null ? BorderSide.none : BorderSide(color: border!),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: foreground), const SizedBox(width: 7)],
                // In a narrow slot the label shortens instead of overflowing.
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.of(context).style(height <= 40 ? 13 : 14, weight, color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
