import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_language.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/teacher_dashboard.dart';
import '../../l10n/app_localizations.dart';

/// The coming days as equal tiles: weekday, date, number of sessions. Rest days are hatched.
class DayStrip extends StatelessWidget {
  const DayStrip({super.key, required this.days, this.selected});

  final List<DayLoad> days;
  final DateTime? selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _DayTile(day: days[i], selected: days[i].date == selected),
          ),
        ],
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day, required this.selected});

  final DayLoad day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final language = AppLanguage.fromCode(Localizations.localeOf(context).languageCode);
    final weekday = DateFormat.E(language.dateLocale).format(day.date).replaceAll('.', '');
    final caption = day.restDay ? l10n.noValue : l10n.daySessions(day.sessions);
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? BrandColors.indigoDeep : (day.restDay ? null : BrandColors.chalk),
        borderRadius: BorderRadius.circular(AppRadii.row),
      ),
      child: Column(
        children: [
          Text(
            weekday.isEmpty ? weekday : weekday[0].toUpperCase() + weekday.substring(1),
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: text.style(12, FontWeight.w700, color: selected ? Colors.white70 : BrandColors.slate),
          ),
          const SizedBox(height: 2),
          Text(
            '${day.date.day}',
            style: text.style(
              22,
              FontWeight.w800,
              color: selected ? Colors.white : (day.restDay ? BrandColors.slate : BrandColors.ink),
              tabular: true,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.fade,
            softWrap: false,
            style: text.style(11, FontWeight.w700, color: selected ? BrandColors.amber : BrandColors.slate),
          ),
        ],
      ),
    );
    if (!day.restDay) return tile;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.row),
      child: CustomPaint(painter: _HatchPainter(), child: tile),
    );
  }
}

class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = BrandColors.chalk);
    final paint = Paint()
      ..color = const Color(0xFFECEEF4)
      ..strokeWidth = 6;
    for (var x = -size.height; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => false;
}
