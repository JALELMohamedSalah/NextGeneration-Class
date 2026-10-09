import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/reference.dart';
import 'package:ngclass/view/screens/teacher/settings/settings_screen.dart';
import 'package:ngclass/view/stateManager/common/load_status.dart';
import 'package:ngclass/view/stateManager/reference/reference_cubit.dart';
import 'package:ngclass/view/stateManager/settings/subjects_settings_cubit.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

const lecture = Subject(
  id: 'lecture',
  name: LocalizedText(fr: 'Lecture', ar: 'القراءة'),
  color: '#12A39A',
);
const francais = Subject(
  id: 'francais',
  name: LocalizedText(fr: 'Français', ar: ''),
  color: '#7048E8',
);
const mathematics = Subject(id: 'math', name: math, color: '#2B3990');

List<SubjectUsage> sampleUsage() => const [
  SubjectUsage(subject: mathematics, groupCount: 2),
  SubjectUsage(subject: lecture, groupCount: 1),
  SubjectUsage(subject: francais, groupCount: 0),
];

void main() {
  setUpAll(initializeAppDates);
  setUp(() => registerTestServices(TunisTime.instant(DateTime.utc(2026, 10, 6), const ClockTime(9, 0))));

  group('SubjectsSettingsCubit', () {
    blocTest<SubjectsSettingsCubit, SubjectsSettingsState>(
      'loads each subject with its groups',
      build: () => SubjectsSettingsCubit(FakeReferenceRepository(usage: sampleUsage())),
      act: (cubit) => cubit.load(),
      expect: () => [const SubjectsSettingsState(), SubjectsSettingsState(status: LoadStatus.ready, subjects: sampleUsage())],
    );

    blocTest<SubjectsSettingsCubit, SubjectsSettingsState>(
      'a failed load keeps its failure for the retry banner',
      build: () => SubjectsSettingsCubit(FakeReferenceRepository()..usageFailure = const ApiFailure(code: ApiFailure.network)),
      act: (cubit) => cubit.load(),
      verify: (cubit) {
        expect(cubit.state.status, LoadStatus.failure);
        expect(cubit.state.failure?.isNetwork, isTrue);
      },
    );

    blocTest<SubjectsSettingsCubit, SubjectsSettingsState>(
      'a new subject goes last without groups, an edited one keeps its place and count, a deleted one leaves',
      build: () => SubjectsSettingsCubit(FakeReferenceRepository()),
      seed: () => SubjectsSettingsState(status: LoadStatus.ready, subjects: sampleUsage()),
      act: (cubit) => cubit
        ..saved(
          const Subject(
            id: 'eveil',
            name: LocalizedText(fr: 'Éveil', ar: ''),
            color: '#FFB020',
          ),
        )
        ..saved(
          const Subject(
            id: 'math',
            name: LocalizedText(fr: 'Maths', ar: 'الرياضيات'),
            color: '#3B5BDB',
          ),
        )
        ..removed('francais'),
      verify: (cubit) {
        final subjects = cubit.state.subjects;
        expect(subjects.map((s) => s.subject.id), ['math', 'lecture', 'eveil']);
        expect(subjects.first.subject.name.fr, 'Maths');
        expect(subjects.first.groupCount, 2);
        expect(subjects.last.groupCount, 0);
      },
    );
  });

  group('ReferenceCubit subjects', () {
    test('an edited subject keeps its place; a deleted one disappears from every form', () async {
      final repository = FakeReferenceRepository(
        reference: const Reference(subjects: [mathematics, lecture], levels: [], currentYear: null),
      );
      final cubit = ReferenceCubit(repository);
      await cubit.load();

      final (edited, _) = await cubit.updateSubject('math', const SubjectDraft(nameFr: 'Maths', color: '#2B3990'));
      expect(edited?.name.fr, 'Maths');
      expect(cubit.state.reference!.subjects.map((s) => s.name.fr), ['Maths', 'Lecture']);

      expect(await cubit.deleteSubject('lecture'), isNull);
      expect(cubit.state.reference!.subjects.map((s) => s.id), ['math']);
      expect(repository.deletedSubjects, ['lecture']);
    });

    test('a refused deletion returns the server failure and keeps the subject', () async {
      final repository = FakeReferenceRepository()
        ..deleteFailure = const ApiFailure(code: 'subject_in_use', message: 'Utilisée', statusCode: 409);
      final cubit = ReferenceCubit(repository);
      await cubit.load();

      final failure = await cubit.deleteSubject('math');
      expect(failure?.code, 'subject_in_use');
      expect(cubit.state.reference!.subjects, isNotEmpty);
    });
  });

  group('Paramètres screen', () {
    late FakeReferenceRepository repository;

    setUp(() => repository = FakeReferenceRepository(reference: referenceWithYear, usage: sampleUsage()));

    Future<void> pumpSettings(WidgetTester tester, {AppLanguage language = AppLanguage.fr, Size size = const Size(1440, 1000)}) =>
        pumpSignedIn(
          tester,
          BlocProvider(
            create: (_) => SubjectsSettingsCubit(repository)..load(),
            child: const Scaffold(body: SettingsView()),
          ),
          language: language,
          size: size,
          reference: repository,
        );

    testWidgets('lists the subjects with both names and their groups, the levels and the school year', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSettings(tester);

      expect(find.text(fr.navSettings), findsWidgets);
      expect(find.text(fr.yourSubjects), findsOneWidget);
      expect(find.text('Mathématiques'), findsOneWidget);
      expect(find.text('الرياضيات'), findsOneWidget, reason: 'the Arabic name is shown under the French one');
      expect(find.text(fr.subjectNoArabicName), findsOneWidget, reason: 'Français has no Arabic name');
      expect(find.text('2 groupes'), findsOneWidget);
      expect(find.text('1 groupe'), findsOneWidget);
      expect(find.text('Aucun groupe'), findsOneWidget);
      expect(find.text(fr.subjectDeleteRule), findsOneWidget);
      expect(find.text('4ème année'), findsOneWidget);
      expect(find.text(fr.primarySchool), findsOneWidget);
      expect(find.text('2026-2027'), findsOneWidget);
      expect(find.text('du 1er septembre 2026 au 30 juin 2027'), findsOneWidget);
    });

    testWidgets('a subject used by a group cannot be deleted; an unused one can, after confirming', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSettings(tester);

      expect(find.byTooltip(fr.subjectInUse), findsNWidgets(2));
      await tester.tap(find.byTooltip(fr.subjectInUse).first);
      await tester.pumpAndSettle();
      expect(find.text(fr.deleteSubjectText), findsNothing, reason: 'nothing to confirm for a subject in use');

      await tester.tap(find.byTooltip(fr.delete));
      await tester.pumpAndSettle();
      expect(find.text(fr.deleteSubjectTitle('Français')), findsOneWidget);
      await tester.tap(find.text(fr.delete).last);
      await tester.pumpAndSettle();

      expect(repository.deletedSubjects, ['francais']);
      expect(find.text('Aucun groupe'), findsNothing);
      expect(find.text(fr.subjectDeleted), findsOneWidget);
    });

    testWidgets('when the server refuses, its message is shown and the counts are reloaded', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.deleteFailure = const ApiFailure(
        code: 'subject_in_use',
        message: 'Cette matière est utilisée par un groupe.',
        statusCode: 409,
      );
      await pumpSettings(tester);

      repository.usage = const [
        SubjectUsage(subject: mathematics, groupCount: 2),
        SubjectUsage(subject: lecture, groupCount: 1),
        SubjectUsage(subject: francais, groupCount: 1),
      ];
      await tester.tap(find.byTooltip(fr.delete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.delete).last);
      await tester.pumpAndSettle();

      expect(find.text('Cette matière est utilisée par un groupe.'), findsOneWidget);
      expect(find.text('Aucun groupe'), findsNothing);
      expect(find.byTooltip(fr.delete), findsNothing, reason: 'every subject is in use now');
    });

    testWidgets('editing opens the filled form and the row follows the new name', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSettings(tester);

      await tester.tap(find.text(fr.edit).at(1));
      await tester.pumpAndSettle();
      expect(find.text(fr.editSubject), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Lecture'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Lecture'), 'Lecture et écriture');
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();

      expect(repository.updatedSubjects.single.$1, 'lecture');
      expect(repository.updatedSubjects.single.$2.nameAr, 'القراءة');
      expect(find.text('Lecture et écriture'), findsOneWidget);
      expect(find.text(fr.subjectUpdated), findsOneWidget);
    });

    testWidgets('a new subject is added at the end with no group', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      await pumpSettings(tester);

      await tester.tap(find.text(fr.newSubject));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Éveil scientifique');
      await tester.tap(find.text(fr.save));
      await tester.pumpAndSettle();

      expect(repository.createdSubjects.single.nameFr, 'Éveil scientifique');
      expect(find.text('Éveil scientifique'), findsOneWidget);
      expect(find.text('Aucun groupe'), findsNWidgets(2));
    });

    testWidgets('in Arabic on a phone: Arabic names first, right to left, nothing overflows', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      await pumpSettings(tester, language: AppLanguage.ar, size: const Size(390, 844));

      expect(tester.takeException(), isNull);
      expect(find.text(ar.yourSubjects), findsOneWidget);
      expect(find.text(ar.subjectNoArabicName), findsOneWidget);
      expect(find.text(ar.schoolYearRange('1 سبتمبر 2026', '30 جوان 2027')), findsOneWidget, reason: 'Tunisian month names');
      final arabicName = tester.getTopLeft(find.text('القراءة'));
      final frenchName = tester.getTopLeft(find.text('Lecture'));
      expect(arabicName.dy, lessThan(frenchName.dy), reason: 'the name in the interface language comes first');
      expect(Directionality.of(tester.element(find.text(ar.yourSubjects))), TextDirection.rtl);
      expect(find.byTooltip(ar.edit), findsNWidgets(3), reason: 'phones show a pencil instead of the "Modifier" button');
    });

    testWidgets('no subject yet: a friendly empty state with the button to create one', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      repository.usage = const [];
      await pumpSettings(tester);

      expect(find.text(fr.noSubjectsYet), findsOneWidget);
      expect(find.text(fr.newSubject), findsOneWidget);
      expect(find.text(fr.subjectDeleteRule), findsNothing);
    });
  });
}
