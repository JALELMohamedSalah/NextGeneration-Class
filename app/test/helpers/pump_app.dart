import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ngclass/core/di/injection.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/language_store.dart';
import 'package:ngclass/core/l10n/tunis_time.dart';
import 'package:ngclass/core/platform/link_opener.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/repositories/auth_repository.dart';
import 'package:ngclass/l10n/app_localizations.dart';
import 'package:ngclass/view/stateManager/auth/auth_cubit.dart';
import 'package:ngclass/view/stateManager/groups/groups_cubit.dart';
import 'package:ngclass/view/stateManager/language/language_cubit.dart';
import 'package:ngclass/view/stateManager/notifications/notifications_cubit.dart';
import 'package:ngclass/view/stateManager/reference/reference_cubit.dart';

import 'fakes.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MemoryLanguageStore implements LanguageStore {
  AppLanguage? saved;

  @override
  Future<AppLanguage?> read() async => saved;

  @override
  Future<void> save(AppLanguage language) async => saved = language;
}

class RecordingLinkOpener implements LinkOpener {
  final opened = <String>[];

  @override
  Future<bool> open(String url) async {
    opened.add(url);
    return true;
  }
}

const teacher = AppUser(
  id: 't',
  role: UserRole.teacher,
  username: 'ines',
  firstName: 'Ines',
  lastName: 'Haddad',
  mustChangePassword: false,
);

/// Services screens read from the locator: a fixed clock and a link opener that only records.
RecordingLinkOpener registerTestServices(DateTime now) {
  sl.reset();
  sl.registerSingleton<Now>(() => now);
  final links = RecordingLinkOpener();
  sl.registerSingleton<LinkOpener>(links);
  return links;
}

/// Pumps [child] signed in as [user], in [language], on a screen of [size], with the teacher's groups
/// and reference lists. Plain MaterialApp without AppTheme: fonts cannot be downloaded in tests.
/// With [router], the app follows it instead of showing [child]; [notifications] is the role shell's cubit.
Future<void> pumpSignedIn(
  WidgetTester tester,
  Widget child, {
  AppUser user = teacher,
  AppLanguage language = AppLanguage.fr,
  Size size = const Size(1440, 1000),
  FakeGroupRepository? groups,
  FakeReferenceRepository? reference,
  NotificationsCubit? notifications,
  GoRouter? router,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = AuthCubit(MockAuthRepository())..signedIn(user);
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: auth),
        BlocProvider(create: (_) => LanguageCubit(MemoryLanguageStore(), initial: language)),
        BlocProvider(create: (_) => GroupsCubit(groups ?? FakeGroupRepository())..load()),
        BlocProvider(create: (_) => ReferenceCubit(reference ?? FakeReferenceRepository())..load()),
        // The role shells always hold one; screens that list what is new read it.
        if (notifications != null)
          BlocProvider.value(value: notifications)
        else
          BlocProvider(create: (_) => NotificationsCubit(FakeNotificationRepository())),
      ],
      child: router == null
          ? MaterialApp(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: child,
            )
          : MaterialApp.router(
              locale: language.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              routerConfig: router,
            ),
    ),
  );
  await tester.pumpAndSettle();
}

AppLocalizations l10nOf(AppLanguage language) => lookupAppLocalizations(language.locale);

/// Every text field inside [within] shows a hint while empty (user rule: never an empty box).
void expectEveryFieldHasAHint(Finder within) {
  final fields = find.descendant(of: within, matching: find.byType(TextField));
  expect(fields, findsWidgets);
  for (final element in fields.evaluate()) {
    final hint = (element.widget as TextField).decoration?.hintText ?? '';
    expect(hint.trim(), isNotEmpty, reason: 'a field without a hint: $element');
  }
}
