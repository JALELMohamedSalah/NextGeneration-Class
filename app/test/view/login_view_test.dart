import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ngclass/core/l10n/app_language.dart';
import 'package:ngclass/core/l10n/language_store.dart';
import 'package:ngclass/core/network/api_failure.dart';
import 'package:ngclass/domain/model/app_user.dart';
import 'package:ngclass/domain/repositories/auth_repository.dart';
import 'package:ngclass/l10n/app_localizations.dart';
import 'package:ngclass/view/screens/shared/login_screen.dart';
import 'package:ngclass/view/stateManager/auth/auth_cubit.dart';
import 'package:ngclass/view/stateManager/auth/auth_state.dart';
import 'package:ngclass/view/stateManager/language/language_cubit.dart';
import 'package:ngclass/view/stateManager/login/login_cubit.dart';

import '../helpers/pump_app.dart' show expectEveryFieldHasAHint;

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MemoryLanguageStore implements LanguageStore {
  AppLanguage? saved;

  @override
  Future<AppLanguage?> read() async => saved;

  @override
  Future<void> save(AppLanguage language) async => saved = language;
}

void main() {
  late _MockAuthRepository repository;
  late AuthCubit auth;

  setUp(() {
    repository = _MockAuthRepository();
    auth = AuthCubit(repository);
  });

  Future<void> pumpLogin(WidgetTester tester, AppLanguage language) async {
    final languageCubit = LanguageCubit(_MemoryLanguageStore(), initial: language);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: languageCubit),
          BlocProvider(create: (_) => LoginCubit(repository, auth)),
        ],
        child: BlocBuilder<LanguageCubit, AppLanguage>(
          builder: (context, current) => MaterialApp(
            locale: current.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const LoginView(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillAndSubmit(WidgetTester tester, AppLocalizations l10n) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'eleve.demo');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.text(l10n.loginSubmit));
    await tester.pumpAndSettle();
  }

  testWidgets('an empty form is refused before calling the server', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    await pumpLogin(tester, AppLanguage.fr);

    await tester.tap(find.text(fr.loginSubmit));
    await tester.pump();

    expect(find.text(fr.loginIdentifierRequired), findsOneWidget);
    expect(find.text(fr.loginPasswordRequired), findsOneWidget);
    verifyNever(
      () => repository.login(
        login: any(named: 'login'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('refusal messages follow the language switch and clear as the user types', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    await pumpLogin(tester, AppLanguage.fr);

    expect(find.text(fr.loginIdentifierHint), findsOneWidget);
    expectEveryFieldHasAHint(find.byType(LoginView));
    await tester.tap(find.text(fr.loginSubmit));
    await tester.pump();
    await tester.tap(find.text(fr.languageArabic));
    await tester.pumpAndSettle();

    expect(find.text(ar.loginIdentifierRequired), findsOneWidget);
    expect(find.text(fr.loginIdentifierRequired), findsNothing);

    await tester.enterText(find.byType(TextFormField).at(0), 'eleve.demo');
    await tester.pump();

    expect(find.text(ar.loginIdentifierRequired), findsNothing);
    expect(find.text(ar.loginPasswordRequired), findsOneWidget);
  });

  testWidgets('Arabic shows Arabic texts, right to left', (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    await pumpLogin(tester, AppLanguage.ar);

    expect(find.text(ar.loginWelcome), findsOneWidget);
    expect(find.text(ar.loginSubmit), findsOneWidget);
    expect(Directionality.of(tester.element(find.text(ar.loginWelcome))), TextDirection.rtl);
  });

  testWidgets('the language switch changes the whole screen', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    final ar = lookupAppLocalizations(const Locale('ar'));
    await pumpLogin(tester, AppLanguage.fr);

    await tester.tap(find.text(fr.languageArabic));
    await tester.pumpAndSettle();

    expect(find.text(ar.loginWelcome), findsOneWidget);
    expect(find.text(fr.loginWelcome), findsNothing);
  });

  testWidgets('a refusal shows the message written by the server', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    when(
      () => repository.login(login: 'eleve.demo', password: 'secret'),
    ).thenThrow(const ApiFailure(code: 'invalid_credentials', message: 'Identifiant ou mot de passe incorrect.', statusCode: 401));
    await pumpLogin(tester, AppLanguage.fr);

    await fillAndSubmit(tester, fr);

    expect(find.text('Identifiant ou mot de passe incorrect.'), findsOneWidget);
  });

  testWidgets('no network is worded by the app in the current language', (tester) async {
    final ar = lookupAppLocalizations(const Locale('ar'));
    when(() => repository.login(login: 'eleve.demo', password: 'secret')).thenThrow(const ApiFailure(code: ApiFailure.network));
    await pumpLogin(tester, AppLanguage.ar);

    await fillAndSubmit(tester, ar);

    expect(find.text(ar.errorNetwork), findsOneWidget);
  });

  testWidgets('a successful login signs in', (tester) async {
    final fr = lookupAppLocalizations(const Locale('fr'));
    const user = AppUser(
      id: '1',
      role: UserRole.student,
      username: 'eleve.demo',
      firstName: 'Adam',
      lastName: 'Gharbi',
      mustChangePassword: false,
    );
    when(() => repository.login(login: 'eleve.demo', password: 'secret')).thenAnswer((_) async => user);
    await pumpLogin(tester, AppLanguage.fr);

    await fillAndSubmit(tester, fr);

    expect(auth.state, const AuthSignedIn(user));
  });
}
