import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n/formatting.dart';
import '../../core/theme/app_text.dart';
import '../../core/theme/brand_colors.dart';
import '../../domain/model/clock_time.dart';
import '../stateManager/language/language_cubit.dart';
import 'text_field.dart';

Duration _motion(BuildContext context, [int ms = 180]) =>
    MediaQuery.disableAnimationsOf(context) ? Duration.zero : Duration(milliseconds: ms);

const _menuStyle = MenuStyle(
  backgroundColor: WidgetStatePropertyAll(Colors.white),
  surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
  padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
  maximumSize: WidgetStatePropertyAll(Size(420, 340)),
  shape: WidgetStatePropertyAll(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
      side: BorderSide(color: BrandColors.line),
    ),
  ),
);

/// The box every picker shows: value (or hint), trailing icon, chalk fill, red border on error.
class _FieldBox extends StatelessWidget {
  const _FieldBox({required this.child, required this.onTap, this.trailing, this.error = false, this.focused = false});

  final Widget child;
  final VoidCallback? onTap;
  final IconData? trailing;
  final bool error;
  final bool focused;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.md);
    final color = error ? Accent.red.strong : (focused ? BrandColors.indigo : BrandColors.line);
    return Material(
      color: BrandColors.chalk,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: color, width: focused || error ? 1.5 : 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 14, end: 12),
            child: Row(
              children: [
                Expanded(child: child),
                if (trailing != null) Icon(trailing, size: 18, color: BrandColors.slate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 6, start: 4),
    child: Text(text, style: AppText.of(context).style(12, FontWeight.w600, color: Accent.red.onSoft)),
  );
}

class SelectOption<T> {
  const SelectOption(this.value, this.label, {this.leading});

  final T value;
  final String label;
  final Widget? leading;
}

/// A labeled field that opens a menu of options.
class SelectField<T> extends StatelessWidget {
  const SelectField({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.label,
    this.errorText,
  });

  final String? label;
  final List<SelectOption<T>> options;
  final T? value;
  final ValueChanged<T> onChanged;
  final String hint;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final selected = options.where((o) => o.value == value).firstOrNull;
    final field = MenuAnchor(
      style: _menuStyle,
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            onPressed: () => onChanged(option.value),
            leadingIcon: option.leading,
            trailingIcon: option.value == value ? const Icon(LucideIcons.check, size: 16, color: BrandColors.indigo) : null,
            style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(240, 42))),
            child: Text(option.label, style: text.style(14, FontWeight.w600)),
          ),
      ],
      builder: (context, controller, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldBox(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            trailing: LucideIcons.chevronDown,
            error: errorText != null,
            focused: controller.isOpen,
            child: Row(
              children: [
                if (selected?.leading != null) ...[selected!.leading!, const SizedBox(width: 10)],
                Expanded(
                  child: Text(
                    selected?.label ?? hint,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(15, FontWeight.w500, color: selected == null ? BrandColors.slate : BrandColors.ink),
                  ),
                ),
              ],
            ),
          ),
          if (errorText != null) _ErrorText(errorText!),
        ],
      ),
    );
    return label == null ? field : LabeledField(label: label!, child: field);
  }
}

/// A calendar day, picked in the Material date picker (in the app language).
class DateField extends StatelessWidget {
  const DateField({super.key, required this.value, required this.onChanged, this.label, this.firstDate, this.lastDate, this.errorText});

  final String? label;

  /// A calendar day (UTC-flagged, 00:00).
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    final text = AppText.of(context);
    final field = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldBox(
          trailing: LucideIcons.calendar,
          error: errorText != null,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(value.year, value.month, value.day),
              firstDate: firstDate ?? DateTime(value.year - 1),
              lastDate: lastDate ?? DateTime(value.year + 2),
            );
            if (picked != null) onChanged(DateTime.utc(picked.year, picked.month, picked.day));
          },
          child: Text(
            '${weekdayShort(value, language)} ${shortDate(value, language)} ${value.year}',
            style: text.style(15, FontWeight.w500),
          ),
        ),
        if (errorText != null) _ErrorText(errorText!),
      ],
    );
    return label == null ? field : LabeledField(label: label!, child: field);
  }
}

/// A time of day in 15-minute steps, from 07:00 to 22:00, plus the current value.
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.value, required this.onChanged, this.label, this.error = false});

  final String? label;
  final ClockTime value;
  final ValueChanged<ClockTime> onChanged;
  final bool error;

  static final _steps = [for (var m = 7 * 60; m <= 22 * 60; m += 15) ClockTime(m ~/ 60, m % 60)];

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final steps = {..._steps, value}.toList()..sort();
    final field = MenuAnchor(
      style: _menuStyle,
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        for (final step in steps)
          MenuItemButton(
            onPressed: () => onChanged(step),
            style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(120, 38))),
            child: Text(
              step.hhmm,
              textDirection: TextDirection.ltr,
              style: text.style(
                14,
                step == value ? FontWeight.w800 : FontWeight.w600,
                color: step == value ? BrandColors.indigo : BrandColors.ink,
                tabular: true,
              ),
            ),
          ),
      ],
      builder: (context, controller, _) => _FieldBox(
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        trailing: LucideIcons.clock,
        error: error,
        focused: controller.isOpen,
        child: Text(value.hhmm, textDirection: TextDirection.ltr, style: text.style(15, FontWeight.w500, tabular: true)),
      ),
    );
    return label == null ? field : LabeledField(label: label!, child: field);
  }
}

