import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/domain/model/clock_time.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/homework.dart';
import 'package:ngclass/view/screens/parent/parent_destinations.dart';
import 'package:ngclass/view/screens/shared/my_homework_detail_screen.dart';
import 'package:ngclass/view/screens/shared/my_homework_screen.dart';
import 'package:ngclass/view/screens/student/student_destinations.dart';
import 'package:ngclass/view/screens/teacher/homework/assign_panel.dart';
import 'package:ngclass/view/screens/teacher/homework/assignment_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/homework_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/stateManager/homework/assign_form_cubit.dart';
import 'package:ngclass/view/stateManager/homework/homework_list_cubit.dart';
import 'package:ngclass/view/stateManager/homework/my_homework_cubit.dart';
import 'package:ngclass/view/stateManager/homework/my_homework_detail_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/homework_widgets.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart';

void main() {
  setUpAll(initializeAppDates);

  group('AssignFormCubit', () {
    late FakeHomeworkRepository homework;
    setUp(() => homework = FakeHomeworkRepository());

    AssignFormCubit form({String? contentItemId, String? groupId}) =>
        AssignFormCubit(homework, FakeContentRepository(), FakeGroupWithMembers(), () => now, contentItemId: contentItemId, groupId: groupId);

    test('in two days at 18:00 by default; only published documents; a document given from Contenus brings its title', () async {
      final cubit = form(contentItemId: 'serie2');
      await cubit.load();

      expect(cubit.state.deadlineAt, at(8, 18));
      expect(cubit.state.loaded, isTrue);
      expect(cubit.state.documents.map((d) => d.id), isNot(contains('corrige')));
      expect(cubit.state.title, 'Série 2 : les fractions');
    });

    test('the title follows the document until the teacher writes her own', () async {
      final cubit = form();
      await cubit.load();
      cubit.setDocument('serie2');
      expect(cubit.state.title, 'Série 2 : les fractions');
      cubit.setDocument('lecon');
      expect(cubit.state.title, 'Leçon : les fractions simples');

      cubit.setTitle('Pour lundi');
      cubit.setDocument('serie2');
      expect(cubit.state.title, 'Pour lundi');
    });

    test('says what is missing; some pupils need one at least; a deadline already past is refused', () async {
      final cubit = form();
      await cubit.load();
      expect(await cubit.submit(), isNull);
      expect(cubit.state.errors, {AssignFormError.document, AssignFormError.title, AssignFormError.group});

      cubit.setDocument('serie2');
      await cubit.setGroup('g4a');
      expect(cubit.state.members, hasLength(2));
      cubit.setSomeStudents(true);
      cubit.setDate(DateTime.utc(2026, 10, 6));
      cubit.setTime(const ClockTime(9, 0));
      expect(await cubit.submit(), isNull);
      expect(cubit.state.errors, {AssignFormError.students, AssignFormError.deadline});
      expect(homework.drafts, isEmpty);
    });

    test('gives it to the whole group, or to the ticked pupils; nothing to send has no lateness', () async {
      final cubit = form(contentItemId: 'serie2', groupId: 'g4a');
      await cubit.load();
      cubit.setInstructions('Exercices 1 à 3');
      cubit.setAllowLate(true);
      final saved = await cubit.submit();

      expect(saved!.id, 'a-new');
      final draft = homework.drafts.single;
      expect(draft.groupId, 'g4a');
      expect(draft.studentIds, isEmpty);
      expect(draft.deadlineAt, at(8, 18));
      expect(draft.allowLate, isTrue);
      expect(draft.instructions, 'Exercices 1 à 3');

      cubit.setSomeStudents(true);
      cubit.toggleStudent('s2');
      cubit.setMode(SubmissionMode.none);
      expect(cubit.state.allowLate, isFalse);
      await cubit.submit();
      expect(homework.drafts.last.studentIds, ['s2']);
      expect(homework.drafts.last.mode, SubmissionMode.none);
    });
  });

  test('a written text keeps its own direction', () {
    expect(writtenDirection('Fais les exercices 1 à 3.'), TextDirection.ltr);
    expect(writtenDirection('أنجز التمارين من 1 إلى 3.'), TextDirection.rtl);
  });

  test('HomeworkListCubit: in progress (nearest first) or finished, by group; a new one shows at once', () async {
    final cubit = HomeworkListCubit(FakeHomeworkRepository());
    await cubit.load();

    expect(cubit.state.countOf(HomeworkTab.open), 2);
    expect(cubit.state.visible.map((a) => a.id), ['a-lect', 'a-fr']);
    cubit.setTab(HomeworkTab.done);
    expect(cubit.state.visible.map((a) => a.id), ['a-old']);
    cubit.filterGroup('another');
    expect(cubit.state.visible, isEmpty);

    cubit.filterGroup(null);
    cubit.saved(assignment('a-new', 'Table de 7', deadlineAt: at(9, 18)));
    expect(cubit.state.tab, HomeworkTab.open);
    expect(cubit.state.countOf(HomeworkTab.open), 3);
  });

  test('MyHomeworkCubit: to do and to read first, then what is finished; a parent asks for the child', () async {
    final repository = FakeHomeworkRepository();
    final cubit = MyHomeworkCubit(repository, () => now);
    await cubit.load(studentId: 'me');

    expect(cubit.open.map((h) => h.id), ['h-lect', 'h-fr', 'h-table']);
    expect(cubit.finished.map((h) => h.id), ['h-old']);
    expect(repository.mineAskedFor, ['me']);
  });

  group('MyHomeworkDetailCubit', () {
    test('a Word file is refused before sending; a PDF goes with its progress, for the child', () async {
      final repository = FakeHomeworkRepository();
      final cubit = MyHomeworkDetailCubit(repository, FakeFileChooser(), 'h-fr', studentId: 'me');
      await cubit.load();
      expect(cubit.state.detail!.canSubmit, isTrue);

      expect(await cubit.send(pdfFile('travail.docx')), isFalse);
      expect(cubit.state.problem, FileProblem.unsupported);
      expect(repository.submitted, isEmpty);

      final progress = <double?>[];
      final subscription = cubit.stream.listen((s) => progress.add(s.progress));
      expect(await cubit.send(pdfFile('travail.pdf')), isTrue);
      // States reach listeners asynchronously.
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(progress, containsAllInOrder(<double?>[0, 0.5, 1, null]));
      expect(repository.submitted.single.$3, 'me');
      expect(cubit.state.detail!.submission!.fileName, 'travail.pdf');
      expect(cubit.state.problem, isNull);
    });

    test('a file chosen on the device is sent; closing the picker sends nothing', () async {
      final repository = FakeHomeworkRepository();
      final chooser = FakeFileChooser();
      final cubit = MyHomeworkDetailCubit(repository, chooser, 'h-fr');
      await cubit.load();

      expect(await cubit.chooseAndSend(), isFalse);
      chooser.next = pdfFile('photo.jpg');
      expect(await cubit.chooseAndSend(), isTrue);
      expect(repository.submitted.single.$2.name, 'photo.jpg');
    });
  });

  group('teacher screens', () {
    setUp(() => registerTestServices(now));

    testWidgets('Devoirs: in progress with who sent; "Nouveau devoir" says what to type and gives the homework', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final services = registerHomeworkServices();
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherAssignments, child: const HomeworkScreen()),
      );

      expect(find.text('Série 2 : les fractions'), findsOneWidget);
      expect(find.text('Lecture : le corbeau'), findsOneWidget);
      expect(find.text('Série 1 : les fractions'), findsNothing);
      expect(find.text(fr.sentOf(1, 2)), findsOneWidget);
      expect(find.text(fr.dueTomorrow('18:00')), findsOneWidget);
      // The bar shows: each segment is as tall as the bar (sent, still to do).
      final segments = find.descendant(of: find.byType(HomeworkProgress), matching: find.byType(ColoredBox));
      expect(segments, findsNWidgets(2));
      for (final segment in segments.evaluate()) {
        expect(tester.getSize(find.byWidget(segment.widget)).height, 8);
      }

      await tester.tap(find.text(fr.newHomework).first);
      await tester.pumpAndSettle();
      expect(find.byType(AssignPanel), findsOneWidget);
      expectEveryFieldHasAHint(find.byType(AssignPanel));
      expect(find.text(fr.chooseDocument), findsOneWidget);
      expect(find.text(fr.chooseGroup), findsOneWidget);

      await tester.tap(find.text(fr.giveHomework));
      await tester.pumpAndSettle();
      expect(find.text(fr.fieldRequired), findsNWidgets(3));

      await tester.tap(find.text(fr.chooseDocument));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Série 2 : les fractions').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.chooseGroup));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4ème année · Maths${fr.dotSeparator}${fr.studentsCount(2)}').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.giveHomework));
      await tester.pumpAndSettle();

      final draft = services.homework.drafts.single;
      expect(draft.contentItemId, 'serie2');
      expect(draft.title, 'Série 2 : les fractions');
      expect(draft.groupId, 'g4a');
      expect(draft.deadlineAt, at(8, 18));
      expect(find.byType(AssignPanel), findsNothing);
      expect(find.text(fr.homeworkGiven), findsOneWidget);
      expect(find.text('Série 2 : les fractions'), findsNWidgets(2));
    });

    testWidgets('"Des élèves" lists the pupils of the group to tick', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      registerHomeworkServices();
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherAssignments, child: const HomeworkScreen()),
        size: const Size(390, 1400),
      );
      await tester.tap(find.text(fr.newHomework).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.chooseGroup));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4ème année · Maths${fr.dotSeparator}${fr.studentsCount(2)}').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.forStudents));
      await tester.pumpAndSettle();

      expect(find.text('Adam Gharbi'), findsOneWidget);
      expect(find.text('Rayen Mansour'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (language, size) in [(AppLanguage.fr, const Size(1440, 1000)), (AppLanguage.ar, const Size(390, 1400))]) {
      testWidgets('a homework in ${language.name} at ${size.width.round()}: counts, each pupil, the work; a new date; close', (tester) async {
        final l10n = l10nOf(language);
        final services = registerHomeworkServices();
        await pumpSignedIn(
          tester,
          AdaptiveShell(
            destinations: teacherDestinations(),
            location: Routes.teacherHomework('a-fr'),
            child: const AssignmentScreen(assignmentId: 'a-fr'),
          ),
          language: language,
          size: size,
        );

        expect(find.text(l10n.tileCorrected), findsOneWidget);
        expect(find.text(l10n.tileMissing), findsOneWidget);
        expect(find.text('Adam Gharbi'), findsOneWidget);
        // Sent: "Corriger" on the row and "Corriger (1)" at the top; missing: "Noter" anyway.
        expect(find.text(l10n.correctAction), findsOneWidget);
        expect(find.text(l10n.correctCount(1)), findsOneWidget);
        expect(find.text(l10n.gradeAnyway), findsOneWidget);
        expect(find.text(l10n.hwStatusMissing), findsOneWidget);

        await tester.tap(find.text(l10n.changeDeadline));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l10n.save));
        await tester.pumpAndSettle();
        expect(services.homework.deadlines.single, ('a-fr', at(8, 18)));
        expect(find.text(l10n.deadlineChanged), findsOneWidget);

        await tester.tap(find.text(l10n.closeHomework));
        await tester.pumpAndSettle();
        expect(find.text(l10n.closeHomeworkTitle(isolated('Série 2 : les fractions'))), findsOneWidget);
        await tester.tap(find.text(l10n.closeHomework).last);
        await tester.pumpAndSettle();
        expect(services.homework.closed, ['a-fr']);
        expect(find.text(l10n.closedChip), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('pupil and parent screens', () {
    setUp(() => registerTestServices(now));

    testWidgets('Mes devoirs: to do first with the deadline in words, the one to read, then what was sent', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      registerHomeworkServices();
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: studentDestinations(), location: Routes.studentAssignments, child: const MyHomeworkScreen()),
        user: pupil,
        size: const Size(390, 1400),
      );

      expect(find.text(fr.myHomeworkTitle), findsOneWidget);
      expect(find.text(fr.navAssignments), findsOneWidget);
      expect(find.text(fr.dueLabel('demain, 18:00')), findsOneWidget);
      expect(find.text(fr.dueLabel('jeudi, 18:00')), findsOneWidget);
      expect(find.text(fr.readBefore('lundi, 18:00')), findsOneWidget);
      expect(find.text(fr.sentOn('vendredi, 17:12')), findsOneWidget);
      expect(find.text(fr.hwStatusTodo), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent in Arabic: the child\'s homework, and that the parent may send it', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final services = registerHomeworkServices();
      await pumpSignedIn(
        tester,
        AdaptiveShell(destinations: parentDestinations(), location: Routes.parentAssignments, child: const MyHomeworkScreen()),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(390, 1400),
      );

      expect(find.text(ar.parentHomeworkTitle(isolated('Adam'))), findsOneWidget);
      expect(find.text(ar.parentSendsNotice(isolated('Adam'))), findsOneWidget);
      expect(services.homework.mineAskedFor, ['me']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a pupil photographs the work: it is sent, and can be replaced until the deadline', (tester) async {
      final fr = l10nOf(AppLanguage.fr);
      final services = registerHomeworkServices();
      await pumpSignedIn(tester, const MyHomeworkDetailScreen(assignmentId: 'h-fr'), user: pupil, size: const Size(390, 844));

      expect(find.text(fr.yourWork), findsOneWidget);
      expect(find.text('Fais les exercices 1 à 3 sur ton cahier.'), findsOneWidget);
      expect(find.text(fr.actionOpen), findsOneWidget);

      await tester.tap(find.text(fr.takeMyWork));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.takePhoto));
      await tester.pumpAndSettle();
      await tester.tap(find.text(fr.createPdf));
      await tester.pumpAndSettle();

      final (id, file, studentId) = services.homework.submitted.single;
      expect(id, 'h-fr');
      expect(file.name, 'Scan du 6 octobre.pdf');
      expect(studentId, isNull);
      expect(find.text(fr.workSent), findsOneWidget);
      expect(find.text(fr.replaceMyWork), findsOneWidget);
      expect(find.text(fr.canReplaceUntilTu('jeudi, 18:00')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent in Arabic: past the deadline, nothing sent says so and offers no button', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final services = registerHomeworkServices();
      final late = mineOf('h-late', 'Série 1 : les fractions', deadlineAt: at(5, 18), status: HomeworkStatus.missing);
      services.homework.details['h-late'] = myDetailOf(late, canSubmit: false);
      await pumpSignedIn(
        tester,
        const MyHomeworkDetailScreen(assignmentId: 'h-late', studentId: 'me'),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(390, 844),
      );

      expect(find.text(ar.missingNotice), findsOneWidget);
      // The teacher's French instructions keep their own direction in the Arabic app.
      expect(tester.widget<Text>(find.text('Fais les exercices 1 à 3 sur ton cahier.')).textDirection, TextDirection.ltr);
      expect(find.text(ar.takeTheWork), findsNothing);
      expect(find.text(ar.orChooseFile), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a parent can send for the child while it is open', (tester) async {
      final ar = l10nOf(AppLanguage.ar);
      final services = registerHomeworkServices();
      services.chooser.next = pdfFile('cahier.pdf');
      await pumpSignedIn(
        tester,
        const MyHomeworkDetailScreen(assignmentId: 'h-fr', studentId: 'me'),
        user: parent,
        language: AppLanguage.ar,
        size: const Size(1440, 900),
      );

      expect(find.text(ar.childWork(isolated('Adam'))), findsOneWidget);
      await tester.tap(find.text(ar.orChooseFile));
      await tester.pumpAndSettle();
      expect(services.homework.submitted.single.$3, 'me');
      expect(find.text(ar.sentWork), findsOneWidget);
      expect(find.text(ar.replaceTheWork), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
