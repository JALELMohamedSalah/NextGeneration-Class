import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/l10n/formatting.dart';
import '../../../../core/l10n/joined_names.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../domain/model/search.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../stateManager/common/load_status.dart';
import '../../../stateManager/language/language_cubit.dart';
import '../../../stateManager/search/search_cubit.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/cards.dart';
import '../../../widgets/content_widgets.dart';
import '../../../widgets/school_widgets.dart';
import '../../../widgets/text_field.dart';

/// Where a result leads: the pupil's fiche (a parent: their first child's), the group, the document, the chapter in
/// Contenus, the homework or the evaluation.
String searchRoute(SearchHit hit) => switch (hit) {
  StudentHit h => Routes.teacherStudent(h.id),
  ParentHit h => h.children.isEmpty ? Routes.teacherStudents : Routes.teacherStudent(h.children.first.id),
  GroupHit h => Routes.teacherGroup(h.id),
  DocumentHit h => Routes.teacherDocument(h.id),
  ChapterHit h => Routes.teacherChapter(h.id),
  HomeworkHit h => Routes.teacherHomework(h.id),
  EvaluationHit h => Routes.teacherEvaluation(h.id),
};

/// The search field of the teacher's top bar (design `r2/Recherche.png`): results under it from two letters,
/// ↑ ↓ to choose, Entrée to open, Échap to close; Ctrl K (⌘ K) puts the cursor in it from any page.
class TeacherSearchField extends StatefulWidget {
  const TeacherSearchField({super.key});

  @override
  State<TeacherSearchField> createState() => _TeacherSearchFieldState();
}

