import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/repository/search_repository_impl.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/search.dart';
import 'package:ngclass/domain/repositories/search_repository.dart';
import 'package:ngclass/view/screens/teacher/search/teacher_search.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/stateManager/library/library_cubit.dart';
import 'package:ngclass/view/stateManager/search/search_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart' show now;

/// "frac" and "ben" of the design (`r2/Recherche.png`, `RecherchePhone.png`).
SearchResults sampleSearch(String query) => query.startsWith('ben')
    ? const SearchResults(
        hits: [
          StudentHit(id: 's-yassine', firstName: 'Yassine', lastName: 'Ben Ali', level: fourth, groups: ['4ème année · Maths']),
          StudentHit(id: 's-malek', firstName: 'Malek', lastName: 'Ben Ali', level: fourth, groups: ['4ème année · Maths']),
          ParentHit(
            id: 'p-sonia',
            firstName: 'Sonia',
            lastName: 'Ben Ali',
            phone: '22345671',
            children: [ChildRef(id: 's-malek', firstName: 'Malek'), ChildRef(id: 's-yassine', firstName: 'Yassine')],
          ),
          GroupHit(id: 'g-sb', name: 'Sara Ben Amor · Lecture', code: 'SB', color: '#7048E8', privateLesson: true, memberCount: 1),
        ],
      )
    : query.startsWith('frac')
    ? SearchResults(
        hits: [
          const DocumentHit(
            id: 'd1',
            name: 'Série 1 : les fractions',
            tag: ContentTag.serie,
            fileKind: FileKind.pdf,
            subject: math,
            level: fourth,
            chapter: 'Les fractions',
          ),
          const ChapterHit(id: 'ch-fr', name: 'Les fractions', subject: math, level: fourth, documents: 4),
          HomeworkHit(id: 'h1', name: 'Série 1 : les fractions', group: ref4A, deadlineAt: DateTime.utc(2026, 10, 9, 17), toCorrect: 1),
          EvaluationHit(id: 'e1', name: 'Évaluation : les fractions', group: ref4A, heldOn: DateTime.utc(2026, 10, 7)),
        ],
      )
    : const SearchResults();

class FakeSearchRepository implements SearchRepository {
  final queries = <String>[];
  bool fail = false;

  @override
  Future<SearchResults> search(String query) async {
    queries.add(query);
    if (fail) throw Exception('down');
    return sampleSearch(query);
  }
}

