import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/l10n/formatting.dart';
import 'view/stateManager/auth/auth_cubit.dart';
import 'view/stateManager/language/language_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppDates();
  configureDependencies(AppConfig.fromEnvironment());
  final language = sl.get<LanguageCubit>();
  await language.load();
  final auth = sl.get<AuthCubit>();
  startSession(auth, language);
  unawaited(auth.restore());
  runApp(NgClassApp(authCubit: auth, languageCubit: language));
}