class _TeacherSearchFieldState extends State<TeacherSearchField> {
  final _focus = FocusNode();
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  late final SearchCubit _cubit = sl.get<SearchCubit>();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_update);
    HardwareKeyboard.instance.addHandler(_shortcut);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_shortcut);
    _focus.dispose();
    _cubit.close();
    super.dispose();
  }

  bool _shortcut(KeyEvent event) {
    final keyboard = HardwareKeyboard.instance;
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyK && (keyboard.isControlPressed || keyboard.isMetaPressed)) {
      _focus.requestFocus();
      return true;
    }
    return false;
  }

  void _update() {
    final show = _focus.hasFocus && _cubit.state.searching;
    if (show && !_portal.isShowing) _portal.show();
    if (!show && _portal.isShowing) _portal.hide();
    if (mounted) setState(() {});
  }

  void _open(SearchHit hit) {
    final router = GoRouter.of(context);
    _cubit.clear();
    _focus.unfocus();
    router.go(searchRoute(hit));
  }

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _cubit.move(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _cubit.move(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _cubit.clear();
      _focus.unfocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<SearchCubit, SearchState>(
        listenWhen: (a, b) => a.searching != b.searching,
        listener: (_, _) => _update(),
        builder: (context, state) => OverlayPortal(
          controller: _portal,
          overlayChildBuilder: (_) => CompositedTransformFollower(
            link: _link,
            targetAnchor: AlignmentDirectional.bottomStart.resolve(Directionality.of(context)),
            followerAnchor: AlignmentDirectional.topStart.resolve(Directionality.of(context)),
            offset: const Offset(0, 8),
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: TextFieldTapRegion(
                child: BlocProvider.value(
                  value: _cubit,
                  child: _Dropdown(onOpen: _open),
                ),
              ),
            ),
          ),
          child: CompositedTransformTarget(
            link: _link,
            child: Focus(
              onKeyEvent: _keys,
              skipTraversal: true,
              child: FormInput(
                hint: l10n.searchPlaceholder,
                icon: LucideIcons.search,
                dense: true,
                fillColor: Colors.white,
                focusNode: _focus,
                initialValue: state.query,
                textInputAction: TextInputAction.search,
                onChanged: _cubit.changed,
                onSubmitted: (_) {
                  final hit = _cubit.state.current;
                  if (hit != null) _open(hit);
                },
                suffix: state.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.close,
                        icon: const Icon(LucideIcons.x, size: 16, color: BrandColors.slate),
                        onPressed: _cubit.clear,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({required this.onOpen});

  final ValueChanged<SearchHit> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final width = MediaQuery.sizeOf(context).width;
    Widget key(String name, String what) => Text.rich(
      TextSpan(
        children: [
          TextSpan(text: name, style: text.style(12, FontWeight.w800, color: BrandColors.body)),
          TextSpan(text: ' $what'),
        ],
      ),
      style: text.style(12, FontWeight.w500, color: BrandColors.slate),
    );
    return Material(
      color: Colors.white,
      elevation: 12,
      shadowColor: const Color(0x401C2566),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.tile),
        side: const BorderSide(color: BrandColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width < 700 ? width - 32 : 560, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: SearchResultsList(onOpen: onOpen, padding: const EdgeInsets.all(8))),
            if (width >= 700)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: const BoxDecoration(border: Border(top: BorderSide(color: BrandColors.rowDivider))),
                child: Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    key('↑ ↓', l10n.searchKeysChoose),
                    key(l10n.searchKeyEnter, l10n.searchKeysOpen),
                    key(l10n.searchKeyEscape, l10n.searchKeysClose),
                    key('${l10n.searchEverywhere} ', 'Ctrl K'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The results by family, the typed letters marked; loading, failure and "Rien pour …" included.
class SearchResultsList extends StatelessWidget {
  const SearchResultsList({super.key, required this.onOpen, this.padding = EdgeInsets.zero, this.big = false});

  final ValueChanged<SearchHit> onOpen;
  final EdgeInsets padding;

  /// The phone page: rows a size up.
  final bool big;

  static String _section(AppLocalizations l10n, SearchKind kind) => switch (kind) {
    SearchKind.student => l10n.navStudents,
    SearchKind.parent => l10n.searchParents,
    SearchKind.group => l10n.tabGroups,
    SearchKind.document || SearchKind.chapter => l10n.navContents,
    SearchKind.homework || SearchKind.evaluation => l10n.searchHomeworkSection,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final state = context.watch<SearchCubit>().state;
    final hits = state.results.hits;
    if (state.status == LoadStatus.failure) {
      return Padding(padding: const EdgeInsets.all(16), child: Text(l10n.errorUnknown, style: text.style(13, FontWeight.w600, color: Accent.red.onSoft)));
    }
    if (state.status == LoadStatus.loading && hits.isEmpty) {
      return const Padding(padding: EdgeInsets.all(16), child: LinearProgressIndicator(minHeight: 3));
    }
    if (hits.isEmpty) return _Nothing(query: state.query.trim());
    final rows = <Widget>[];
    String? last;
    for (final (i, hit) in hits.indexed) {
      final section = _section(l10n, hit.kind);
      if (section != last) {
        rows.add(
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, rows.isEmpty ? 6 : 12, 12, 4),
            child: Text(text.upper(section), style: text.overline(size: 11)),
          ),
        );
        last = section;
      }
      rows.add(_HitRow(hit: hit, query: state.query.trim(), highlighted: i == state.highlighted, big: big, onTap: () => onOpen(hit)));
    }
    return ListView(shrinkWrap: true, padding: padding, children: rows);
  }
}

class _Nothing extends StatelessWidget {
  const _Nothing({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const IconBadge(icon: LucideIcons.search, accent: Accent.grey),
          const SizedBox(height: 12),
          Text(l10n.searchNothing(isolated(query)), textAlign: TextAlign.center, style: text.style(16, FontWeight.w800)),
          const SizedBox(height: 6),
          Text(l10n.searchNothingHint, textAlign: TextAlign.center, style: text.style(13, FontWeight.w500, color: BrandColors.slate, height: 1.5)),
        ],
      ),
    );
  }
}

class _HitRow extends StatelessWidget {
  const _HitRow({required this.hit, required this.query, required this.highlighted, required this.big, required this.onTap});

  final SearchHit hit;
  final String query;
  final bool highlighted;
  final bool big;
  final VoidCallback onTap;

  String _subtitle(AppLocalizations l10n, BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    final dot = l10n.dotSeparator;
    String join(List<String?> parts) => parts.whereType<String>().where((p) => p.isNotEmpty).join(dot);
    return switch (hit) {
      StudentHit h => join([h.level?.of(language), ...h.groups.map(isolated)]),
      ParentHit h => join([
        l10n.parentOf(joinedNames(l10n, [for (final c in h.children) c.firstName])),
        if (h.phone != null) isolated(h.phone!),
      ]),
      GroupHit h => join([if (h.privateLesson) l10n.privateLesson, l10n.studentsCount(h.memberCount)]),
      DocumentHit h => join([tagLabel(l10n, h.tag), h.subject?.of(language), h.level?.of(language), if (h.chapter != null) isolated(h.chapter!)]),
      ChapterHit h => join([l10n.chapter, h.subject?.of(language), h.level?.of(language), l10n.documentsCount(h.documents)]),
      HomeworkHit h => join([l10n.gradeKindHomework, isolated(h.group.name), if (h.toCorrect > 0) l10n.toCorrectCount(h.toCorrect)]),
      EvaluationHit h => join([l10n.gradeKindEvaluation, isolated(h.group.name), dayDate(h.heldOn, language)]),
    };
  }

  Widget _leading() {
    final size = big ? 38.0 : 34.0;
    String initials(String first, String last) => '${first.isEmpty ? '' : first[0]}${last.isEmpty ? '' : last[0]}'.toUpperCase();
    return switch (hit) {
      StudentHit h => InitialsAvatar(initials: initials(h.firstName, h.lastName), size: size),
      ParentHit h => InitialsAvatar(initials: initials(h.firstName, h.lastName), size: size),
      GroupHit h => GroupSquare(code: h.code, color: h.color, size: size - 6),
      DocumentHit h => KindBadge(kind: h.fileKind, size: IconBadgeSize.small),
      ChapterHit _ => const IconBadge(icon: LucideIcons.folder, size: IconBadgeSize.small),
      HomeworkHit _ => const IconBadge(icon: LucideIcons.clipboardList, accent: Accent.amber, size: IconBadgeSize.small),
      EvaluationHit _ => const IconBadge(icon: LucideIcons.clipboardCheck, accent: Accent.violet, size: IconBadgeSize.small),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = AppText.of(context);
    final title = text.style(big ? 15 : 14, FontWeight.w700, color: BrandColors.body);
    return Material(
      color: highlighted ? BrandColors.indigoSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        onHover: (inside) {
          if (inside) context.read<SearchCubit>().highlight(context.read<SearchCubit>().state.results.hits.indexOf(hit));
        },
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: big ? 10 : 8),
          child: Row(
            children: [
              _leading(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      markedText(hit.title, query, title, title.copyWith(color: BrandColors.ink, fontWeight: FontWeight.w800, backgroundColor: Accent.amber.soft)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _subtitle(l10n, context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.style(12, FontWeight.w500, color: BrandColors.slate),
                    ),
                  ],
                ),
              ),
              if (highlighted && !big) ...[
                const SizedBox(width: 8),
                const Icon(LucideIcons.cornerDownLeft, size: 14, color: BrandColors.indigo),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// [text] with the first place [query] is found marked (accents and capitals ignored, lengths kept).
TextSpan markedText(String text, String query, TextStyle style, TextStyle marked) {
  final folded = foldAccents(text);
  final at = query.isEmpty ? -1 : folded.indexOf(foldAccents(query));
  if (at < 0) return TextSpan(text: text, style: style);
  return TextSpan(
    style: style,
    children: [
      TextSpan(text: text.substring(0, at)),
      TextSpan(text: text.substring(at, at + query.length), style: marked),
      TextSpan(text: text.substring(at + query.length)),
    ],
  );
}

const _accents = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'î': 'i', 'ï': 'i', 'í': 'i', //
  'ô': 'o', 'ö': 'o', 'ó': 'o', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ú': 'u', 'ç': 'c', 'ÿ': 'y', 'œ': 'o', 'æ': 'a',
};

/// Lower case without accents, one letter for one letter, so positions stay the same.
String foldAccents(String text) => text.toLowerCase().split('').map((c) => _accents[c] ?? c).join();

/// The magnifier of the teacher's phone header: the search over the whole screen.
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconSquareButton(
      icon: LucideIcons.search,
      tooltip: l10n.searchOpen,
      size: 44,
      onPressed: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(fullscreenDialog: true, builder: (_) => BlocProvider(create: (_) => sl.get<SearchCubit>(), child: const SearchPage())),
      ),
    );
  }
}

/// The phone search: the field on top, the results under it.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<SearchCubit>();
    final state = context.watch<SearchCubit>().state;
    void open(SearchHit hit) {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      router.go(searchRoute(hit));
    }

    return Scaffold(
      backgroundColor: BrandColors.chalk,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: BrandColors.line)),
              ),
              child: Row(
                children: [
                  IconSquareButton(icon: LucideIcons.arrowLeftDir, tooltip: l10n.back, size: 44, onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormInput(
                      hint: l10n.searchPlaceholder,
                      icon: LucideIcons.search,
                      dense: true,
                      fillColor: Colors.white,
                      autofocus: true,
                      initialValue: state.query,
                      textInputAction: TextInputAction.search,
                      onChanged: cubit.changed,
                      onSubmitted: (_) {
                        final hit = cubit.state.current;
                        if (hit != null) open(hit);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.searching
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: SearchResultsList(onOpen: open, big: true, padding: const EdgeInsets.fromLTRB(8, 8, 8, 24)),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