void main() {
  setUpAll(initializeAppDates);

  late FakeSearchRepository repository;
  setUp(() {
    registerTestServices(now);
    repository = FakeSearchRepository();
    sl.registerSingleton<SearchRepository>(repository);
    sl.registerFactory<SearchCubit>(() => SearchCubit(sl.get(), delay: Duration.zero));
  });

  test('the server\'s families are read in order', () {
    final results = searchResults({
      'students': [
        {'id': 's1', 'firstName': 'Adam', 'lastName': 'Gharbi', 'level': {'fr': '4ème année', 'ar': 'السنة الرابعة'}, 'groups': ['4ème année · Maths']},
      ],
      'parents': [
        {'id': 'p1', 'firstName': 'Mouna', 'lastName': 'Gharbi', 'phone': '20000001', 'children': [{'id': 's1', 'firstName': 'Adam'}]},
      ],
      'groups': <Object>[],
      'documents': [
        {'id': 'd1', 'title': 'Série 1', 'tag': 'SERIE', 'kind': 'PDF', 'subject': {'fr': 'Maths', 'ar': 'رياضيات'}, 'level': null, 'chapter': null},
      ],
      'chapters': <Object>[],
      'homework': [
        {
          'id': 'h1',
          'title': 'Série 1',
          'group': {'id': 'g', 'name': '4A', 'code': '4A', 'color': '#2B3990', 'subject': {'fr': 'Maths', 'ar': ''}, 'privateLesson': false},
          'deadlineAt': '2026-10-09T17:00:00Z',
          'toCorrect': 2,
          'done': false,
        },
      ],
      'evaluations': [
        {
          'id': 'e1',
          'title': 'Dictée',
          'group': {'id': 'g', 'name': '4A', 'code': '4A', 'color': '#2B3990', 'subject': {'fr': 'Maths', 'ar': ''}, 'privateLesson': false},
          'heldOn': '2026-10-07',
        },
      ],
    });
    expect(results.hits.map((h) => h.kind), [SearchKind.student, SearchKind.parent, SearchKind.document, SearchKind.homework, SearchKind.evaluation]);
    expect((results.hits[1] as ParentHit).children.single.id, 's1');
    expect((results.hits[2] as DocumentHit).tag, ContentTag.serie);
    expect((results.hits[3] as HomeworkHit).toCorrect, 2);
    expect((results.hits[4] as EvaluationHit).heldOn, DateTime.utc(2026, 10, 7));
    expect(searchRoute(results.hits[1]), Routes.teacherStudent('s1'));
    expect(searchRoute(results.hits[2]), Routes.teacherDocument('d1'));
  });

  group('SearchCubit', () {
    test('from two letters, once after the last letter; ↑ ↓ stay within the lines', () async {
      final cubit = SearchCubit(repository, delay: const Duration(milliseconds: 60));
      addTearDown(cubit.close);
      cubit.changed('f');
      await Future<void>.delayed(const Duration(milliseconds: 120));
      expect(repository.queries, isEmpty);
      expect(cubit.state.searching, isFalse);

      cubit.changed('fr');
      cubit.changed('fra');
      cubit.changed('frac');
      expect(cubit.state.status, LoadStatus.loading);
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(repository.queries, ['frac']);
      expect(cubit.state.results.hits, hasLength(4));

      cubit.move(1);
      cubit.move(1);
      expect(cubit.state.current, isA<HomeworkHit>());
      cubit.move(10);
      expect(cubit.state.current, isA<EvaluationHit>());
      cubit.move(-10);
      expect(cubit.state.current, isA<DocumentHit>());
      cubit.clear();
      expect(cubit.state.query, isEmpty);
    });

    test('a failure says so; nothing found is an empty list', () async {
      final cubit = SearchCubit(repository, delay: Duration.zero);
      addTearDown(cubit.close);
      repository.fail = true;
      cubit.changed('ben');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.status, LoadStatus.failure);
      repository.fail = false;
      cubit.changed('zzz');
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.results.isEmpty, isTrue);
      expect(cubit.state.status, LoadStatus.ready);
    });
  });

  test('the typed letters are marked whatever their accents and capitals', () {
    const style = TextStyle();
    const marked = TextStyle(fontWeight: FontWeight.w900);
    final span = markedText('Élyes Ben Ali', 'ELY', style, marked);
    expect(span.children!.map((c) => (c as TextSpan).text), ['', 'Ély', 'es Ben Ali']);
    expect(markedText('Adam', 'zz', style, marked).text, 'Adam');
  });

  group('in the top bar', () {
    Future<GoRouter> pumpShell(WidgetTester tester, {AppLanguage language = AppLanguage.fr, Size size = const Size(1440, 900)}) async {
      final router = GoRouter(
        initialLocation: Routes.teacherHome,
        routes: [
          GoRoute(
            path: Routes.teacherHome,
            builder: (_, _) => AdaptiveShell(
              destinations: teacherDestinations(),
              location: Routes.teacherHome,
              search: const TeacherSearchField(),
              phoneSearch: const SearchButton(),
              child: const SizedBox.expand(),
            ),
          ),
          GoRoute(path: '/enseignante/:rest(.*)', builder: (_, state) => Scaffold(body: Text('opened ${state.uri.path}'))),
        ],
      );
      addTearDown(router.dispose);
      await pumpSignedIn(tester, const SizedBox(), router: router, language: language, size: size);
      return router;
    }

    testWidgets('results by family under the field, ↓ then Entrée opens one, Échap closes', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpShell(tester);
      expect(find.text(fr.searchPlaceholder), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'frac');
      await tester.pumpAndSettle();
      expect(find.text(fr.navContents.toUpperCase()), findsOneWidget);
      expect(find.text(fr.searchHomeworkSection.toUpperCase()), findsOneWidget);
      expect(find.textContaining('Évaluation : les fractions', findRichText: true), findsOneWidget);
      expect(find.text('${fr.chapter}${fr.dotSeparator}Mathématiques${fr.dotSeparator}4ème année${fr.dotSeparator}${fr.documentsCount(4)}'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('opened ${Routes.teacherHomework('h1')}'), findsOneWidget);
    });

    testWidgets('Échap closes; Ctrl K puts the cursor back in it', (tester) async {
      await pumpShell(tester);
      await tester.enterText(find.byType(TextField), 'ben');
      await tester.pumpAndSettle();
      expect(find.textContaining('Yassine Ben', findRichText: true), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.textContaining('Yassine Ben', findRichText: true), findsNothing);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.focusNode!.hasFocus, isTrue);
    });

    testWidgets('nothing found says what can be found', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpShell(tester);
      await tester.enterText(find.byType(TextField), 'géométrie');
      await tester.pumpAndSettle();
      expect(find.text(fr.searchNothing(isolated('géométrie'))), findsOneWidget);
      expect(find.text(fr.searchNothingHint), findsOneWidget);
    });

    testWidgets('on a phone, in Arabic: the magnifier opens the search over the screen; a parent opens the child', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpShell(tester, language: AppLanguage.ar, size: const Size(390, 844));
      expect(find.byType(TeacherSearchField), findsNothing);
      await tester.tap(find.byType(SearchButton));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ben');
      await tester.pumpAndSettle();
      expect(find.text(ar.searchParents.toUpperCase()), findsOneWidget);
      expect(find.textContaining('Sonia', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.textContaining('Sonia', findRichText: true));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsNothing);
      expect(find.text('opened ${Routes.teacherStudent('s-malek')}'), findsOneWidget);
    });
  });

  test('Contenus opens on the chapter a result points to', () async {
    final cubit = LibraryCubit(FakeContentRepository());
    addTearDown(cubit.close);
    await cubit.load(chapterId: 'ch-mul');
    expect(cubit.state.place!.chapterId, 'ch-mul');
  });
}
