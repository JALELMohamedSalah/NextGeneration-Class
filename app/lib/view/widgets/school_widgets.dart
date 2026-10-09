import 'package:flutter/material.dart';

import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/session.dart';
import '../../l10n/app_localizations.dart';
import 'cards.dart';

Duration _motion(BuildContext context, int ms) => MediaQuery.disableAnimationsOf(context) ? Duration.zero : Duration(milliseconds: ms);

/// The colored square of a group with its two-letter code ("7A").
class GroupSquare extends StatelessWidget {
  const GroupSquare({super.key, required this.code, required this.color, this.size = 24});

  final String code;
  final String color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final background = colorFromHex(color);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(size * 0.29)),
      child: Text(
        code,
        textDirection: TextDirection.ltr,
        style: AppText.of(context).style(size * 0.42, FontWeight.w800, color: onGroupColor(background)),
      ),
    );
  }
}

/// Square + name: "7A 7ème A · Math".
class GroupLabel extends StatelessWidget {
  const GroupLabel({super.key, required this.code, required this.color, required this.name, this.size = 20});

  final String code;
  final String color;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      GroupSquare(code: code, color: color, size: size),
      const SizedBox(width: 8),
      Flexible(
        child: Text(name, overflow: TextOverflow.ellipsis, style: AppText.of(context).style(13, FontWeight.w600)),
      ),
    ],
  );
}

/// A number that counts up to its value.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({super.key, required this.value, required this.style, this.suffix = ''});

  final int value;
  final String suffix;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value.toDouble()),
    duration: _motion(context, 700),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => Text('${v.round()}$suffix', textDirection: TextDirection.ltr, style: style),
  );
}

/// Icon badge and caption on top, a big value, a label (UI design spec 2).
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.label,
    this.value,
    this.valueText,
    this.suffix = '',
    this.caption,
    this.captionColor,
  });

  final IconData icon;
  final Accent accent;

  /// Null shows "—".
  final int? value;

  /// A value that is not a whole number ("15,25"), shown as is instead of [value].
  final String? valueText;
  final String suffix;
  final String label;
  final String? caption;
  final Color? captionColor;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, accent: accent),
              const Spacer(),
              if (caption != null)
                Flexible(
                  child: Text(
                    caption!,
                    textAlign: TextAlign.end,
                    style: text.style(12, FontWeight.w700, color: captionColor ?? BrandColors.slate),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (valueText != null)
            Text(valueText!, textDirection: TextDirection.ltr, style: text.statValue)
          else if (value == null)
            Text(l10n.noValue, style: text.statValue)
          else
            AnimatedCount(value: value!, suffix: suffix, style: text.statValue),
          Text(label, style: text.style(14, FontWeight.w600, color: BrandColors.slate)),
        ],
      ),
    );
  }
}

/// The color of an attendance rate: green from 85 %, orange from 75 %, red below.
Color attendanceColor(int? rate) => rate == null
    ? BrandColors.slate
    : rate >= 85
    ? Accent.green.onSoft
    : (rate >= 75 ? Accent.orange.onSoft : Accent.red.onSoft);

/// A thin bar that fills up to [value] percent.
class MiniBar extends StatelessWidget {
  const MiniBar({super.key, required this.value, required this.color, this.height = 6});

  final int value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height / 2),
    child: Container(
      height: height,
      color: BrandColors.rowDivider,
      alignment: AlignmentDirectional.centerStart,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0, 100) / 100),
        duration: _motion(context, 600),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => FractionallySizedBox(
          widthFactor: v,
          child: Container(color: color),
        ),
      ),
    ),
  );
}

/// The status of a session as a chip: always a word next to the color.
class SessionStatusChip extends StatelessWidget {
  const SessionStatusChip({super.key, required this.status, this.next = false});

  final SessionStatus status;

  /// The next session of the day: solid indigo "Prochaine".
  final bool next;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (next) return StatusChip(label: l10n.statusNext, accent: Accent.indigo, solid: true);
    return switch (status) {
      SessionStatus.planned => StatusChip(label: l10n.statusPlanned, accent: Accent.blue),
      SessionStatus.inProgress => StatusChip(label: l10n.statusInProgress, accent: Accent.turquoise),
      SessionStatus.done => StatusChip(label: l10n.statusDone, accent: Accent.green),
      SessionStatus.cancelled => StatusChip(label: l10n.statusCancelled, accent: Accent.grey),
    };
  }
}

