import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/formatting.dart';
import 'package:ngclass/core/platform/document_printer.dart';
import 'package:ngclass/core/router/routes.dart';
import 'package:ngclass/data/repository/dashboard_repository_impl.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/model/content.dart';
import 'package:ngclass/domain/model/homework.dart';
import 'package:ngclass/domain/model/localized_text.dart';
import 'package:ngclass/domain/model/scan.dart';
import 'package:ngclass/domain/model/session.dart';
import 'package:ngclass/domain/model/student.dart';
import 'package:ngclass/domain/repositories/comment_repository.dart';
import 'package:ngclass/domain/repositories/evaluation_repository.dart';
import 'package:ngclass/domain/repositories/group_repository.dart';
import 'package:ngclass/domain/repositories/homework_repository.dart';
import 'package:ngclass/domain/repositories/planning_repository.dart';
import 'package:ngclass/domain/repositories/results_repository.dart';
import 'package:ngclass/domain/repositories/search_repository.dart';
import 'package:ngclass/domain/repositories/student_repository.dart';
import 'package:ngclass/view/screens/admin/admin_destinations.dart';
import 'package:ngclass/view/screens/admin/teachers_screen.dart';
import 'package:ngclass/view/screens/parent/parent_destinations.dart';
import 'package:ngclass/view/screens/parent/parent_overview_screen.dart';
import 'package:ngclass/view/screens/shared/document_screen.dart';
import 'package:ngclass/view/screens/shared/my_contents_screen.dart';
import 'package:ngclass/view/screens/shared/my_homework_detail_screen.dart';
import 'package:ngclass/view/screens/shared/my_homework_screen.dart';
import 'package:ngclass/view/screens/shared/my_planning_screen.dart';
import 'package:ngclass/view/screens/shared/my_results_screen.dart';
import 'package:ngclass/view/screens/shared/notifications_screen.dart';
import 'package:ngclass/view/screens/student/student_destinations.dart';
import 'package:ngclass/view/screens/student/student_home_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/contents_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/crop_screen.dart';
import 'package:ngclass/view/screens/teacher/contents/scan_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/assignment_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/correction_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/evaluation_panel.dart';
import 'package:ngclass/view/screens/teacher/homework/evaluation_screen.dart';
import 'package:ngclass/view/screens/teacher/homework/homework_screen.dart';
import 'package:ngclass/view/screens/teacher/planning/session_mode_screen.dart';
import 'package:ngclass/view/screens/teacher/search/teacher_search.dart';
import 'package:ngclass/view/screens/teacher/students/student_import_screen.dart';
import 'package:ngclass/view/screens/teacher/students/student_profile_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_destinations.dart';
import 'package:ngclass/view/screens/teacher/teacher_home_screen.dart';
import 'package:ngclass/view/screens/teacher/teacher_notifications_panel.dart';
import 'package:ngclass/view/stateManager/admin/teachers_cubit.dart';
import 'package:ngclass/view/stateManager/homework/correction_cubit.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/stateManager/scan/crop_cubit.dart';
import 'package:ngclass/view/stateManager/scan/scan_cubit.dart';
import 'package:ngclass/view/stateManager/search/search_cubit.dart';
import 'package:ngclass/view/stateManager/session_mode/session_mode_cubit.dart';
import 'package:ngclass/view/stateManager/student_import/student_import_cubit.dart';
import 'package:ngclass/view/stateManager/teacher_home/teacher_home_cubit.dart';
import 'package:ngclass/view/widgets/adaptive_shell.dart';
import 'package:ngclass/view/widgets/notification_bell.dart';

import '../helpers/content_fixtures.dart';
import '../helpers/fakes.dart';
import '../helpers/homework_fixtures.dart';
import '../helpers/pump_app.dart';
import '../helpers/student_fixtures.dart';
import 'admin_test.dart' show accounts, owner;
import 'search_test.dart' show FakeSearchRepository;
import 'student_import_test.dart' show FakeDocumentPrinter, FakeStudentImportRepository;
import 'teacher_notifications_test.dart' show teacherSample;

/// Every size the app meets, from the smallest phone to a wide screen, short and tall windows.
const sizes = [
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(600, 960),
  Size(768, 1024),
  Size(1024, 768),
  Size(1280, 720),
  Size(1440, 900),
  Size(1920, 1080),
];

