import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/di/injection.dart';
import '../../../l10n/app_localizations.dart';
import '../../stateManager/login/login_cubit.dart';
import '../../widgets/buttons.dart';
import '../../widgets/cards.dart';
import '../../widgets/feedback.dart';
import '../../widgets/password_field.dart';
import '../../widgets/text_field.dart';
import 'welcome_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(create: (_) => sl.get<LoginCubit>(), child: const LoginView());
}

/// Design `Login.png`: brand pane at the start, the form at the end.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) => const WelcomeLayout(form: _LoginForm());
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();

  /// After a refused submit, errors are checked on every build: they follow the language and clear as the user types.
  bool _submitted = false;

  AutovalidateMode get _check => _submitted ? AutovalidateMode.always : AutovalidateMode.disabled;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_submitted) setState(() => _submitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().submit(login: _login.text, password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<LoginCubit>().state;
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WelcomeTitle(overline: l10n.loginOverline, title: l10n.loginWelcome, message: l10n.loginSubtitle),
            const SizedBox(height: 20),
            AppTextField(
              controller: _login,
              label: l10n.loginIdentifierLabel,
              hint: l10n.loginIdentifierHint,
              icon: LucideIcons.user,
              autofillHints: const [AutofillHints.username],
              textInputAction: TextInputAction.next,
              autovalidateMode: _check,
              validator: (value) => (value == null || value.trim().isEmpty) ? l10n.loginIdentifierRequired : null,
            ),
            const SizedBox(height: 20),
            PasswordField(
              controller: _password,
              label: l10n.loginPasswordLabel,
              hint: l10n.loginPasswordHint,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              autovalidateMode: _check,
              validator: (value) => (value == null || value.isEmpty) ? l10n.loginPasswordRequired : null,
            ),
            if (state.failure != null) ...[const SizedBox(height: 16), FailureBanner(state.failure!)],
            const SizedBox(height: 20),
            PrimaryButton(label: l10n.loginSubmit, arrow: true, shadow: true, loading: state.submitting, onPressed: _submit),
            const SizedBox(height: 20),
            InfoNote(text: l10n.loginForgotHint),
          ],
        ),
      ),
    );
  }
}