/// A student's own attendance mark as a chip.
class AttendanceChip extends StatelessWidget {
  const AttendanceChip({super.key, required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      AttendanceStatus.present => StatusChip(label: l10n.attendancePresent, accent: Accent.green),
      AttendanceStatus.absent => StatusChip(label: l10n.attendanceAbsent, accent: Accent.red),
      AttendanceStatus.late => StatusChip(label: l10n.attendanceLate, accent: Accent.orange),
    };
  }
}

/// A row of a day: time column, colored bar, title and subtitle, a chip at the end (UI spec 2).
class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
    required this.start,
    required this.end,
    required this.color,
    required this.title,
    this.subtitle,
    this.trailing,
    this.current = false,
    this.past = false,
    this.struck = false,
    this.onTap,
  });

  final String start;
  final String end;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool current;
  final bool past;
  final bool struck;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final radius = BorderRadius.circular(AppRadii.row);
    return Opacity(
      opacity: past || struck ? 0.62 : 1,
      child: Material(
        color: current ? BrandColors.indigoSoft : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          hoverColor: BrandColors.chalk,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 48,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            start,
                            style: text.style(14, FontWeight.w800, color: current ? BrandColors.indigo : BrandColors.ink, tabular: true),
                          ),
                          Text(end, style: text.style(12, FontWeight.w500, color: BrandColors.slate, tabular: true)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 4,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: text.rowTitle.copyWith(
                            decoration: struck ? TextDecoration.lineThrough : null,
                            color: struck ? BrandColors.slate : null,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(subtitle!, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[const SizedBox(width: 10), Align(alignment: Alignment.topCenter, child: trailing)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Session mode: one tap cycles Présent, Absent, En retard. The color eases from one to the next.
class AttendanceTile extends StatelessWidget {
  const AttendanceTile({super.key, required this.name, required this.initials, required this.status, required this.onTap});

  final String name;
  final String initials;
  final AttendanceStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final (border, background, foreground, label) = switch (status) {
      AttendanceStatus.present => (const Color(0xFFCDEBD3), const Color(0xFFF3FBF5), Accent.green.onSoft, l10n.attendancePresent),
      AttendanceStatus.absent => (const Color(0xFFF6C9C9), const Color(0xFFFEF5F5), Accent.red.onSoft, l10n.attendanceAbsent),
      AttendanceStatus.late => (const Color(0xFFF7D3BE), const Color(0xFFFEF7F2), Accent.orange.onSoft, l10n.attendanceLate),
    };
    final radius = BorderRadius.circular(AppRadii.row);
    return Semantics(
      button: true,
      label: '$name, $label',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _motion(context, 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius,
          border: Border.all(color: border, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Text(
                      initials,
                      textDirection: TextDirection.ltr,
                      style: text.style(13, FontWeight.w800, color: foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name, overflow: TextOverflow.ellipsis, style: text.rowTitle),
                  ),
                  AnimatedSwitcher(
                    duration: _motion(context, 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(animation), child: child),
                    ),
                    child: Text(
                      label,
                      key: ValueKey(status),
                      style: text.style(13, FontWeight.w800, color: foreground),
                    ),
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

/// Overlapping avatars with "+N" (UI design spec 2).
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.initials, this.total, this.size = 32, this.max = 4});

  final List<String> initials;
  final int? total;
  final double size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final shown = initials.take(max).toList();
    final rest = (total ?? initials.length) - shown.length;
    final overlap = size * 0.3;
    Widget ring(Widget child) => Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
      ),
      child: child,
    );
    final items = [
      for (final i in shown) ring(InitialsAvatar(initials: i, size: size)),
      if (rest > 0)
        ring(
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: BrandColors.ink, shape: BoxShape.circle),
            child: Text(
              '+$rest',
              textDirection: TextDirection.ltr,
              style: AppText.of(context).style(12, FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
    ];
    final step = size + 5 - overlap;
    return SizedBox(
      height: size + 5,
      width: items.isEmpty ? 0 : step * (items.length - 1) + size + 5,
      child: Stack(
        children: [for (var i = 0; i < items.length; i++) PositionedDirectional(start: step * i, child: items[i])],
      ),
    );
  }
}

/// A card that lifts slightly under the mouse (desktop), and can be tapped.
class HoverCard extends StatefulWidget {
  const HoverCard({super.key, required this.child, this.onTap, this.radius = AppRadii.card, this.padding = const EdgeInsets.all(24)});

  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: _motion(context, 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover && widget.onTap != null ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: _hover && widget.onTap != null ? const Color(0xFFD5D8E4) : BrandColors.line),
          boxShadow: _hover && widget.onTap != null
              ? const [BoxShadow(color: Color(0x141C2566), blurRadius: 24, offset: Offset(0, 10))]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            hoverColor: Colors.transparent,
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