/// A name as long as a teacher may write it, to make rows wrap.
const longName = GroupRef(
  id: 'gp',
  name: 'Cours particulier · Mathématiques et lecture',
  code: 'CP',
  color: '#7048E8',
  subject: LocalizedText(fr: 'Mathématiques', ar: 'الرياضيات'),
  privateLesson: true,
);

void main() {
  setUpAll(initializeAppDates);

  setUp(() {
    registerTestServices(now);
    sl.registerSingleton<PlanningRepository>(
      FakePlanningRepository()
        ..mine = [...week(), mine('long', longName, at(9, 16), mode: SessionMode.online)]
        // Session mode: a long group name, two pupils, the group's documents beside them.
        ..detailResult = SessionDetail(
          session: Session(
            id: 's1',
            group: longName,
            startsAt: at(6, 9, 30),
            endsAt: at(6, 11),
            mode: SessionMode.inPerson,
            status: SessionStatus.inProgress,
            location: 'Salle 2',
          ),
          roster: const [
            RosterEntry(studentId: 'a', firstName: 'Yasmine', lastName: 'Ben Abdallah Trabelsi'),
            RosterEntry(studentId: 'b', firstName: 'Omar', lastName: 'Saidi'),
          ],
        ),
    );
    sl.registerSingleton<StudentRepository>(
      FakeStudentRepository()..students = [student('1', 'Yasmine', 'Ben Abdallah Trabelsi', rate: 94)],
    );
    sl.registerFactory<TeachersCubit>(() => TeachersCubit(FakeAdminRepository(accounts: accounts())));
    registerContentServices();
    final homework = FakeHomeworkRepository();
    // One homework already sent, for the "C'est envoyé !" card.
    final sent = mineOf('h-sent', 'Série 2 : les fractions, exercices 1 à 3', status: HomeworkStatus.submitted, submittedAt: at(5, 16, 40));
    homework.details['h-sent'] = myDetailOf(
      sent,
      submission: SubmissionInfo(id: 'sub', submittedAt: at(5, 16, 40), fileName: 'Scan.pdf', pageCount: 2),
    );
    // Copies to correct, a pupil who sent nothing, missing work for Ma journée.
    homework.rows['a-fr'] = [
      const RecipientRow(studentId: 's2', firstName: 'Rayen', lastName: 'Mansour', status: HomeworkStatus.missing),
      RecipientRow(
        studentId: 's3',
        firstName: 'Yasmine',
        lastName: 'Ben Abdallah Trabelsi',
        status: HomeworkStatus.late,
        submittedAt: at(4, 9, 30),
        submissionId: 'sub-s3',
      ),
    ];
    homework.queue = [
      ToCorrectGroup(
        assignment: homework.items.first,
        items: [
          ToCorrectItem(
            studentId: 's3',
            firstName: 'Yasmine',
            lastName: 'Ben Abdallah Trabelsi',
            status: HomeworkStatus.late,
            submittedAt: at(4, 9, 30),
            submissionId: 'sub-s3',
          ),
        ],
      ),
    ];
    homework.missingWork = [
      MissingWork(
        assignment: homework.items.last,
        missing: const [PupilName(studentId: 's2', firstName: 'Rayen', lastName: 'Mansour')],
      ),
    ];
    sl.registerSingleton<HomeworkRepository>(homework);
    sl.registerSingleton<GroupRepository>(FakeGroupWithMembers());
    sl.registerSingleton<ResultsRepository>(FakeResultsRepository());
    sl.registerSingleton<EvaluationRepository>(
      FakeEvaluationRepository(items: [sampleEvaluation()], details: {'e1': sampleEvaluationDetail()}),
    );
    sl.registerSingleton<CommentRepository>(
      FakeCommentRepository(
        items: [
          NoteEntry(
            id: 'c1',
            body: 'Adam participe bien. Il doit revoir la simplification des fractions avant vendredi.',
            createdAt: at(5, 18),
            updatedAt: at(5, 18),
          ),
        ],
      ),
    );
  });

  Future<void> pumpShell(WidgetTester tester, Widget shell, AppUser user, AppLanguage language, Size size) async {
    final notifications = NotificationsCubit(FakeNotificationRepository(items: changes()));
    addTearDown(notifications.close);
    await pumpSignedIn(tester, shell, user: user, language: language, size: size, notifications: notifications);
  }

  for (final language in AppLanguage.values) {
    for (final size in sizes) {
      final label = '${language.name} ${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('pupil home fits, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(
            destinations: studentDestinations(),
            location: Routes.studentHome,
            bell: const NotificationBell(),
            child: const StudentHomeScreen(),
          ),
          pupil,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(StudentHomeView), findsOneWidget);
      });

      testWidgets('pupil planning fits, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(
            destinations: studentDestinations(),
            location: Routes.studentPlanning,
            bell: const NotificationBell(),
            child: const MyPlanningScreen(),
          ),
          pupil,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('owner dashboard fits, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(destinations: adminDestinations(), location: Routes.adminTeachers, child: const TeachersScreen()),
          owner,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('teacher library fits, $label', (tester) async {
        await pumpSignedIn(
          tester,
          AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherContents, child: const ContentsScreen()),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Série 2 : les fractions'), findsOneWidget);
      });

      testWidgets('pupil Cours fits, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(
            destinations: studentDestinations(),
            location: Routes.studentCourses,
            bell: const NotificationBell(),
            child: const MyContentsScreen(),
          ),
          pupil,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('parent Cours fits, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(destinations: parentDestinations(), location: Routes.parentCourses, child: const MyContentsScreen()),
          parent,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('document viewer fits, $label', (tester) async {
        await pumpShell(tester, const DocumentScreen(documentId: 'serie2', backTo: Routes.studentCourses), pupil, language, size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('scan pages fit, $label', (tester) async {
        final cubit = ScanCubit(sl.get(), sl.get());
        addTearDown(cubit.close);
        await cubit.pickPhotos();
        await pumpSignedIn(
          tester,
          BlocProvider.value(value: cubit, child: const ScanScreen()),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('crop fits, $label', (tester) async {
        final cubit = CropCubit(ScanPage(id: 'p', bytes: tinyPng, width: 30, height: 40, preview: tinyPng));
        addTearDown(cubit.close);
        await pumpSignedIn(
          tester,
          BlocProvider.value(value: cubit, child: const CropScreen(index: 1, count: 3)),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('teacher homework and its panel fit, $label', (tester) async {
        await pumpSignedIn(
          tester,
          AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherAssignments, child: const HomeworkScreen()),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(l10nOf(language).newHomework).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('a homework for the teacher fits, $label', (tester) async {
        await pumpSignedIn(
          tester,
          AdaptiveShell(
            destinations: teacherDestinations(),
            location: Routes.teacherHomework('a-old'),
            child: const AssignmentScreen(assignmentId: 'a-old'),
          ),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('pupil and parent homework fit, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(destinations: studentDestinations(), location: Routes.studentAssignments, child: const MyHomeworkScreen()),
          pupil,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
        await pumpShell(
          tester,
          AdaptiveShell(destinations: parentDestinations(), location: Routes.parentAssignments, child: const MyHomeworkScreen()),
          parent,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('a homework to send, and one sent, fit, $label', (tester) async {
        await pumpShell(tester, const MyHomeworkDetailScreen(assignmentId: 'h-fr'), pupil, language, size);
        expect(tester.takeException(), isNull);
        await pumpShell(tester, const MyHomeworkDetailScreen(assignmentId: 'h-sent', studentId: 'me'), parent, language, size);
        expect(tester.takeException(), isNull);
      });

      testWidgets('correction fits, with a copy and without one, $label', (tester) async {
        for (final studentId in ['s3', 's2']) {
          await pumpSignedIn(
            tester,
            BlocProvider(create: (_) => CorrectionCubit(sl.get(), sl.get(), 'a-fr', studentId)..load(), child: const CorrectionBody()),
            language: language,
            size: size,
          );
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('Ma journée with copies to correct and missing work fits, $label', (tester) async {
        await pumpSignedIn(
          tester,
          BlocProvider(
            create: (_) => TeacherHomeCubit(DashboardRepositoryImpl(sl.get(), sl.get(), now: () => now))..load(),
            child: AdaptiveShell(destinations: teacherDestinations(), location: Routes.teacherHome, child: const TeacherHomeView()),
          ),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('results and the parent overview fit, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(destinations: studentDestinations(), location: Routes.studentResults, child: const MyResultsScreen()),
          pupil,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
        await pumpShell(
          tester,
          AdaptiveShell(destinations: parentDestinations(), location: Routes.parentResults, child: const MyResultsScreen()),
          parent,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
        await pumpShell(
          tester,
          AdaptiveShell(destinations: parentDestinations(), location: Routes.parentOverview, child: const ParentOverviewScreen()),
          parent,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('the Fiche élève with grades and session mode with the day\'s documents fit, $label', (tester) async {
        await pumpSignedIn(
          tester,
          const Scaffold(body: StudentProfileScreen(studentId: '1')),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
        await pumpSignedIn(
          tester,
          BlocProvider(
            create: (_) => SessionModeCubit(sl.get(), 's1', attendanceDelay: Duration.zero, noteDelay: Duration.zero)..open(),
            child: const SessionModeView(),
          ),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });

      testWidgets('the search fits, its results typed in, $label', (tester) async {
        sl.registerSingleton<SearchRepository>(FakeSearchRepository());
        sl.registerFactory<SearchCubit>(() => SearchCubit(sl.get(), delay: Duration.zero));
        await pumpSignedIn(
          tester,
          AdaptiveShell(
            destinations: teacherDestinations(),
            location: Routes.teacherHome,
            search: const TeacherSearchField(),
            phoneSearch: const SearchButton(),
            child: const SizedBox.expand(),
          ),
          language: language,
          size: size,
        );
        expect(tester.takeException(), isNull);
        if (size.width < 600) {
          await tester.tap(find.byType(SearchButton));
          await tester.pumpAndSettle();
        }
        for (final query in ['frac', 'ben', 'rien du tout']) {
          await tester.enterText(find.byType(TextField), query);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('the three steps of a pupils\' import fit, $label', (tester) async {
        final chooser = FakeFileChooser()..next = PickedFile(name: 'classe-4A avec un nom de fichier assez long.xlsx', bytes: Uint8List(4));
        final cubit = StudentImportCubit(FakeStudentImportRepository(), chooser);
        addTearDown(cubit.close);
        sl.registerSingleton<DocumentPrinter>(FakeDocumentPrinter());
        Widget shell() => AdaptiveShell(
          destinations: teacherDestinations(),
          location: Routes.teacherStudents,
          child: BlocProvider.value(value: cubit, child: const StudentImportView()),
        );
        await pumpSignedIn(tester, shell(), language: language, size: size);
        expect(tester.takeException(), isNull);
        await cubit.chooseFile();
        await tester.pumpAndSettle();
        expect(find.byType(Checkbox), findsWidgets);
        expect(tester.takeException(), isNull);
        await cubit.importKept();
        await tester.pumpAndSettle();
        expect(find.text('kpra4827'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('a paper evaluation\'s score table and its panel fit, $label', (tester) async {
        await pumpSignedIn(
          tester,
          AdaptiveShell(
            destinations: teacherDestinations(),
            location: Routes.teacherAssignments,
            child: Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    onPressed: () => EvaluationPanel.open(context, groupId: 'g4a'),
                    child: const Text('panel'),
                  ),
                  const Expanded(child: EvaluationScreen(evaluationId: 'e1')),
                ],
              ),
            ),
          ),
          language: language,
          size: size,
        );
        expect(find.text('Évaluation : la multiplication'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('panel'));
        await tester.pumpAndSettle();
        expect(find.byType(EvaluationPanel), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('the teacher\'s notifications fit, from the bell, $label', (tester) async {
        final notifications = NotificationsCubit(FakeNotificationRepository(items: teacherSample(now)));
        addTearDown(notifications.close);
        await notifications.refreshCount();
        await pumpSignedIn(
          tester,
          AdaptiveShell(
            destinations: teacherDestinations(),
            location: Routes.teacherHome,
            bell: const NotificationBell(onPressed: TeacherNotificationsPanel.open),
            child: const SizedBox.expand(),
          ),
          language: language,
          size: size,
          notifications: notifications,
        );
        await tester.tap(find.byType(NotificationBell));
        await tester.pumpAndSettle();
        expect(find.byType(TeacherNotificationsPanel), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('notifications fit, $label', (tester) async {
        await pumpShell(
          tester,
          AdaptiveShell(destinations: parentDestinations(), location: Routes.parentNotifications, child: const NotificationsScreen()),
          parent,
          language,
          size,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