/// "Présentiel | En ligne": the selected option is a white pill on chalk.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({super.key, required this.options, required this.value, required this.onChanged});

  final List<SelectOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrandColors.chalk,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Semantics(
                selected: option.value == value,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(option.value),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: _motion(context),
                      curve: Curves.easeOut,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: option.value == value ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: option.value == value ? AppShadows.toggle : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ?option.leading,
                          if (option.leading != null) const SizedBox(width: 8),
                          // A narrow phone shortens the label rather than letting it run out of the segment.
                          Flexible(
                            child: Text(
                              option.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.style(
                                14,
                                option.value == value ? FontWeight.w700 : FontWeight.w600,
                                color: option.value == value ? BrandColors.indigo : BrandColors.slate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The brand switch: indigo track, white knob that slides toward the end.
class BrandSwitch extends StatelessWidget {
  const BrandSwitch({super.key, required this.value, required this.onChanged, this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: value,
    label: label,
    child: GestureDetector(
      onTap: () => onChanged(!value),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: _motion(context),
          width: 46,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: value ? BrandColors.indigo : const Color(0xFFD5D8E4), borderRadius: BorderRadius.circular(14)),
          child: AnimatedAlign(
            duration: _motion(context),
            curve: Curves.easeOutBack,
            alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.toggle),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A radio choice as a card: "Cette séance uniquement".
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({super.key, required this.title, required this.selected, required this.onTap, this.subtitle});

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final radius = BorderRadius.circular(AppRadii.md);
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: _motion(context),
        decoration: BoxDecoration(
          color: selected ? BrandColors.indigoSoft : Colors.white,
          borderRadius: radius,
          border: Border.all(color: selected ? BrandColors.indigo : BrandColors.line, width: selected ? 1.5 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: _motion(context),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: selected ? BrandColors.indigo : const Color(0xFFADB1C6), width: selected ? 6 : 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: text.rowTitle),
                        if (subtitle != null) Text(subtitle!, style: text.style(13, FontWeight.w500, color: BrandColors.slate)),
                      ],
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

/// White search field with a magnifier.
class SearchBox extends StatelessWidget {
  const SearchBox({super.key, required this.hint, required this.onChanged, this.initialValue = '', this.width});

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: FormInput(
        hint: hint,
        initialValue: initialValue,
        onChanged: onChanged,
        icon: LucideIcons.search,
        dense: true,
        fillColor: Colors.white,
      ),
    );
  }
}

class TabItem<T> {
  const TabItem(this.value, this.label, {this.count});

  final T value;
  final String label;
  final int? count;
}

/// "Élèves 22 | Groupes 4 | ...": the selected tab is indigo on indigo soft.
class PillTabs<T> extends StatelessWidget {
  const PillTabs({super.key, required this.items, required this.value, required this.onChanged});

  final List<TabItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: BrandColors.line),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final item in items)
              Semantics(
                selected: item.value == value,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(item.value),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: _motion(context),
                      height: 38,
                      margin: const EdgeInsetsDirectional.only(end: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: item.value == value ? BrandColors.indigoSoft : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.label,
                            style: text.style(
                              14,
                              item.value == value ? FontWeight.w700 : FontWeight.w600,
                              color: item.value == value ? BrandColors.indigo : BrandColors.slate,
                            ),
                          ),
                          if (item.count != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.value == value ? Colors.white : BrandColors.chalk,
                                borderRadius: BorderRadius.circular(AppRadii.pill),
                              ),
                              child: Text(
                                '${item.count}',
                                style: text.style(
                                  12,
                                  FontWeight.w800,
                                  color: item.value == value ? BrandColors.indigo : BrandColors.slate,
                                  tabular: true,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A secondary button that opens a menu of choices: "Niveau : tous", "Tous les groupes".
class FilterMenuButton<T> extends StatelessWidget {
  const FilterMenuButton({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.icon = LucideIcons.listFilter,
  });

  final String label;
  final List<SelectOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MenuAnchor(
      style: _menuStyle,
      alignmentOffset: const Offset(0, 6),
      menuChildren: [
        for (final option in options)
          MenuItemButton(
            onPressed: () => onChanged(option.value),
            leadingIcon: option.leading,
            trailingIcon: option.value == value ? const Icon(LucideIcons.check, size: 16, color: BrandColors.indigo) : null,
            style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(220, 42))),
            child: Text(option.label, style: text.style(14, FontWeight.w600)),
          ),
      ],
      builder: (context, controller, _) => Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: const BorderSide(color: BrandColors.line),
        ),
        child: InkWell(
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          hoverColor: BrandColors.chalk,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: BrandColors.body),
                const SizedBox(width: 8),
                // On a narrow phone the label gives way (ellipsis) rather than the row overflowing.
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.style(14, FontWeight.w700, color: BrandColors.body),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(LucideIcons.chevronDown, size: 16, color: BrandColors.slate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
