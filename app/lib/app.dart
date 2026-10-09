import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/app_language.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'view/stateManager/auth/auth_cubit.dart';
import 'view/stateManager/language/language_cubit.dart';

class NgClassApp extends StatefulWidget {
  const NgClassApp({super.key, required this.authCubit, required this.languageCubit});

  final AuthCubit authCubit;
  final LanguageCubit languageCubit;

  @override
  State<NgClassApp> createState() => _NgClassAppState();
}

class _NgClassAppState extends State<NgClassApp> {
  late final GoRouter _router = buildRouter(widget.authCubit);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.authCubit),
        BlocProvider.value(value: widget.languageCubit),
      ],
      // Changing the language rebuilds the app: texts, fonts and direction (Arabic is right to left).
      child: BlocBuilder<LanguageCubit, AppLanguage>(
        builder: (context, language) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(language),
          locale: language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          routerConfig: _router,
        ),
      ),
    );
  }
}
